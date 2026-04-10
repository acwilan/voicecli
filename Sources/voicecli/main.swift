import Foundation
import Speech
import AVFoundation

// Helper for stderr - global since it's commonly needed
let stderr = Darwin.stderr

@main
struct VoiceCLI {
    static func main() async {
        let arguments = CommandLine.arguments
        
        guard arguments.count > 1 else {
            printUsage()
            exit(1)
        }
        
        let command = arguments[1]
        
        do {
            switch command {
            case "transcribe":
                try await transcribeCommand(arguments: arguments)
            case "speak":
                try await speakCommand(arguments: arguments)
            case "voices":
                listVoices()
            default:
                print("Unknown command: \(command)", to: stderr)
                exit(1)
            }
        } catch {
            print("Error: \(error)", to: stderr)
            exit(1)
        }
    }
    
    static func printUsage() {
        fputs("Usage: voicecli <command> [options]\n", stderr)
        fputs("Commands:\n", stderr)
        fputs("  transcribe <audio-file>       - Transcribe audio to text\n", stderr)
        fputs("  speak <text-or-file> [options] - Convert text to speech\n", stderr)
        fputs("  voices                         - List available voices\n", stderr)
        fputs("\n", stderr)
        fputs("Speak options:\n", stderr)
        fputs("  --output <path>               - Save to file (default: play via speaker)\n", stderr)
        fputs("  --voice <voice-name>          - Use specific voice (default: system default)\n", stderr)
        fputs("  --rate <rate>                 - Speech rate 0.0-1.0 (default: 0.5)\n", stderr)
        fputs("\n", stderr)
        fputs("Speak input:\n", stderr)
        fputs("  Plain text:  voicecli speak \"Hello world\"\n", stderr)
        fputs("  File input:  voicecli speak ./response.md\n", stderr)
        fputs("  Stdin (-):   echo \"Hello\" | voicecli speak -\n", stderr)
    }
    
    static func transcribeCommand(arguments: [String]) async throws {
        guard arguments.count > 2 else {
            fputs("Usage: voicecli transcribe <audio-file>\n", stderr)
            exit(1)
        }
        
        let audioPath = arguments[2]
        
        // Request speech recognition authorization
        let authStatus = await requestSpeechAuthorization()
        guard authStatus == .authorized else {
            throw NSError(domain: "VoiceCLI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized. Check System Settings > Privacy & Security > Speech Recognition"])
        }
        
        let recognizer = SFSpeechRecognizer()
        guard let recognizer = recognizer else {
            throw NSError(domain: "VoiceCLI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
        }
        
        let url = URL(fileURLWithPath: audioPath)
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        // Enable on-device recognition if available
        if #available(macOS 13.0, *) {
            request.requiresOnDeviceRecognition = false
        }
        
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SFSpeechRecognitionResult, Error>) in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result = result else { return }
                if result.isFinal {
                    continuation.resume(returning: result)
                }
            }
        }
        
        print(result.bestTranscription.formattedString)
    }
    
    static func speakCommand(arguments: [String]) async throws {
        guard arguments.count > 2 else {
            fputs("Usage: voicecli speak <text-or-file> [--output <path>] [--voice <voice>] [--rate <rate>]\n", stderr)
            exit(1)
        }
        
        // Parse arguments
        var inputSource: String?
        var outputPath: String?
        var voiceName: String?
        var rate: Float = 0.5
        
        var i = 2
        while i < arguments.count {
            let arg = arguments[i]
            switch arg {
            case "--output":
                i += 1
                if i < arguments.count {
                    outputPath = arguments[i]
                }
            case "--voice":
                i += 1
                if i < arguments.count {
                    voiceName = arguments[i]
                }
            case "--rate":
                i += 1
                if i < arguments.count {
                    rate = Float(arguments[i]) ?? 0.5
                }
            default:
                if inputSource == nil {
                    inputSource = arg
                }
            }
            i += 1
        }
        
        guard let input = inputSource else {
            throw NSError(domain: "VoiceCLI", code: 5, userInfo: [NSLocalizedDescriptionKey: "No input provided"])
        }
        
        // Determine text source: file, stdin, or direct text
        let text: String
        if input == "-" {
            // Read from stdin
            text = readStdin()
        } else if FileManager.default.fileExists(atPath: input) && FileManager.default.isReadableFile(atPath: input) {
            // Read from file
            let url = URL(fileURLWithPath: input)
            text = try String(contentsOf: url, encoding: .utf8)
        } else {
            // Use as direct text
            text = input
        }
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "VoiceCLI", code: 6, userInfo: [NSLocalizedDescriptionKey: "Empty text"])
        }
        
        if let outputPath = outputPath {
            // Save to file using 'say' command
            try await saveToFile(text: text, path: outputPath, voice: voiceName, rate: rate)
        } else {
            // Play via speaker
            try await playViaSpeaker(text: text, voice: voiceName, rate: rate)
        }
    }
    
    static func listVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices().sorted { $0.language < $1.language }
        for voice in voices {
            let quality = voice.quality == .enhanced ? " (enhanced)" : ""
            print("\(voice.identifier) [\(voice.language)]\(quality)")
        }
    }
    
    static func saveToFile(text: String, path: String, voice: String?, rate: Float) async throws {
        var args = ["-o", path]
        
        if let voice = voice {
            args.append("-v")
            args.append(voice)
        }
        
        // 'say' command doesn't have rate control directly, but we can pipe the text
        args.append(text)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        process.arguments = args
        
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw NSError(domain: "VoiceCLI", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to save audio file"])
        }
        
        print("Saved to: \(path)", to: stderr)
    }
    
    static func playViaSpeaker(text: String, voice: String?, rate: Float) async throws {
        let synthesizer = AVSpeechSynthesizer()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        
        // Set voice if specified
        if let voiceName = voice {
            if let voice = AVSpeechSynthesisVoice(identifier: voiceName) {
                utterance.voice = voice
            } else if let voice = AVSpeechSynthesisVoice(language: voiceName) {
                utterance.voice = voice
            }
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let delegate = SpeakDelegate(continuation: continuation)
            synthesizer.delegate = delegate
            synthesizer.speak(utterance)
        }
    }
    
    static func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}

// Helper to read from stdin
func readStdin() -> String {
    var text = ""
    while let line = readLine() {
        if !text.isEmpty {
            text += "\n"
        }
        text += line
    }
    return text
}

// Delegate for tracking speech synthesis completion
class SpeakDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let continuation: CheckedContinuation<Void, Error>
    
    init(continuation: CheckedContinuation<Void, Error>) {
        self.continuation = continuation
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        continuation.resume()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        continuation.resume(throwing: NSError(domain: "VoiceCLI", code: 4, userInfo: [NSLocalizedDescriptionKey: "Speech synthesis cancelled"]))
    }
}

// Helper for print to FILE pointer
func print(_ items: Any..., to stream: UnsafeMutablePointer<FILE>) {
    let output = items.map { "\($0)" }.joined(separator: " ") + "\n"
    fputs(output, stream)
}

# AGENTS.md - voicecli

This document helps AI assistants understand and work with this codebase.

## Project Overview

`voicecli` is a macOS-native CLI tool for speech operations:
- **Transcribe** audio to text using `SFSpeechRecognizer`
- **Synthesize** text to speech using `AVSpeechSynthesizer` or `say` command

## Architecture

### Entry Point
- `@main struct VoiceCLI` in `Sources/voicecli/main.swift`
- Async entry point, dispatches to subcommands

### Commands

#### `transcribe <audio-file>`
- Uses `SFSpeechRecognizer` with `SFSpeechURLRecognitionRequest`
- Requires macOS Speech Recognition permission
- Outputs transcribed text to stdout

#### `speak <text-or-file> [options]`
- Auto-detects input type (text, file, or stdin via `-`)
- Two output modes:
  - **Speaker**: `AVSpeechSynthesizer` (real-time playback)
  - **File**: `/usr/bin/say -o` (generates AIFF)
- Options: `--output`, `--voice`, `--rate`

#### `voices`
- Lists all available `AVSpeechSynthesisVoice` instances
- Shows identifier, language, and quality

## Key Design Decisions

1. **Swift Package Manager** — Simple, no external dependencies
2. **Auto-detect input** — Less friction for users
3. **Dual TTS backends** — `AVSpeechSynthesizer` for playback, `say` for file export
4. **No config files** — Everything via CLI args

## Permissions

Speech recognition requires user permission via:
- System Settings → Privacy & Security → Speech Recognition
- First run prompts automatically via `SFSpeechRecognizer.requestAuthorization()`

## Platform Limitations

- macOS only (uses `SFSpeechRecognizer` and `AVSpeechSynthesizer`)
- Requires macOS 13.0+ for full feature set
- Audio file output is AIFF format (via `say` command)

## Testing

Currently manual testing:
```bash
swift build
.build/debug/voicecli voices
.build/debug/voicecli speak "test" --output /tmp/out.aiff
```

## Dependencies

- `Foundation` — Core functionality
- `Speech` — `SFSpeechRecognizer`
- `AVFoundation` — `AVSpeechSynthesizer`
- `/usr/bin/say` — System command for file output

## Future Ideas

- [ ] Support for MP3/OGG output (requires audio conversion)
- [ ] Configurable default voice via env var
- [ ] Batch transcription of multiple files
- [ ] Word-level timestamps in transcription
- [ ] Unit tests
- [ ] CI/CD with GitHub Actions

## Context for AI Assistants

When modifying this code:
- Test on macOS (Linux won't work due to Apple frameworks)
- Respect the async/await patterns already in place
- Keep the CLI interface stable — it's the public API
- File I/O should use `FileManager` APIs, not shell commands
- Audio permissions are required for transcription only

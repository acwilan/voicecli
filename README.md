# voicecli

macOS native voice CLI — transcribe audio to text and synthesize speech.

## Commands

### Transcribe audio to text
```bash
voicecli transcribe /path/to/audio.m4a
```

### Text to speech (play via speaker)
```bash
voicecli speak "Hello world"
```

### Text to speech (save to file)
```bash
voicecli speak "Hello world" --output /path/to/output.aiff
```

### Text to speech from file
```bash
voicecli speak /path/to/response.md --output /path/to/output.aiff
```

### Text to speech from stdin
```bash
echo "Hello world" | voicecli speak -
cat response.md | voicecli speak - --output response.aiff
```

### List available voices
```bash
voicecli voices
```

## Options for `speak`

- `--output <path>` — Save audio to file instead of playing
- `--voice <voice-id>` — Use specific voice (see `voicecli voices`)
- `--rate <0.0-1.0>` — Speech rate (default: 0.5)

## Speak Input Detection

The `speak` command auto-detects input type:
- **Plain text**: `voicecli speak "Hello world"`
- **File path**: If the argument is a readable file, it reads the file content
- **Stdin (`-`)**: Read from standard input for piping

## Permissions

First run of `transcribe` will prompt for Speech Recognition permission.
Check System Settings → Privacy & Security → Speech Recognition if denied.

## Building

```bash
swift build
swift build -c release  # For release build
```

## Installation

### Homebrew (recommended)

```bash
brew tap acwilan/voicecli
brew install voicecli
```

### Download Binary

Download the latest release from [GitHub Releases](https://github.com/acwilan/voicecli/releases):

```bash
curl -L https://github.com/acwilan/voicecli/releases/latest/download/voicecli-macos.tar.gz | tar xz
mv voicecli ~/.local/bin/  # or /usr/local/bin/
```

### Build from Source

```bash
git clone https://github.com/acwilan/voicecli.git
cd voicecli
swift build -c release
cp .build/release/voicecli ~/.local/bin/
```

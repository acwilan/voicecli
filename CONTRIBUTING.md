# Contributing to voicecli

Thanks for your interest in contributing! This is a small CLI tool for macOS speech functionality.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/acwilan/voicecli.git`
3. Build the project: `swift build`
4. Run tests: `swift test` (when tests are added)

## Development

### Requirements

- macOS 13.0+
- Swift 5.9+
- Xcode Command Line Tools

### Project Structure

```
voicecli/
├── Package.swift          # Swift Package Manager manifest
├── Sources/
│   └── voicecli/
│       └── main.swift     # Entry point and CLI logic
├── README.md              # Documentation
└── LICENSE                # MIT License
```

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Install locally (after build)
cp .build/release/voicecli ~/.local/bin/
```

## Submitting Changes

1. Create a feature branch: `git checkout -b feature/my-change`
2. Make your changes
3. Test locally
4. Commit with clear messages
5. Push to your fork
6. Open a Pull Request

### Commit Message Format

- Use present tense: "Add feature" not "Added feature"
- Use imperative mood: "Move cursor to..." not "Moves cursor to..."
- Limit first line to 72 characters
- Reference issues when relevant: "Fix #123"

## Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Keep functions focused and small
- Add comments for non-obvious logic

## Reporting Issues

When filing an issue, please include:

- macOS version
- Swift version (`swift --version`)
- Steps to reproduce
- Expected vs actual behavior
- Any error messages

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

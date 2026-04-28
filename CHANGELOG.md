# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-04-28

### Added

- New `locales` command to list all supported STT locales
- `--locale` flag for `transcribe` command to specify recognition locale
- `--locale` flag for `speak` command to select TTS voice by locale
- Updated help text with new flags and commands

## [0.2.0] - 2025-04-10

### Added

- `--help` and `--version` global flags
- CI workflow for auto-updating homebrew formula on release

### Fixed

- Prevent continuation leak in `playViaSpeaker`
- CI permissions for release job

## [0.1.0] - 2025-04-08

### Added

- Initial release
- `transcribe` command for audio-to-text using macOS native Speech framework
- `speak` command for text-to-speech using AVFoundation
- `voices` command to list available TTS voices
- Support for file output, voice selection, and speech rate control
- Stdin input support for speak command

[unreleased]: https://github.com/acwilan/voicecli/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/acwilan/voicecli/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/acwilan/voicecli/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/acwilan/voicecli/releases/tag/v0.1.0

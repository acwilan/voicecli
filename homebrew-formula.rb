# Homebrew formula for voicecli
# This is a template - update URL and SHA256 for each release

class Voicecli < Formula
  desc "macOS native voice CLI for transcription and speech synthesis"
  homepage "https://github.com/acwilan/voicecli"
  url "https://github.com/acwilan/voicecli/releases/download/v0.1.0/voicecli-macos.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on :macos

  def install
    bin.install "voicecli"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/voicecli --help 2>&1 || true")
    system "#{bin}/voicecli", "voices"
  end
end

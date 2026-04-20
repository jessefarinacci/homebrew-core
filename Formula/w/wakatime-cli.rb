class WakatimeCli < Formula
  desc "Command-line interface to the WakaTime api"
  homepage "https://wakatime.com/"
  url "https://github.com/wakatime/wakatime-cli.git",
      tag:      "v2.6.0",
      revision: "b361c3e9b491550688070ce6c3f555d03d8fb495"
  license "BSD-3-Clause"
  version_scheme 1

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "26eb65946dd42c4b67856932737f8434a7379500a2a38fd827cb32e4d2598990"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "26eb65946dd42c4b67856932737f8434a7379500a2a38fd827cb32e4d2598990"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "26eb65946dd42c4b67856932737f8434a7379500a2a38fd827cb32e4d2598990"
    sha256 cellar: :any_skip_relocation, sonoma:        "eaf3c603b250a01cb41512b48af9ff9f2309e87848849e83cbc5b735eb52cb3b"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "baefd70050731d81416bf3b7b3cd3adb56b8cf7c5978f1e6ab5dbb23cb3da90d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "eb0c8101431e3be66c26aad538542e0181ed834e9b9a58956f2e066c4bfce5cf"
  end

  depends_on "go" => :build

  def install
    arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
    ldflags = %W[
      -s -w
      -X github.com/wakatime/wakatime-cli/pkg/version.Arch=#{arch}
      -X github.com/wakatime/wakatime-cli/pkg/version.BuildDate=#{time.iso8601}
      -X github.com/wakatime/wakatime-cli/pkg/version.Commit=#{Utils.git_head(length: 7)}
      -X github.com/wakatime/wakatime-cli/pkg/version.OS=#{OS.kernel_name.downcase}
      -X github.com/wakatime/wakatime-cli/pkg/version.Version=v#{version}
    ].join(" ")
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    output = shell_output("#{bin}/wakatime-cli --help 2>&1")
    assert_match "Command line interface used by all WakaTime text editor plugins", output
  end
end

class Consul < Formula
  desc "Tool for service discovery, monitoring and configuration"
  homepage "https://www.consul.io"
  url "https://github.com/hashicorp/consul.git",
      :tag => "v1.2.0",
      :revision => "28141971f966e99916da2c5e461dd968746491cd"
  head "https://github.com/hashicorp/consul.git",
       :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "ad59f466d3ca275f1bf5d91b20730976e820b02820cd44df8a33546807bf8314" => :high_sierra
    sha256 "1f853423f648cad30e8af265d04af9a696952ec557f36e053fc019732b8fc67e" => :sierra
    sha256 "a5922c64d19c4954f5f10659cf26e78f69272b29a30fe1155ee1e0dccfaf8f18" => :el_capitan
    sha256 "c185b7ead59da74fe920a35fcf92b2f41bc2dfa31b0437f6cb93794f3da5195a" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "gox" => :build
  depends_on "zip" => :build unless OS.mac?

  def install
    inreplace *(OS.mac? ? "scripts/build.sh" : "build-support/functions/20-build.sh"), "-tags=\"${GOTAGS}\" \\", "-tags=\"${GOTAGS}\" -parallel=4 \\"

    # Avoid running `go get`
    inreplace "GNUmakefile", "go get -u -v $(GOTOOLS)", ""

    ENV["XC_OS"] = OS.mac? ? "darwin" : "linux"
    ENV["XC_ARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386" if OS.mac?
    ENV["XC_ARCH"] = "amd64" unless OS.mac?
    ENV["GOPATH"] = buildpath
    contents = Dir["{*,.git,.gitignore}"]
    (buildpath/"src/github.com/hashicorp/consul").install contents

    (buildpath/"bin").mkpath

    cd "src/github.com/hashicorp/consul" do
      system "make"
      bin.install "bin/consul"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "consul agent -dev -advertise 127.0.0.1"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/consul</string>
          <string>agent</string>
          <string>-dev</string>
          <string>-advertise</string>
          <string>127.0.0.1</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/consul.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/consul.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    # Workaround for Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]

    fork do
      exec "#{bin}/consul", "agent", *("-bind" unless OS.mac?), *("127.0.0.1" unless OS.mac?), "-data-dir", "."
    end
    sleep 3
    system "#{bin}/consul", "leave"
  end
end

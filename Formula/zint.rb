class Zint < Formula
  desc "Barcode encoding library supporting over 50 symbologies"
  homepage "http://www.zint.org.uk/"
  url "https://downloads.sourceforge.net/project/zint/zint/2.6.3/zint-2.6.3.src.tar.gz"
  sha256 "adcaebeb2931163a567073644c8e7952430ea31e08060363432d77cc599318d8"
  head "https://git.code.sf.net/p/zint/code.git"

  bottle do
    cellar :any
    sha256 "84fcae80b8ad56b4a4d5666a617a57c9f49afac7783f6298582a3ce053aa157b" => :high_sierra
    sha256 "831d734afaa473f891a750799641da15653007ddd0355e8b7b2d1a49c2cc3550" => :sierra
    sha256 "ecf62997149cefbc38b5b74ca99eeeab44569525d2ef67a4822a3c706e073ce7" => :el_capitan
    sha256 "bd862fd26004e1ad03ee1c1c4c8d9686086af2d859290adc1bb2cf237156b716" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "libpng"

  def install
    # Sandbox fix: install FindZint.cmake in zint's prefix, not cmake's.
    inreplace "CMakeLists.txt", "${CMAKE_ROOT}", "#{share}/cmake"

    mkdir "zint-build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/zint", "-o", "test-zing.png", "-d", "This Text"
  end
end

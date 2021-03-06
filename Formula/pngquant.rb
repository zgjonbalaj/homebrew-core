class Pngquant < Formula
  desc "PNG image optimizing utility"
  homepage "https://pngquant.org/"
  url "https://pngquant.org/pngquant-2.12.0-src.tar.gz"
  sha256 "0e540c64bb58c05f2a05b4eaf1d3d165f0d3278500f15abfeac47f93f8fa8fa8"
  head "https://github.com/kornelski/pngquant.git"

  bottle do
    cellar :any
    sha256 "f052f75b1b03c360dfa13a80322c5e24d60e74d7e330cc77c29e7a9ea9dfcc0b" => :high_sierra
    sha256 "cbd79a30ce1a5302c158bb623d79e90d4637f0a4267973731fa1501c6351adb8" => :sierra
    sha256 "62aca3d86ea5a1a8db27cb073f3ed715e53d1734981d14124019eddd419cb60c" => :el_capitan
    sha256 "26d0d7839fae15358638d6e379986208a84a223d23cc70c58923ffe89a773176" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libpng"
  depends_on "little-cms2"

  def install
    system "cargo", "install", "--root", prefix
    man1.install "pngquant.1"
  end

  test do
    system "#{bin}/pngquant", test_fixtures("test.png"), "-o", "out.png"
    assert_predicate testpath/"out.png", :exist?
  end
end

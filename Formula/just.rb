class Just < Formula
  desc "Handy way to save and run project-specific commands"
  homepage "https://github.com/casey/just"
  url "https://github.com/casey/just/archive/v0.3.12.tar.gz"
  sha256 "e5ca71efd19db8f157131cddb14d75ba161851e79e1cc9fc709e2c674d2c943b"

  bottle do
    sha256 "a3cf6e47a38bd3cbf8bfb09dce648f447dffec708eed07994491b1509bf857a8" => :high_sierra
    sha256 "b1e19274a73e5bf4d0b3b38bd26270d9b4ff97e4191ffd3ecdee353e0dae468e" => :sierra
    sha256 "a46cd86aa51e106d8025ab98cc560b3c1adee3524a7121d81ce63ae274403573" => :el_capitan
    sha256 "46be23893291889fa5d855f3e65438e8cb19e46a05f2392a2ea3c404b16b4391" => :x86_64_linux
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--root", prefix
  end

  test do
    (testpath/"justfile").write <<~EOS
      default:
        touch it-worked
    EOS
    system "#{bin}/just"
    assert_predicate testpath/"it-worked", :exist?
  end
end

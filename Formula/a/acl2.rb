class Acl2 < Formula
  desc "Logic and programming language in which you can model computer systems"
  homepage "https://www.cs.utexas.edu/~moore/acl2/"
  url "https://github.com/acl2/acl2/archive/refs/tags/8.7.tar.gz"
  sha256 "d6013c22e190cbd702870d296b5370a068c14625bf7f9d305d2d87292b594d52"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 arm64_tahoe:   "5e71a151f1b20b4ac7ecc5e06c9e24230b3d56a8c9ac7c3e18772a489cdbac0f"
    sha256 arm64_sequoia: "47224d8da3c28dfcde6365d5567678d15191e810f893aadcab8b35e014be63e3"
    sha256 arm64_sonoma:  "90d2c2a503799b06c858978ba982846fd533b74fe527cc5e90a16b21ac0fd0d0"
    sha256 sonoma:        "09ae0bfbc2cfee944326ccf5428ec11b3ac62cac5b6ddd93cbc808fdb042d63b"
    sha256 x86_64_linux:  "3d77079ea4ceeb15a54b560b55270b7760fdab18317bd06a87dacae099254f0d"
  end

  on_macos do
    depends_on "sbcl"
  end

  on_linux do
    # FP overflow trap isn't behaving as expected on GitHub runner so using `gcl` instead.
    # https://github.com/acl2/acl2/issues/1616#issuecomment-3448760740
    # https://github.com/jimwhite/acl2-jupyter/commit/6c062e8c5c02f996476c461fa18e464bf7c6ceea
    on_arm do
      depends_on "gcl" => :build
      depends_on "gmp"
      depends_on "libtirpc"
    end
    on_intel do
      depends_on "sbcl"
    end
  end

  def install
    # Remove prebuilt binaries
    rm_r buildpath.glob("books/kestrel/axe/*/{examples,tests}")

    # Move files and then build to avoid saving build directory in files
    libexec.install Dir["*"]

    variants = ["acl2"]
    lisp = if OS.linux? && Hardware::CPU.arm?
      ENV["GCL_ANSI"] = "1"
      ENV.remove "PATH", Superenv.shims_path # gcl saves compiler path in binary
      "gcl"
    else
      variants << "acl2p"
      "sbcl"
    end
    args = ["LISP=#{Formula[lisp].opt_bin/lisp}", "USE_QUICKLISP=0", "ACL2_MAKE_LOG=NONE"]

    variants.each do |acl2|
      extra_args = ["ACL2_PAR=p"] if acl2 == "acl2p"
      system "make", "-C", libexec, "all", "basic", *args, *extra_args
      inreplace libexec/"saved_#{acl2}", Formula[lisp].prefix.realpath, Formula[lisp].opt_prefix if lisp == "sbcl"
      (bin/acl2).write_env_script libexec/"saved_#{acl2}", ACL2_SYSTEM_BOOKS: "#{libexec}/books"
    end
  end

  test do
    (testpath/"simple.lisp").write "(+ 2 2)"
    output = shell_output("#{bin}/acl2 < #{testpath}/simple.lisp | grep 'ACL2 !>'")
    assert_equal "ACL2 !>4\nACL2 !>Bye.", output.strip
  end
end

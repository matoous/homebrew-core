class LovableOj < Formula
  desc "Experimental next generation frontend tooling"
  homepage "https://github.com/lovablelabs/oj"
  url "https://github.com/lovablelabs/oj/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "9b2cb6d53da1f9ae1a3565f2b773e2bcc87df9c400924ed81b19ccef884593ea"
  license "MIT"
  head "https://github.com/lovablelabs/oj.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c8de9c1b5f0b459938d7f3f52216da4bc8f973d2058b99754dad2318992df270"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3fb9b877433d1105786444e23af4f1497cbc3ec5f41966994ad606ab42728538"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "286174381aec2910e20229228b81b0372f88566b9d809d76fd054e4f5d45dc16"
    sha256 cellar: :any,                 arm64_linux:       "d62c4cd8dc78d097c28ad81e44dc5842ce391bafe457f004e217501cc6b94156"
    sha256 cellar: :any,                 x86_64_linux:      "42f78b0c0aa93f08c4109478519b816147eb72be9eb4167c94b598e7b9cc200c"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build # for libclang

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # `v8` crate downloads binaries at build-time
  allow_network_access! :build

  def install
    ENV["LIBCLANG_PATH"] = formula_opt_lib("llvm") if OS.linux?

    system "cargo", "install", *std_cargo_args(path: "crates/oj")
  end

  test do
    (testpath/"index.html").write <<~HTML
      <!doctype html>
      <div id="app"></div>
      <script type="module" src="/src/main.js"></script>
    HTML
    (testpath/"src/main.js").write <<~JS
      document.getElementById("app").textContent = "hello " + "oj";
    JS

    assert_match version.to_s, shell_output("#{bin}/oj --version")
    system bin/"oj", "build"
    assert_match "hello oj", (testpath/"dist/assets").glob("*.js").map(&:read).join
  end
end

class Mitos < Formula
  desc "Fast and minimal modal text editor"
  homepage "https://mitos.computer"
  url "https://github.com/mitos-editor/mitos/releases/download/v0.1.2/mitos-v0.1.2-source.tar.xz"
  sha256 "1fa019dbbd298edeb790e3033f7cc1d3b8b431ef3d866406b919cdc6b4bf031f"
  license "MPL-2.0"
  head "https://github.com/mitos-editor/mitos.git", branch: "main"

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
    system "cargo", "run", "--locked", "--package", "grammar-build", "--bin", "grammar-fetch" if build.head?
  end

  def install
    # Release archives bundle grammar sources; compile them without fetching again.
    ENV["MITOS_DISABLE_AUTO_GRAMMAR_BUILD"] = "1"
    ENV["CARGO_MANIFEST_DIR"] = buildpath/"crates/term"

    system "cargo", "install", *std_cargo_args(path: "crates/term")
    system bin/"ms", "--grammar", "build", "--strict"
    rm_r "runtime/grammars/sources"
    libexec.install "runtime"
    bin.env_script_all_files libexec/"bin", MITOS_RUNTIME: "${MITOS_RUNTIME:-#{libexec}/runtime}"

    bash_completion.install "contrib/completion/ms.bash" => "ms"
    fish_completion.install "contrib/completion/ms.fish"
    zsh_completion.install "contrib/completion/ms.zsh" => "_ms"
  end

  test do
    assert_match "Mitos terminal application", shell_output("#{bin}/ms --help")
    health = shell_output("#{bin}/ms --health rust")
    assert_match(/Tree-sitter parser:.*✓/, health)
    assert_match(/Highlight queries:.*✓/, health)
  end
end

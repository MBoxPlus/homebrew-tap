class Mbox < Formula
  VERSION = "1.1.7".freeze
  REPO = "MBoxPlus/mbox".freeze

  version VERSION
  desc "Missing toolchain for mobile development"
  homepage "https://github.com/#{REPO}"
  url "https://github.com/#{REPO}/releases/download/v#{VERSION}/mbox-#{VERSION}.tar.gz"
  sha256 "ed15f89795dc9ac9062fd65a195c2c8f54e4a7d8a8de4ddc3b5ed065252928fe"
  license "GPL-2.0-only"

  def install
    cp_r ".", libexec, preserve: true
    bin.install_symlink libexec/"MBoxCore/MBoxCLI" => "mbox"
    bin.install_symlink libexec/"MBoxCore/MDevCLI" => "mdev"

    # Prevent formula installer from changing dylib id.
    # The dylib id of our frameworks is just like "@rpath/xxx/xxx" and is NOT expected to absolute path.
    Dir[libexec/"*/*.framework"].each do |framework|
      system "tar",
             "-czf",
             "#{framework}.tar.gz",
             "-C",
             File.dirname(framework),
             File.basename(framework)
      rm_rf framework
    end
  end

  def post_install
    Dir[libexec/"*/*.framework.tar.gz"].each do |pkg|
      system "tar", "-zxf", pkg, "-C", File.dirname(pkg)
      rm_rf pkg
    end
  end

  def caveats
    s = <<~EOS
      Use 'mbox --help' or 'mbox [command] --help' to display help information about the command.
    EOS
    s += "MBox only supports macOS version ≥ 15.0 (Catalina)" if MacOS.version < :catalina
    s
  end

  test do
    assert_match "CLI Core Version", shell_output("mbox --version --no-launcher").strip
  end
end

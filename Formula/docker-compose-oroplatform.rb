require 'formula'

class DockerComposeOroplatform < Formula
  url "https://github.com/digitalspacestdio/homebrew-docker-compose-oroplatform.git", :using => :git
  version "0.3.2"
  revision 3

  depends_on 'coreutils'
  depends_on 'rsync'
  depends_on 'mutagen-io/mutagen/mutagen'

  def install
    #bin.install "docker-compose-oroplatform"
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"docker-compose-oroplatform"
  end

  def caveats
    s = <<~EOS
      docker-compose-oroplatform was installed
    EOS
    s
  end
end

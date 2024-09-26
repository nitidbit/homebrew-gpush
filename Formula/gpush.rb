class Gpush < Formula
  desc "Run linters and tests locally before pushing to a remote git repository"
  homepage "https://github.com/nitidbit/gpush"
  url "https://github.com/nitidbit/gpush/archive/refs/tags/2.0.0.tar.gz"
  sha256 "18f6530ecdf235121dfecdec79421997c6bdf574b7f70c3c99013a1328ea86cd"
  license "MIT"

  EXECUTABLES = [
    "gpush_changed_files.rb",
    "gpush_get_specs.rb",
    "gpush_run_if_any.rb",
    "gpush.rb",
  ].freeze

  OTHER_FILES = [
    "gpushrc_default.yml",
  ].freeze

  def install
    # Logging the start of the installation process
    ohai "Starting installation of gpush"

    # Ensure libexec directory exists
    libexec.mkpath

    # Copy all Ruby scripts (*.rb) to the libexec directory
    ohai "Copying all Ruby scripts to the libexec directory"
    Dir.glob("src/ruby/*.rb").each do |file|
      libexec.install file
    end

    OTHER_FILES.each do |file|
      libexec.install file
    end

    # Set execute permissions on the command files only
    ohai "Making command files executable"
    EXECUTABLES.each do |file|
      chmod "+x", libexec/file

      # Create wrapper scripts for each command file
      bin_name = File.basename(file, ".rb") # Get the name without the .rb extension
      (bin/bin_name).write <<~EOS
        #!/bin/bash
        exec ruby "#{libexec}/#{file}" "$@"
      EOS
      chmod "+x", bin/bin_name
    end

    # Confirming the installation
    ohai "gpush installation completed"
  end

  test do
    system bin/"gpush", "--version"
  end
end

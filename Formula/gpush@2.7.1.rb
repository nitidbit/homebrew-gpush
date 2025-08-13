class GpushAt271 < Formula
  MINIMUM_RUBY_VERSION = '3.1'.freeze

  desc 'Run linters and tests locally before pushing to a remote git repository'
  homepage 'https://github.com/nitidbit/gpush'
  url "https://github.com/nitidbit/gpush/archive/refs/tags/v2.7.1.tar.gz"
  sha256 "ac01f6d73e26cf4ff3198fd19cf19bd9b99919e247c23b78b7eb9390016bfc09"
  license 'MIT'

  depends_on 'ruby' => ">= #{MINIMUM_RUBY_VERSION}"
  depends_on 'terminal-notifier' => :recommended

  EXECUTABLES = [
    'gpush_changed_files.rb',
    'gpush_get_specs.rb',
    'gpush.rb'
  ].freeze

  OTHER_FILES = [
    'gpushrc_default.yml'
  ].freeze

  def install
    # Logging the start of the installation process
    ohai "Starting installation of gpush version #{version}"

    # Ensure libexec directory exists
    libexec.mkpath

    # Copy all Ruby scripts (*.rb) to the libexec directory
    ohai 'Copying all Ruby scripts to the libexec directory'
    Dir.glob('src/ruby/*.rb').each do |file|
      libexec.install file
    end

    OTHER_FILES.each do |file|
      libexec.install file
    end

    # Set execute permissions on the command files only
    ohai 'Making command files executable'
    EXECUTABLES.each do |file|
      chmod '+x', libexec / file

      # Create wrapper scripts for each command file
      bin_name = File.basename(file, '.rb') # Get the name without the .rb extension
      (bin / bin_name).write <<~BASH_SCRIPT
        #!/bin/bash

        # Use the Ruby installed by Homebrew
        GPUSH_VERSION="#{version}" #{Formula['ruby'].opt_bin}/ruby "#{libexec}/#{file}" "$@"
      BASH_SCRIPT
      chmod '+x', bin / bin_name
    end

    # Confirming the installation
    ohai 'gpush installation completed'
  end

  test do
    system bin / 'gpush', '--version'
    assert_match 'Usage', shell_output("#{bin}/gpush --help")
  end
end

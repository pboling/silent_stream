# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "silent_stream/version"

Gem::Specification.new do |spec|
  authors = [
    # Everyone who touched the files extracted from Rails:
    ["jeremy", "Jeremy Daer"],
    ["dhh", "David Heinemeier Hansson"],
    ["pixeltrix", "Andrew White"],
    ["spastorino", "Santiago Pastorino"],
    ["sstephenson", "Sam Stephenson"],
    ["amatsuda", "Akira Matsuda"],
    ["Raphomet", "Raphael Lee"],
    ["rafaelfranca", "Rafael França"],
    ["mariovisic", "Mario Visic"],
    ["krekoten", "Мар'ян Крекотень"],
    ["lest", "Sergey Nartimov"],
    ["joshk", "Josh Kalderimis"],
    ["fxn", "Xavier Noria"],
    ["deivid-rodriguez", "David Rodríguez"],
    ["route", "Dmitry Vorotilin"],
    ["tenderlove", "Aaron Patterson"],
    ["guilleiguaran", "Guillermo Iguaran"],
    ["gazay", "Alexey Gaziev"],
    ["wycats", "Yehuda Katz"],
    ["tommeier", "Tom Meier"],
    ["lifo", "Pratik Naik"],
    ["charliesome", "Charlie Somerville"],
    ["atambo", "Alex Tambellini"],
    ["arthurnn", "Arthur Nogueira Neves"],
    ["anildigital", "Anil Wadghule"],
    # Author/Maintainer of this gem:
    ["pboling", "Peter Boling"],
  ]

  spec.name = "silent_stream"
  spec.version = SilentStream::VERSION
  spec.authors = authors.map { |_gh, name| name }
  spec.email = ["peter.boling@gmail.com"]

  # Linux distros may package ruby gems differently,
  #   and securely certify them independently via alternate package management systems.
  # Ref: https://gitlab.com/oauth-xx/version_gem/-/issues/3
  # Hence, only enable signing if `SKIP_GEM_SIGNING` is not set in ENV.
  # See CONTRIBUTING.md
  user_cert = "certs/#{ENV.fetch("GEM_CERT_USER", ENV["USER"])}.pem"
  cert_file_path = File.join(__dir__, user_cert)
  cert_chain = cert_file_path.split(",")
  cert_chain.select! { |fp| File.exist?(fp) }
  if cert_file_path && cert_chain.any?
    spec.cert_chain = cert_chain
    if $PROGRAM_NAME.end_with?("gem") && ARGV[0] == "build" && !ENV.include?("SKIP_GEM_SIGNING")
      spec.signing_key = File.join(Gem.user_home, ".ssh", "gem-private_key.pem")
    end
  end

  spec.summary = "ActiveSupport's Stream Silencing - Without ActiveSupport"
  spec.description = "ActiveSupport Kernel Reporting Detritus with a few enhancements"
  spec.homepage = "https://github.com/pboling/#{spec.name}"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["wiki_uri"] = "#{spec.homepage}/wiki"
  spec.metadata["funding_uri"] = "https://liberapay.com/pboling"
  spec.metadata["news_uri"] = "https://www.railsbling.com/tags/#{spec.name}"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir[
    # Splats (alphabetical)
    "lib/**/*.rb",
  ]
  # Automatically included with gem package, no need to list again in files.
  spec.extra_rdoc_files = Dir[
    # Files (alphabetical)
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md",
  ]
  spec.rdoc_options += [
    "--title",
    "#{spec.name} - #{spec.summary}",
    "--main",
    "README.md",
    "--line-numbers",
    "--inline-source",
    "--quiet",
  ]
  spec.require_paths = ["lib"]
  spec.bindir = "exe"
  spec.executables = []

  # tempfile is still a standard library gem, and the released versions only support back to Ruby 2.5
  # spec.add_dependency("tempfile", "~> 0.3.1")
  spec.add_dependency("logger", ">= 1.4.4") # Ruby >= 2.3, newer minor versions require Ruby >= 2.5

  # Utilities
  spec.add_dependency("version_gem", "~> 1.1", ">= 1.1.7")

  # Development dependencies
  spec.add_development_dependency("minitest", ">= 5.15")                # ruby >= 2.2, later releases are ruby >= 2.6+
  spec.add_development_dependency("minitest-reporters")
  spec.add_development_dependency("mocha")
  spec.add_development_dependency("rake", "~> 13.0")                    # ruby >= 2.2
  spec.add_development_dependency("ruby_engine", "~> 2.0")
  spec.add_development_dependency("ruby_version", "~> 1.0")
  spec.add_development_dependency("stone_checksums", "~> 1.0")          # ruby >= 2.2
  spec.add_development_dependency("test-unit", ">= 3.2")
  # Linting - rubocop-lts v10 is a rubocop wrapper for Ruby >= 2.3,
  #   and should only be bumped when dropping old Ruby support
  # NOTE: it can only be installed on, and run on Ruby >= 2.7, so we add the dependency in the Gemfile.
  # see: https://rubocop-lts.gitlab.io
  # spec.add_development_dependency 'rubocop-lts', ['~> 10.0']
end

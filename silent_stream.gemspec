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
  spec.required_ruby_version = ">= 2.3"

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
    "lib/**/*.rb",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE",
    "README.md",
    "SECURITY.md"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "MIT"

  # tempfile is still a standard library gem, and the released versions only support back to Ruby 2.5
  # spec.add_dependency("tempfile", "~> 0.3.1")
  spec.add_dependency("logger", ">= 1.4.4") # Ruby >= 2.3, newer minor versions require Ruby >= 2.5

  # Development dependencies
  spec.add_development_dependency("appraisal")
  spec.add_development_dependency("bundler")
  spec.add_development_dependency("minitest", ">= 5.22")
  spec.add_development_dependency("minitest-reporters")
  spec.add_development_dependency("mocha")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("simplecov", ">= 0.16")
  spec.add_development_dependency("test-unit", ">= 3.2")
  spec.add_development_dependency("wwtd")

  # Linting
  spec.add_development_dependency("rubocop-gradual", ">= 0.3.4")
  spec.add_development_dependency("rubocop-lts", "~> 10.1", ">= 10.1.1") # Lint & Style Support for Ruby 2.3+
  spec.add_development_dependency("rubocop-rspec", "~> 2.26", ">= 2.26.1")
  spec.add_development_dependency("standard", "~> 1.33")
end

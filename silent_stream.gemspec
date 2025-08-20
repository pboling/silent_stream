# frozen_string_literal: true

gem_version =
  if RUBY_VERSION >= "3.1" # rubocop:disable Gemspec/RubyVersionGlobalsUsage
    # Loading version into an anonymous module allows version.rb to get code coverage from SimpleCov!
    # See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-2630782358
    Module.new.tap { |mod| Kernel.load("lib/silent_stream/version.rb", mod) }::SilentStream::Version::VERSION
  else
    # TODO: Remove this hack once support for Ruby 3.0 and below is removed
    Kernel.load("lib/silent_stream/version.rb")
    g_ver = SilentStream::Version::VERSION
    SilentStream::Version.send(:remove_const, :VERSION)
    g_ver
  end

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
  spec.version = gem_version
  spec.authors = authors.map { |_gh, name| name }
  spec.email = ["floss@galtzo.com"]

  # Linux distros often package gems and securely certify them independent
  #   of the official RubyGem certification process. Allowed via ENV["SKIP_GEM_SIGNING"]
  # Ref: https://gitlab.com/oauth-xx/version_gem/-/issues/3
  # Hence, only enable signing if `SKIP_GEM_SIGNING` is not set in ENV.
  # See CONTRIBUTING.md
  unless ENV.include?("SKIP_GEM_SIGNING")
    user_cert = "certs/#{ENV.fetch("GEM_CERT_USER", ENV["USER"])}.pem"
    cert_file_path = File.join(__dir__, user_cert)
    cert_chain = cert_file_path.split(",")
    cert_chain.select! { |fp| File.exist?(fp) }
    if cert_file_path && cert_chain.any?
      spec.cert_chain = cert_chain
      if $PROGRAM_NAME.end_with?("gem") && ARGV[0] == "build"
        spec.signing_key = File.join(Gem.user_home, ".ssh", "gem-private_key.pem")
      end
    end
  end

  spec.summary = "🔕 (formerly) ActiveSupport's Stream Silencing - Without ActiveSupport"
  spec.description = "🔕 (formerly) ActiveSupport Kernel Reporting Detritus with a few enhancements"
  spec.homepage = "https://github.com/pboling/#{spec.name}"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3"

  spec.metadata["homepage_uri"] = "https://#{spec.name.tr("_", "-")}.galtzo.com/"
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["funding_uri"] = "https://github.com/sponsors/pboling"
  spec.metadata["wiki_uri"] = "#{spec.homepage}/wiki"
  spec.metadata["news_uri"] = "https://www.railsbling.com/tags/#{spec.name}"
  spec.metadata["discord_uri"] = "https://discord.gg/3qme4XHNKN"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files are part of each release.
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
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md",
    "--line-numbers",
    "--inline-source",
    "--quiet",
  ]
  spec.require_paths = ["lib"]
  spec.bindir = "exe"
  spec.executables = []

  # tempfile is still a standard library gem, and the released versions only support back to Ruby 2.5
  # spec.add_dependency("tempfile", "~> 0.3.1")
  #
  # spec.add_dependency("logger", ">= 1.4.4")             # Ruby >= 2.3, newer minor versions require Ruby >= 2.5
  spec.add_dependency("logger", "~> 1.2")                 # Ruby >= 0, some newer minor versions require Ruby >= 2.5

  # Utilities
  spec.add_dependency("version_gem", ">= 1.1.8", "< 3")   # Ruby >= 2.2

  # NOTE: It is preferable to list development dependencies in the gemspec due to increased
  #       visibility and discoverability on RubyGems.org.
  #       However, development dependencies in gemspec will install on
  #       all versions of Ruby that will run in CI.
  #       This gem, and its runtime dependencies, will install on Ruby down to 2.3.x.
  #       This gem, and its development dependencies, will install on Ruby down to 2.3.x.
  #       This is because in CI easy installation of Ruby, via setup-ruby, is for >= 2.3.
  #       Thus, dev dependencies in gemspec must have
  #
  #       required_ruby_version ">= 2.3" (or lower)
  #
  #       Development dependencies that require strictly newer Ruby versions should be in a "gemfile",
  #       and preferably a modular one (see gemfiles/modular/*.gemfile).

  # Development dependencies
  spec.add_development_dependency("appraisal2", "~> 3.0")                     # ruby >= 1.8.7
  spec.add_development_dependency("minitest", ">= 5.15")                      # ruby >= 2.2, later releases are ruby >= 2.6+
  spec.add_development_dependency("minitest-reporters", "~> 1.7", ">= 1.7.1") # ruby >= 1.9.3
  spec.add_development_dependency("mocha", "~> 2.7", ">= 2.7.1")              # ruby >= 2.1
  spec.add_development_dependency("rake", "~> 13.0")                          # ruby >= 2.2
  spec.add_development_dependency("ruby_engine", "~> 2.0", ">= 2.0.3")        # ruby >= 0
  spec.add_development_dependency("ruby_version", "~> 1.0", ">= 1.0.3")       # ruby >= 0
  spec.add_development_dependency("stone_checksums", "~> 1.0")                # ruby >= 2.2
  spec.add_development_dependency("test-unit", ">= 3.7")                      # ruby >= 0
  # Linting - rubocop-lts v10 is a rubocop wrapper for Ruby >= 2.3,
  #   and should only be bumped when dropping old Ruby support
  # NOTE: it can only be installed on, and run on Ruby >= 2.7, so we add the dependency in the Gemfile.
  # see: https://rubocop-lts.gitlab.io
  # spec.add_development_dependency 'rubocop-lts', ['~> 10.0']
end

# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silent_stream/version'

Gem::Specification.new do |spec|
  authors = [
    # Everyone who touched the files extracted from Rails:
    ['jeremy',            'Jeremy Daer'],
    ['dhh',               'David Heinemeier Hansson'],
    ['pixeltrix',         'Andrew White'],
    ['spastorino',        'Santiago Pastorino'],
    ['sstephenson',       'Sam Stephenson'],
    ['amatsuda',          'Akira Matsuda'],
    ['Raphomet',          'Raphael Lee'],
    ['rafaelfranca',      'Rafael França'],
    ['mariovisic',        'Mario Visic'],
    ['krekoten',          "Мар'ян Крекотень"],
    ['lest',              'Sergey Nartimov'],
    ['joshk',             'Josh Kalderimis'],
    ['fxn',               'Xavier Noria'],
    ['deivid-rodriguez',  'David Rodríguez'],
    ['route',             'Dmitry Vorotilin'],
    ['tenderlove',        'Aaron Patterson'],
    ['guilleiguaran',     'Guillermo Iguaran'],
    ['gazay',             'Alexey Gaziev'],
    ['wycats',            'Yehuda Katz'],
    ['tommeier',          'Tom Meier'],
    ['lifo',              'Pratik Naik'],
    ['charliesome',       'Charlie Somerville'],
    ['atambo',            'Alex Tambellini'],
    ['arthurnn',          'Arthur Nogueira Neves'],
    ['anildigital',       'Anil Wadghule'],
    # Author/Maintainer of this gem:
    ['pboling',           'Peter Boling']
  ]

  spec.name          = 'silent_stream'
  spec.version       = SilentStream::VERSION
  spec.authors       = authors.map { |_gh, name| name }
  spec.email         = ['peter.boling@gmail.com']

  spec.summary       = "ActiveSupport's Stream Silencing - Without ActiveSupport"
  spec.description   = 'ActiveSupport Kernel Reporting Detritus with a few enhancements'
  spec.homepage      = 'https://github.com/pboling/silent_stream'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(tests|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.license       = 'MIT'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '>= 5.10'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov', '>= 0.16'
  spec.add_development_dependency 'test-unit', '>= 3.2'
  spec.add_development_dependency 'wwtd'
end

# Changelog

Starting with v1.0.9, All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [1.0.11] - 2025-05-16
- COVERAGE:  88.06% -- 59/67 lines in 2 files
- BRANCH COVERAGE:  30.00% -- 3/10 branches in 2 files
- 50.00% documented
### Changed
- Reduced minimum version of logger dependency to 1.2
  - To help with testing old libraries, or newer libraries that still support old libraries
### Fixed
- Code Coverage setup in CI

## [1.0.10] - 2025-05-05
- COVERAGE:  47.76% -- 32/67 lines in 2 files
- BRANCH COVERAGE:  10.00% -- 1/10 branches in 2 files
- 50.00% documented
### Changed
- SilentStream::Version => SilentStream::Version::VERSION
  - Allows test coverage to be tracked for version.rb

## [1.0.9] - 2025-05-05
- COVERAGE:  40.62% -- 26/64 lines in 2 files
- BRANCH COVERAGE:  10.00% -- 1/10 branches in 2 files
- 54.55% documented
### Added
- Releases will be signed by my key that expires 2045-04-29
- Allow unsigned gem builds (for linux distros)
  - In the ENV set `SKIP_GEM_SIGNING` to any value
- Compatibility with Ruby 3.5
  - Make `logger` a direct dependency, since it is removed from stdlib in Ruby 3.5
- Expanded CI test matrix to include JRuby, TruffleRuby, and MRI 2.3+, including heads

## [1.0.8] - 2024-03-20

## [1.0.7] - 2024-03-20

## [1.0.6] - 2020-02-25

## [1.0.5] - 2018-10-10

## [1.0.4] - 2018-10-06

## [1.0.3] - 2018-09-25

## [1.0.2] - 2018-09-25

## [1.0.1] - 2018-09-23

## [1.0.0] - 2018-09-23

[Unreleased]: https://gitlab.com/pboling/silent_stream/-/compare/v1.0.10...HEAD
[1.0.10]: https://gitlab.com/pboling/silent_stream/-/compare/v1.0.9...v1.0.10
[1.0.9]: https://gitlab.com/pboling/silent_stream/-/compare/v1.0.8...v1.0.9
[1.0.8]: https://gitlab.com/pboling/silent_stream/-/compare/v1.0.7...v1.0.8
[1.0.7]: https://gitlab.com/pboling/silent_stream/-/compare/v1.0.5...v1.0.7
[1.0.6]: https://rubygems.org/gems/silent_stream/versions/1.0.6
[1.0.5]: https://gitlab.com/pboling/silent_stream/-/tags/v1.0.5
[1.0.4]: https://rubygems.org/gems/silent_stream/versions/1.0.4
[1.0.3]: https://rubygems.org/gems/silent_stream/versions/1.0.3
[1.0.2]: https://rubygems.org/gems/silent_stream/versions/1.0.2
[1.0.1]: https://rubygems.org/gems/silent_stream/versions/1.0.1
[1.0.0]: https://rubygems.org/gems/silent_stream/versions/1.0.0

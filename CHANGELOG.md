# Changelog

Starting with v1.0.9, All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0.12] - 2025-08-21
- TAG: [v1.0.12][1.0.12t]
- COVERAGE: 100.00% -- 80/80 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 21/21 branches in 2 files
- 50.00% documented
### Added
- RBS types
- More YARD documentation
- Published docs site: [silent-stream.galtzo.com](https://silent-stream.galtzo.com)
- Complete test coverage for lines and branches at 100%
### Fixed
-  TypeError: can't convert Tempfile into StringIO

## [1.0.11] - 2025-05-16
- TAG: [v1.0.11][1.0.11t]
- COVERAGE: 88.06% -- 59/67 lines in 2 files
- BRANCH COVERAGE: 30.00% -- 3/10 branches in 2 files
- 50.00% documented
### Changed
- Reduced minimum version of logger dependency to 1.2
  - To help with testing old libraries, or newer libraries that still support old libraries
### Fixed
- Code Coverage setup in CI

## [1.0.10] - 2025-05-05
- TAG: [v1.0.10][1.0.10t]
- COVERAGE:  47.76% -- 32/67 lines in 2 files
- BRANCH COVERAGE:  10.00% -- 1/10 branches in 2 files
- 50.00% documented
### Changed
- SilentStream::Version => SilentStream::Version::VERSION
  - Allows test coverage to be tracked for version.rb

## [1.0.9] - 2025-05-05
- TAG: [v1.0.9][1.0.9t]
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
- TAG: [v1.0.8][1.0.8t]

## [1.0.7] - 2024-03-20
- TAG: [v1.0.7][1.0.7t]

## [1.0.6] - 2020-02-25
- TAG: [v1.0.6][1.0.6t]

## [1.0.5] - 2018-10-10
- TAG: [v1.0.5][1.0.5t]

## [1.0.4] - 2018-10-06
- TAG: [v1.0.4][1.0.4t]

## [1.0.3] - 2018-09-25
- TAG: [v1.0.3][1.0.3t]

## [1.0.2] - 2018-09-25
- TAG: [v1.0.2][1.0.2t]

## [1.0.1] - 2018-09-23
- TAG: [v1.0.1][1.0.1t]

## [1.0.0] - 2018-09-23
- TAG: [v1.0.0][1.0.0t]

[Unreleased]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.12...HEAD
[1.0.12]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.11...v1.0.12
[1.0.12t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.12
[1.0.11]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.10...v1.0.11
[1.0.11t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.11
[1.0.10]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.9...v1.0.10
[1.0.10t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.10
[1.0.9]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.8...v1.0.9
[1.0.9t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.9
[1.0.8]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.7...v1.0.8
[1.0.8t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.8
[1.0.7]: https://gitlab.com/galtzo-floss/silent_stream-/compare/v1.0.5...v1.0.7
[1.0.7t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.7
[1.0.6]: https://rubygems.org/gems/silent_stream/versions/1.0.6
[1.0.6t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.6
[1.0.5]: https://gitlab.com/galtzo-floss/silent_stream-/tags/v1.0.5
[1.0.5t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.5
[1.0.4]: https://rubygems.org/gems/silent_stream/versions/1.0.4
[1.0.4t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.4
[1.0.3]: https://rubygems.org/gems/silent_stream/versions/1.0.3
[1.0.3t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.3
[1.0.2]: https://rubygems.org/gems/silent_stream/versions/1.0.2
[1.0.2t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.2
[1.0.1]: https://rubygems.org/gems/silent_stream/versions/1.0.1
[1.0.1t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.1
[1.0.0]: https://rubygems.org/gems/silent_stream/versions/1.0.0
[1.0.0t]: https://gitlab.com/galtzo-floss/timecop-rspec/-/tags/v1.0.0

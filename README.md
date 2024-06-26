# SilentStream

SilentStream is an extraction of some parts of ActiveSupport's Kernel Reporting Core Extentions around silencing IO streams.

Since July 2014 `silence_stream`, `silence_stderr`, `capture`, `silence`, and `quietly` have been deprecated because they are not thread safe.  See that discussion in the [PR where it all went down](https://github.com/rails/rails/pull/13392). I rely on them a lot in *single threaded* code, and so I plan to keep them alive.  With the exception of `silence`, which was just an alias of `capture`.

This gem was taken out of Rails but it is *not* Rails dependent.  The extraction was total (**even the tests**!), and this is now a pure Ruby library, which can be used in any Ruby project without encumbrances.  *This gem has no runtime dependencies*.

| Project                | SilentStream                                                                                                                                                                                      |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| gem name               | [silent_stream](https://rubygems.org/gems/silent_stream)                                                                                                                                          |
| compatibility          | Ruby 2.3, 2.4, 2.5, 2.6, 2.7, 3.0, 3.1, 3.2, 3.3                                                                                                                                                  |
| license                | [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)                                                                                        |
| download rank          | [![Downloads Today](https://img.shields.io/gem/rd/silent_stream.svg)](https://github.com/pboling/silent_stream)                                                                                   |
| version                | [![Version](https://img.shields.io/gem/v/silent_stream.svg)](https://rubygems.org/gems/silent_stream)                                                                                             |
| continuous integration | [![Build Status](https://travis-ci.org/pboling/silent_stream.svg?branch=master)](https://travis-ci.org/pboling/silent_stream)                                                                     |
| test coverage          | [![Test Coverage](https://api.codeclimate.com/v1/badges/ced7e39984dd9c27c528/test_coverage)](https://codeclimate.com/github/pboling/silent_stream/test_coverage)                                  |
| maintainability        | [![Maintainability](https://api.codeclimate.com/v1/badges/ced7e39984dd9c27c528/maintainability)](https://codeclimate.com/github/pboling/silent_stream/maintainability)                            |
| dependencies           | [![Depfu](https://badges.depfu.com/badges/6633827ecc1ad3b5dd749b4ac822347b/count.svg)](https://depfu.com/github/pboling/silent_stream?project_id=5828)                                            |
| code triage            | [![Open Source Helpers](https://www.codetriage.com/pboling/silent_stream/badges/users.svg)](https://www.codetriage.com/pboling/silent_stream)                                                     |
| homepage               | [on Github.com][homepage], [on Railsbling.com][blogpage]                                                                                                                                          |
| documentation          | [on RDoc.info][documentation]                                                                                                                                                                     |
| Spread ~♡ⓛⓞⓥⓔ♡~        | [🌏](https://about.me/peter.boling), [👼](https://angel.co/peter-boling), [![Tweet Peter](https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow)](http://twitter.com/galtzo) |


## NOTE

One aspect of what this gem provides can be achieved with the Rails' built-in [`LoggerSilence`](https://github.com/rails/rails/blob/5-2-stable/activesupport/lib/active_support/logger_silence.rb), which is thread safe.  You will have to decide what is right for you!

## Doing a Rails <= 4 to Rails >= 5 Upgrade?

The reason for not keeping `silence` as it was in Rails 4, i.e. an alias of `capture`, is that the just mentioned `LoggerSilence` now uses this term, and it is shipping with Rails 5. I don't want to make this gem incompatible with Rails 5, so you will have to convert Rails <= 4 implementations that utilize `silence` over to `capture` when using this gem.  One further point of difference is this gem does not add the methods to `Kernel` or `Object`.  You can do that if you like via `include`.  By default this gem does not pollute anything, so you will need to `include SilentStream` in any class using these methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "silent_stream"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silent_stream

## Usage

Four standard methods you may be familiar with from ActiveSupport's previous implementation are provided:

```
silence_stderr
silence_stream
capture
quietly
```

They are direct replicas, *except* not mixed into `Kernel` or `Object`, so in order to use them you must mix them into your classes or modules.

```
class Bogosity
  include SilentStream::Extracted # allows use at instance level
  extend SilentStream::Extracted # allows use at class level
  # or
  include SilentStream # access everything, and add #silence_all method, see below
end
```

In addition there is a `silence_all` method that is a useful wrapper that can be easily instrumented (turned off and on) with an ENV variable switch.

Including the `SilentStream` namespace fully gives access to this enhanced method, as well as the extracted methods above, and also makes everything available at the class and instance levels.

```ruby
class Bogosity
  include SilentStream # allows use of any method at instance or class level

  def silent
    silence_all(true) do
      puts "play that funky music"
      Rails.logger.info("git jiggy with it")
    end
  end
  class << self
    def noise
      silence_all(false) do
        puts "play that funky music"
        Rails.logger.info("git jiggy with it")
      end
    end
  end
end
```

And run

```
>> Bogosity.new.silent # has no output
=> nil
>> Bogosity.noise # is noisy
play that funky music
=> nil
```

## Use in Specs / Tests

Make the methods avaialble:
```
RSpec.configure do |conf|
  conf.include(SilentStream)
end
```

Then add a test on output:
```
it "has output" do
  output = capture(:stdout) { subject.request(:get, "/success") }
  logs = [
    "INFO -- request: GET https://api.example.com/success",
    "INFO -- response: Status 200",
  ]
  expect(output).to(include(*logs))
end
```

See it in practice in the specs for the [oauth2 gem](https://github.com/oauth-xx/oauth2/blob/master/spec/oauth2/client_spec.rb#L193) and the [debug_logging gem](https://github.com/pboling/debug_logging/blob/master/spec/debug_logging/instance_logger_spec.rb#L10)

## Migrate from ActiveSupport::Testing::Stream, or remove ActiveSupport completely, in your ruby library!

For most scenarios, simple. Change three lines.  Here's an example from a gem I just converted from ActiveSupport to SilentStream ([see commit](https://github.com/pboling/debug_logging/commit/d0cd109e1509084bbcf753be39f2173f0e2878a7))

`gemspec` diff:
```
-spec.add_development_dependency 'activesupport', '>= 5'
+spec.add_development_dependency 'silent_stream', '>= 1'
```

`spec_helper.rb` diff:
```
-require 'active_support/testing/stream'
+require 'silent_stream'

RSpec.configure do |config|
-  config.include ActiveSupport::Testing::Stream
+  config.include SilentStream
```

Run spec suite to verify everything is good.  This gem is as close as can be to a drop-in replacement for Rails' `ActiveSupport::Testing::Stream`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pboling/silent_stream.

## Code of Conduct

Everyone interacting in the AnonymousActiveRecord project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pboling/silent_stream/blob/master/CODE_OF_CONDUCT.md).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver].
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("silent_stream", "~> 1.0")
```

## License

* Copyright (c) 2018, 2024 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

[license]: LICENSE
[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[documentation]: http://rdoc.info/github/pboling/silent_stream/frames
[homepage]: https://github.com/pboling/silent_stream/
[blogpage]: http://www.railsbling.com/tags/silent_stream/

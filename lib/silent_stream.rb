# frozen_string_literal: true

require 'silent_stream/version'

require 'tempfile'
require 'logger'

module SilentStream
  def self.included(base)
    base.send(:extend, Extracted)
    base.send(:include, Extracted)
    base.send(:extend, Enhanced)
    base.send(:include, Enhanced)
  end

  module Enhanced
    # param switch is true or false
    # By default it is true, when means we don't want logging.
    # Switching it to false enables logging again.
    # By default ERROR log level continues to be logged.
    # The return value is the return value of the block,
    #   so you can use it without changing code structure.
    #
    # This method is not thread-safe.
    def silence_all(switch = true, temporary_level = Logger::ERROR, logger = nil)
      if !switch || ENV['NO_SILENCE'] == 'true'
        yield
      else
        begin
          logger ||= defined?(Rails) ? Rails.logger : nil
          logger && (old_logger_level = logger.level || true) && (logger.level = temporary_level)
          # silence STDOUT (like puts)
          silence_stream(STDOUT) do
            yield
          end
        ensure
          logger && (logger.level = old_logger_level)
        end
      end
    end
  end

  # Extracted from:
  # https://github.com/rails/rails/blob/4-2-stable/activesupport/lib/active_support/core_ext/kernel/reporting.rb
  module Extracted
    # This method is not thread-safe.
    def silence_stderr
      silence_stream(STDERR) { yield }
    end

    # Silences any stream for the duration of the block.
    #
    #   silence_stream(STDOUT) do
    #     puts 'This will never be seen'
    #   end
    #
    #   puts 'But this will'
    #
    # This method is not thread-safe.
    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(windows_os_test ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
      old_stream.close
    end

    # Captures the given stream and returns it:
    #
    #   stream = capture(:stdout) { puts 'notice' }
    #   stream # => "notice\n"
    #
    #   stream = capture(:stderr) { warn 'error' }
    #   stream # => "error\n"
    #
    # even for subprocesses:
    #
    #   stream = capture(:stdout) { system('echo notice') }
    #   stream # => "notice\n"
    #
    #   stream = capture(:stderr) { system('echo error 1>&2') }
    #   stream # => "error\n"
    #
    # This method is not thread-safe.
    def capture(stream)
      stream = stream.to_s
      captured_stream = Tempfile.new(stream)
      stream_io = eval("$#{stream}")
      origin_stream = stream_io.dup
      stream_io.reopen(captured_stream)

      yield

      stream_io.rewind
      captured_stream.read
    ensure
      captured_stream.close
      captured_stream.unlink
      stream_io.reopen(origin_stream)
    end
    # silence is provided by the LoggerSilence concern that continues to be
    # shipped with Rails, so not continuing with this alias.
    # alias silence capture

    # Silences both STDOUT and STDERR, even for subprocesses.
    #
    #   quietly { system 'bundle install' }
    #
    # This method is not thread-safe.
    def quietly
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          yield
        end
      end
    end

    private

    WINDOWS_REGEXP = /mswin|mingw/
    REGEXP_HAS_MATCH = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.4')
    def windows_os_test
      # When available, in Ruby 2.4+, we use Regexp#match? which does not update
      #   the $~ global object and may be 3x faster than alternative match tests
      if REGEXP_HAS_MATCH
        WINDOWS_REGEXP.match?(RbConfig::CONFIG['host_os'])
      else
        WINDOWS_REGEXP =~ (RbConfig::CONFIG['host_os'])
      end
    end
  end
end

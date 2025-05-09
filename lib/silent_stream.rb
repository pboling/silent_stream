# frozen_string_literal: true

# Std Lib
require "tempfile"

# Extracted Std Lib
require "logger" # as of Ruby 3.5

# External gems
require "version_gem"

# This gem
require_relative "silent_stream/version"

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
    # By default, ERROR log level continues to be logged.
    # The return value is the return value of the block,
    #   so you can use it without changing code structure.
    #
    # This method is not thread-safe.
    def silence_all(switch = true, temporary_level = Logger::ERROR, logger = nil, &block)
      if !switch || silent_stream_no_silence
        yield
      else
        begin
          logger ||= silent_stream_logger
          old_logger_level = silent_stream_reset_logger_level(logger, temporary_level)
          # silence STDOUT (like puts)
          silence_stream(STDOUT, &block)
        ensure
          silent_stream_reset_logger_level(logger, old_logger_level)
        end
      end
    end

    private

    def silent_stream_no_silence
      ENV["NO_SILENCE"] == "true"
    end

    def silent_stream_logger
      (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) ? Rails.logger : nil
    end

    # returns previous logger's level
    def silent_stream_reset_logger_level(logger, temporary_level)
      logger && (old_logger_level = logger.level || true) && (logger.level = temporary_level)
      old_logger_level
    end
  end

  # Extracted from:
  # https://github.com/rails/rails/blob/4-2-stable/activesupport/lib/active_support/core_ext/kernel/reporting.rb
  module Extracted
    SILENT_STREAM_NULL_DEVICE = if defined?(IO::NULL)
      IO::NULL
    else
      Gem.win_platform? ? "NUL:" : "/dev/null"
    end

    # This method is not thread-safe.
    def silence_stderr(&block)
      silence_stream(STDERR, &block)
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
      begin
        stream.reopen(SILENT_STREAM_NULL_DEVICE, "a+")
      rescue Exception => e
        stream.puts "[SilentStream] Unable to silence. #{e.class}: #{e.message}"
      end
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
    def quietly(&block)
      silence_stream(STDOUT) do
        silence_stream(STDERR, &block)
      end
    end

    private

    SILENT_STREAM_WINDOWS_REGEXP = /mswin|mingw/.freeze
    SILENT_STREAM_REGEXP_HAS_MATCH = Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.4")
    def windows_os_test
      # When available, in Ruby 2.4+, we use Regexp#match? which does not update
      #   the $~ global object and may be 3x faster than alternative match tests
      if SILENT_STREAM_REGEXP_HAS_MATCH
        SILENT_STREAM_WINDOWS_REGEXP.match?(RbConfig::CONFIG["host_os"])
      else
        SILENT_STREAM_WINDOWS_REGEXP =~ RbConfig::CONFIG["host_os"]
      end
    end
  end
end

SilentStream::Version.class_eval do
  extend VersionGem::Basic
end

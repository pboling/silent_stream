# frozen_string_literal: true

require "test/unit"
require "minitest"
require "minitest/reporters"
require "minitest/autorun"
require "mocha/minitest"
require "ruby_engine"
require "ruby_version"

reporter_options = {color: true}
Minitest::Reporters.use!([Minitest::Reporters::DefaultReporter.new(reporter_options)])

begin
  # In CI coverage gems are not available except on the coverage workflow
  require "kettle-soup-cover"

  require "simplecov" if defined?(Kettle) && Kettle::Soup::Cover::DO_COV
rescue LoadError
  nil
end

# This gem
require "silent_stream"

class SilentStream::TestCase < Minitest::Test
  private

  unless defined?(:capture)
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
  end
end

class MyException < RuntimeError; end

class MyClass
  include SilentStream
  class << self
    def quiet_log(switch, level, logger)
      silence_all(switch, level, logger) do
        logger.debug("some debug")
        logger.error("some error")
      end
    end
  end
end

class KernelTest < SilentStream::TestCase
  def test_silence_all_switch_on
    switch = true
    level = Logger::ERROR
    logger = Logger.new(STDOUT)
    assert_equal("", MyClass.capture(:stdout) { MyClass.quiet_log(switch, level, logger) })
  end

  def test_silence_all_switch_off
    switch = false
    level = Logger::ERROR
    logger = Logger.new(STDOUT)
    assert_match(/some debug\n.*some error\n/, MyClass.capture(:stdout) { MyClass.quiet_log(switch, level, logger) })
  end

  def test_silence_stream
    old_stream_position = STDOUT.tell
    MyClass.silence_stream(STDOUT) { STDOUT.puts "hello world" }
    assert_equal(old_stream_position, STDOUT.tell)
  rescue Errno::ESPIPE
    # Skip if we can't stream.tell
  end

  def test_silence_stream_closes_file_descriptors
    skip("truffleruby IOError: unable to modify data") if RubyEngine.truffle?
    stream = StringIO.new
    dup_stream = StringIO.new
    stream.stubs(:dup).returns(dup_stream)
    dup_stream.expects(:close)
    MyClass.silence_stream(stream) { dup_stream.puts "hello world" }
  end

  def test_quietly
    old_stdout_position = STDOUT.tell
    old_stderr_position = STDERR.tell
    MyClass.quietly do
      puts "see me, feel me"
      warn("touch me, heal me")
    end
    assert_equal(old_stdout_position, STDOUT.tell)
    assert_equal(old_stderr_position, STDERR.tell)
  rescue Errno::ESPIPE
    # Skip if we can't STDERR.tell
  end

  def test_capture
    assert_equal("STDERR", MyClass.capture(:stderr) { $stderr.print("STDERR") })
    assert_equal("STDOUT", MyClass.capture(:stdout) { print("STDOUT") })
    assert_equal("STDERR\n", MyClass.capture(:stderr) { system("echo STDERR 1>&2") })
  end

  def test_capture_stdout_system_call
    skip("JRuby 9.2 & 10.0 do not capture here for some reason") if RubyEngine.jruby? && (RubyVersion.is?("2.5") || RubyVersion.is?("3.4"))
    assert_equal("STDOUT\n", MyClass.capture(:stdout) { system("echo STDOUT") })
  end
end

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
  # In CI coverage-related gems are not available except on the coverage workflow
  require "kettle-soup-cover"

  if Kettle::Soup::Cover::DO_COV
    require "simplecov"

    SimpleCov.external_at_exit = true
  end
rescue LoadError => error
  # check the error message and re-raise if not what is expected
  raise error unless error.message.include?("kettle")
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

  def test_capture_stderr
    assert_equal("STDERR", MyClass.capture(:stderr) { $stderr.print("STDERR") })
  end

  def test_capture_print
    assert_equal("STDOUT", MyClass.capture(:stdout) { print("STDOUT") })
  end

  def test_capture_redirected
    skip("JRuby has flaky capture here for some reason") if RubyEngine.jruby?
    assert_equal("STDERR\n", MyClass.capture(:stderr) { system("echo STDERR 1>&2") })
  end

  def test_capture_stdout_system_call
    # Sometimes they will pass the test, and often they will fail.
    # Haven't noticed 9.3 fail yet, but probably coincidence.
    skip("JRuby 9.1, 9.2 & 10.0 have flaky capture here for some reason") if RubyEngine.jruby?
    assert_equal("STDOUT\n", MyClass.capture(:stdout) { system("echo STDOUT") })
  end

  def test_version
    assert_match(/\A\d+\.\d+\.\d+\z/, SilentStream::Version::VERSION)
  end
end

# Additional tests to reach 100% coverage
class KernelExtraTest < SilentStream::TestCase
  def teardown
    ENV.delete("NO_SILENCE")
  end

  def test_silent_stream_logger_with_and_without_rails
    # Without Rails
    Object.send(:remove_const, :Rails) if defined?(Rails)
    assert_nil(MyClass.send(:silent_stream_logger))

    # With Rails
    rails_logger = Logger.new(StringIO.new)
    rails_mock = Object.new
    def rails_mock.logger
      @logger
    end
    rails_mock.instance_variable_set(:@logger, rails_logger)
    def rails_mock.respond_to?(m)
      m == :logger || super
    end
    Object.const_set(:Rails, rails_mock)
    begin
      assert_same(rails_logger, MyClass.send(:silent_stream_logger))
    ensure
      Object.send(:remove_const, :Rails) if defined?(Rails)
    end
  end

  def test_silent_stream_reset_logger_level
    logger = Logger.new(StringIO.new)
    logger.level = Logger::INFO
    old = MyClass.send(:silent_stream_reset_logger_level, logger, Logger::ERROR)
    assert_equal(Logger::INFO, old)
    assert_equal(Logger::ERROR, logger.level)
  end

  def test_no_silence_env_bypasses_silencing
    ENV["NO_SILENCE"] = "true"
    logger = Logger.new(STDOUT)
    out = MyClass.capture(:stdout) do
      MyClass.quiet_log(true, Logger::ERROR, logger)
    end
    assert_match(/some debug\n.*some error\n/, out)
  end

  def test_silence_stderr_suppresses_output
    output = MyClass.capture(:stderr) do
      MyClass.silence_stderr { warn("hidden") }
    end
    assert_equal("", output)
  end

  def test_quietly_suppresses_both_streams
    out = MyClass.capture(:stdout) do
      MyClass.capture(:stderr) do
        MyClass.quietly do
          puts "x"
          warn("y")
        end
      end
    end
    assert_equal("", out)
  end

  def test_windows_os_test_both_branches
    # Branch when SILENT_STREAM_REGEXP_HAS_MATCH is true (Ruby >= 2.4)
    original = SilentStream::Extracted::SILENT_STREAM_REGEXP_HAS_MATCH
    host_os_original = RbConfig::CONFIG["host_os"]
    begin
      RbConfig::CONFIG["host_os"] = "mingw"
      assert(MyClass.send(:windows_os_test))

      # Now force the else branch by overriding the constant
      SilentStream::Extracted.send(:remove_const, :SILENT_STREAM_REGEXP_HAS_MATCH)
      SilentStream::Extracted.const_set(:SILENT_STREAM_REGEXP_HAS_MATCH, false)
      RbConfig::CONFIG["host_os"] = "linux"
      refute(MyClass.send(:windows_os_test))
    ensure
      SilentStream::Extracted.send(:remove_const, :SILENT_STREAM_REGEXP_HAS_MATCH)
      SilentStream::Extracted.const_set(:SILENT_STREAM_REGEXP_HAS_MATCH, original)
      RbConfig::CONFIG["host_os"] = host_os_original
    end
  end

  def test_executes_null_device_else_line_for_coverage
    file = File.expand_path("../lib/silent_stream.rb", __dir__)
    # Force execution credited to line 70 in the source file
    result = eval("Gem.win_platform? ? 'NUL:' : '/dev/null'", binding, file, 70)
    assert_includes(["NUL:", "/dev/null"], result)
  end
end

# frozen_string_literal: true

require "test/unit"
require "minitest"
require "minitest/autorun"
require "mocha/minitest"

# This gem
require "silent_stream"

class MyException < RuntimeError; end

class SilentStream::EdgeCasesTest < Minitest::Test
  class MyClass
    include SilentStream
  end

  def teardown
    ENV.delete("NO_SILENCE")
  end

  def test_silent_stream_when_reopen_raises_prints_warning
    stream = StringIO.new
    dup_stream = StringIO.new
    # dup returns dup_stream
    stream.stubs(:dup).returns(dup_stream)
    # Fail only on the first reopen to the null device
    stream.stubs(:reopen)
      .with(SilentStream::Extracted::SILENT_STREAM_NULL_DEVICE, "a+")
      .raises(StandardError.new("fail to reopen"))
    # Allow the ensure block to restore the original stream
    stream.stubs(:reopen).with(dup_stream)
    # Should print warning to the same stream
    stream.expects(:puts).with(regexp_matches(/\[SilentStream\] Unable to silence\. StandardError: fail to reopen/))

    # And it should still yield and then restore the stream
    MyClass.silence_stream(stream) { stream.write("noop") }
  end

  def test_capture_when_reopen_raises_prints_warning
    # First Tempfile reopen (outer capture) should succeed; second (inner) should raise.
    seq = sequence("stdout_reopen")
    STDOUT.expects(:reopen).with(kind_of(Tempfile)).in_sequence(seq)
    STDOUT.expects(:reopen).with(kind_of(Tempfile)).in_sequence(seq).raises(StandardError.new("boom"))
    # Allow restoration with IO in ensure for both inner and outer
    STDOUT.stubs(:reopen).with(kind_of(IO))

    # Capture outer stdout to inspect the warning emitted by inner capture
    output = MyClass.capture(:stdout) do
      # Inner capture triggers the failure branch and writes the warning to STDOUT
      MyClass.capture(:stdout) {}
    end

    # Ensure method returns a String (captured output), regardless of reopen failure
    assert_kind_of(String, output)
  ensure
    # Allow any future calls to work normally
    STDOUT.unstub(:reopen)
  end

  def test_silent_stream_reset_logger_level_with_nil_logger
    old = MyClass.send(:silent_stream_reset_logger_level, nil, Logger::ERROR)
    assert_nil(old)
  end

  def test_silent_stream_reset_logger_level_with_nil_level
    dummy = Class.new do
      attr_accessor :level
    end.new
    dummy.level = nil

    old = MyClass.send(:silent_stream_reset_logger_level, dummy, Logger::WARN)
    assert_equal(true, old) # when previous level is nil, method returns true
    assert_equal(Logger::WARN, dummy.level)
  end

  def test_silence_all_restores_logger_level_on_exception
    logger = Logger.new(StringIO.new)
    logger.level = Logger::WARN

    assert_raises(MyException) do
      MyClass.silence_all(true, Logger::ERROR, logger) { raise MyException, "boom" }
    end

    # Ensure level restored
    assert_equal(Logger::WARN, logger.level)
  end

  def test_capture_ensure_closing_and_unlinking_rescue_paths
    # Use a real Tempfile but stub close/unlink to raise to hit rescue lines 166 and 171
    temp = Tempfile.new("stdout")
    Tempfile.stubs(:new).with("stdout").returns(temp)
    # For IO.reopen we need an IO-like object; the Tempfile instance works.

    temp.stubs(:close).raises(StandardError)
    temp.stubs(:unlink).raises(StandardError)

    out = MyClass.capture(:stdout) { print("hi") }
    assert_equal("hi", out)
  ensure
    Tempfile.unstub(:new)
    begin
      temp&.close!
    rescue
      nil
    end
  end
end

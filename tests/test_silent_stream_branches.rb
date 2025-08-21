# frozen_string_literal: true

require "test/unit"
require "minitest/autorun"
require "mocha/minitest"

# This gem
require "silent_stream"

class BranchesCoverageTest < Minitest::Test
  class MyClass
    include SilentStream
  end

  # Covers the false branches for the guards
  #   io_const.reopen(origin_io_dup) if defined?(io_const) && io_const
  #   origin_io_dup.close if defined?(origin_io_dup) && origin_io_dup
  # by raising before io_const and origin_io_dup are assigned;
  # the ensure block executes and the guarded calls are skipped.
  def test_capture_ensure_skips_reopen_and_close_when_stream_setup_fails
    bad = Object.new
    def bad.to_s
      raise "boom to_s"
    end

    begin
      MyClass.capture(bad) {}
    rescue TypeError
      # Expected: $stderr assignment attempts with nil origin_gvar raise TypeError
      # We only care that ensure ran and hit the guarded conditions at 150/151.
    end
  end

  # Covers the false branch by making captured_stream nil;
  #   if defined?(captured_stream) && captured_stream
  # this causes captured_stream.rewind to raise before returning,
  # but ensure runs and the guard (defined? && captured_stream)
  # evaluates to false.
  def test_capture_ensure_skips_tempfile_cleanup_when_missing
    Tempfile.stubs(:new).with("stdout").returns(nil)
    assert_raises(NoMethodError) do
      MyClass.capture(:stdout) { print("hi") }
    end
  ensure
    Tempfile.unstub(:new)
  end

  def test_capture_ensure_handles_tempfile_unlink_failure
    # Use a real Tempfile and stub only unlink to raise to hit rescue at unlink (line 174)
    temp = Tempfile.new("stdout")
    Tempfile.stubs(:new).with("stdout").returns(temp)
    # Tempfile#unlink internally calls File.unlink(path); stub that to force an error
    File.stubs(:unlink).with(temp.path).raises(StandardError)

    out = MyClass.capture(:stdout) { print("hi") }
    assert_equal("hi", out)
  ensure
    Tempfile.unstub(:new)
    File.unstub(:unlink)
    begin
      temp&.close!
    rescue
      nil
    end
  end
end

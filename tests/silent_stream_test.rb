require 'test/unit'
require 'minitest'
require 'simplecov'

SimpleCov.start { add_filter '/tests/' }

# This gem
require 'silent_stream'

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
      return captured_stream.read
    ensure
      captured_stream.close
      captured_stream.unlink
      stream_io.reopen(origin_stream)
    end
  end
end

class MyException < Exception; end

class MyClass
  include SilentStream
end

class KernelTest < SilentStream::TestCase
  def test_silence_stream
    old_stream_position = STDOUT.tell
    MyClass.silence_stream(STDOUT) { STDOUT.puts 'hello world' }
    assert_equal old_stream_position, STDOUT.tell
  rescue Errno::ESPIPE
    # Skip if we can't stream.tell
  end

  def test_silence_stream_closes_file_descriptors
    stream     = StringIO.new
    dup_stream = StringIO.new
    stream.stubs(:dup).returns(dup_stream)
    dup_stream.expects(:close)
    MyClass.silence_stream(stream) { stream.puts 'hello world' }
  end

  def test_quietly
    old_stdout_position, old_stderr_position = STDOUT.tell, STDERR.tell
    MyClass.quietly do
      puts 'see me, feel me'
      STDERR.puts 'touch me, heal me'
    end
    assert_equal old_stdout_position, STDOUT.tell
    assert_equal old_stderr_position, STDERR.tell
  rescue Errno::ESPIPE
    # Skip if we can't STDERR.tell
  end

  def test_capture
    assert_equal 'STDERR', MyClass.capture(:stderr) { $stderr.print 'STDERR' }
    assert_equal 'STDOUT', MyClass.capture(:stdout) { print 'STDOUT' }
    assert_equal "STDERR\n", MyClass.capture(:stderr) { system('echo STDERR 1>&2') }
    assert_equal "STDOUT\n", MyClass.capture(:stdout) { system('echo STDOUT') }
  end
end

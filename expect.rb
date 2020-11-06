require 'stringio'
require_relative 'lisp'
require_relative 'colors'

def capture(&block)
  sio = StringIO.new
  value = nil
  begin
    old_stdout = $stdout
    $stdout = sio
    value = yield
  ensure
    $stdout = old_stdout
  end
  [value, sio.string]
end

class Expectation
  def initialize(string)
    @expr = string
    begin
      @value, @stdout = capture { exec_lisp(string) }
    rescue => e
      @exception = e
    end
  end

  def to_x(statement, verb, test_value, real_value)
    if test_value != Exception and @exception
      puts
      puts "#{@expr} should #{statement}"
      puts " -> it actually threw".red
      raise @exception
    end
    if !(test_value === real_value)
      puts
      puts "#{@expr} should #{statement}"
      puts " -> it actually #{verb} #{real_value.inspect}".red
    else
      print "."
    end
    self
  end

  def to_return(value)
    to_x("return #{value.inspect}", "returned", value, @value)
  end

  def to_print(string)
    to_x("print #{string.inspect}", "printed", string, @stdout)
  end

  def to_fail
    to_x("fail", "did not (#{@value})", Exception, @exception)
  end

  def and
    # conjunction junction
    self
  end
end

def expect(string)
  Expectation.new(string)
end

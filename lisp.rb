#!/usr/bin/env ruby

require 'readline'
require 'optparse'
require_relative 'parse'

options = {}

OptionParser.new do |opt|
  opt.on("--debug", "print debug information") { $debug = true }
  opt.on("--stdin", "read program from stdin") { options[:stdin] = true }
  opt.on("-f", "--file FILE", "read program from file") { |v| options[:file] = v }
end.parse!

def default_state
  {
    vars: {},
  }
end

def assert(assertion)
  raise "assertion failed" unless assertion
end

def sym(v)
  type, value = v
  assert(type == :sym)
  value
end

def var(state, name)
  if state[:vars].include? name
    state[:vars][name]
  elsif state.include? :upper
    var(state[:upper], name)
  end
end

def format_lisp(sexp)
  case sexp
  when Integer
    "#{sexp}"
  when String
    "\"#{sexp}\""
  when -> x { x[0] == :sym }
    ":#{sexp[1]}"
  when -> x { x[0] == :int }
    "#{sexp[1]}"
  when -> x { x[0] == :str }
    "#{sexp[1]}"
  when -> x { x[0] == :lambda }
    "<lambda>"
  when Array
    "(#{sexp.map { |s| format_lisp(s) }.join(" ")})"
  else
    "?"
  end
end

def eval_lambda(lisp)
  STDERR.puts "eval_lambda #{lisp.inspect}" if $debug
  [:lambda, lisp[1].map { |t, v| v }, lisp.drop(2)]
end

def exec_lambda(lam, args, context)
  STDERR.puts "exec_lambda #{lam.inspect} : #{args.inspect}" if $debug
  args = Hash[lam[1].zip(args)]
  exec_several(lam[2], { upper: context, vars: args })
end

def exec_one(sexp, state = default_state)
  STDERR.puts "exec_one    #{sexp.inspect} : #{state.inspect}" if $debug

  return unless sexp
  return nil if sexp == [:sym, "nil"]

  case sexp[0]
  when :int, :str, :quote
    sexp[1]
  when :sym
    var(state, sexp[1]) || sexp
  when :lambda
    sexp
  when [:sym, "def"]
    state[:vars][sexp[1][1]] = exec_several(sexp.drop(2), state)
  when [:sym, "lambda"]
    eval_lambda(sexp)
  when [:sym, "print"]
    sexp.drop(1).each { |l| puts(format_lisp(exec_one(l, state))) }
  when [:sym, "state"]
    puts state.inspect
  when [:sym, "if"]
    if exec_one(sexp[1], state) 
      exec_one(sexp[2], state) 
    elsif sexp.length > 3
      exec_one(sexp[3], state)
    end
  when [:sym, "exit"]
    exit 0
  when [:sym, "not"]
    not exec_one(sexp[1], state)
  when [:sym, "+"]
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(0, &:+)
  when [:sym, "*"]
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(1, &:*)
  when [:sym, "-"]
    exec_one(sexp[1], state) - exec_one(sexp[2], state)
  when [:sym, "/"]
    exec_one(sexp[1], state) / exec_one(sexp[2], state)
  when [:sym, "="]
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(&:==)
  else
    exec_lambda(
      exec_one(var(state, sexp[0][1]), state),
      sexp.drop(1).map { |l| exec_one(l, state) },
      state
    )
  end
end

def exec_several(lisp, state = default_state)
  lisp.map { |sexp| exec_one(sexp, state) }.last
end

def exec_lisp(string)
  STDERR.puts "exec_lisp    #{string}" if $debug
  exec_several(to_lisp(string))
end


if options[:stdin]
  exec_lisp(ARGF.read)
elsif options[:file]
  exec_lisp(File.read(options[:file]))
elsif __FILE__ == $PROGRAM_NAME
  state = { vars: {} }
  while buf = Readline.readline("> ", true)
    begin
      exec_several(to_lisp("(print #{buf})"), state)
    rescue RuntimeError => e
      puts e.message
    end
  end
end

#!/usr/bin/env ruby

require 'readline'
require_relative 'parse'

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

def type(sexp)
  sexp[0]
end

def val(sexp)
  sexp(1)
end

def exec_one(sexp, state = default_state)
  puts "#{sexp.inspect} #{state.inspect}"

  return state[:vars][val(sexp)] if type(sexp) == :sym
  return val(sexp) if sexp[0].is_a? Symbol
  assert(sexp[0].is_a? Array)

  case sym(sexp[0])
  when "def"
    state[:vars][sexp[1][1]] = exec(sexp.drop(2), state)
  when "lambda"
    [:lambda, [], []]
  when "+"
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(0, &:+)
  when "*"
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(1, &:*)
  when "-"
    exec_one(sexp[1], state) - exec_one(sexp[2], state)
  when "/"
    exec_one(sexp[1], state) / exec_one(sexp[2], state)
  when "="
    sexp.drop(1).map { |l| exec_one(l, state) }.reduce(&:==)
  when "print"
    sexp.drop(1).map { |l| exec_one(l, state) }.map { |v| puts v }
  else
    raise "#{sexp} is not executable"
  end
end

def exec(lisp, state = default_state)
  lisp.map { |sexp| exec_one(sexp, state) }.last
end

# lisp = <<EOF
# (def a (+ 1 1))
# (print a)
# EOF
# 
# exec(to_lisp(lisp))

if __FILE__ == $PROGRAM_NAME
  state = { vars: {} }

  while buf = Readline.readline("> ", true)
    exec(to_lisp("(print #{buf})"), state)
  end
end

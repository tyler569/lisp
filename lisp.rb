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

def eval_lambda(lisp)
  p [:lambda, lisp[1].map { |t, v| v }, lisp.drop(2)]
end

def exec_lambda(lam, args, context)
  p args = Hash[lam[1].zip(args)]
  p exec_one(lam[2], { upper: context, vars: args })
end

def exec_one(sexp, state = default_state)
  puts "#{sexp.inspect} #{state.inspect}"

  case sexp[0]
  when :int, :str
    sexp[1]
  when :sym
    var(state, sexp[1])
  when [:sym, "def"]
    state[:vars][sexp[1][1]] = exec(sexp.drop(2), state)
  when [:sym, "lambda"]
    eval_lambda(sexp)
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
  when [:sym, "print"]
    sexp.drop(1).map { |l| exec_one(l, state) }.map { |v| puts v }
  when [:sym, "if"]
    exec_one(sexp[1], state) ? exec_one(sexp[2], state) : exec_one(sexp[3], state)
  else
    exec_lambda(
      var(state, sexp[0][1]),
      sexp.drop(1).map { |l| exec_one(l, state) },
      state
    )
  end
end

def exec(lisp, state = default_state)
  lisp.map { |sexp| exec_one(sexp, state) }.last
end


if __FILE__ == $PROGRAM_NAME
  lisp = <<~EOF
    (def plus-one (lambda (a) (+ a 1)))
    (print (plus-one 19))
  EOF
  exec(to_lisp(lisp))

  exec(p to_lisp("(lambda (a) 1)"))

  state = { vars: {} }
  while buf = Readline.readline("> ", true)
    exec(to_lisp("(print #{buf})"), state)
  end
end

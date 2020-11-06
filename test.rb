#!/usr/bin/env ruby

require_relative 'lisp'
require_relative 'expect'

# $debug = true

expect("(+)").to_return(0)
expect("(+ 1)").to_return(1)
expect("(+ 1 1)").to_return(2)

expect("(*)").to_return(1)
expect("(* 1)").to_return(1)
expect("(* 1 1)").to_return(1)

expect("(foobar)").to_fail

expect(<<EOF).to_return(10)
(def a 10)
a
EOF

expect(<<EOF).to_return(10)
(def a (+ 1 9))
a
EOF

expect(<<EOF).to_return(10)
(def plus-one (lambda (a) (+ a 1)))
(plus-one 9)
EOF

expect("(if (= 1 1) 1 2)").to_return(1)
expect("(if (= 1 2) 1 2)").to_return(2)
expect("(if nil 1 2)").to_return(2)
expect("(if some-symbol 1 2)").to_return(1)

expect("(print 10)").to_print("10\n")
expect("(print '(1 2 3))").to_print("(1 2 3)\n")
expect("(print (lambda () 1))").to_print("<lambda>\n")
expect("(print ((lambda () 1)))").to_print("1\n")

expect("(do 1 2)").to_return(2)
expect("(if t (do (print 1) (print 2)) (print 3))").to_print("1\n2\n")

puts

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

expect("(-)").to_fail
expect("(- 10)").to_fail
expect("(- 10 9)").to_return(1)

expect("(/)").to_fail
expect("(/ 10)").to_fail
expect("(/ 10 10)").to_return(1)

expect("(%)").to_fail
expect("(% 10)").to_fail
expect("(% 10 10)").to_return(0)
expect("(% 11 10)").to_return(1)
expect("(% 12 10)").to_return(2)
expect("(% 13 10)").to_return(3)

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

expect("(print (cons 1 '()))").to_print("(1)\n")

expect("(print (car '(1 2 3)))").to_print("1\n")
expect("(print (cdr '(1 2 3)))").to_print("(2 3)\n")
expect("(print (car '()))").to_print("nil\n")
expect("(print (cdr '(1)))").to_print("nil\n")
expect("(print (cdr '()))").to_print("nil\n")

expect(<<EOF).to_return(10)
(def foo (lambda (a) a))
(def a 10)
(foo a)
EOF

finish

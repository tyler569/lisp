(def assert (lambda (test-value real-value)
              (if (not (= test-value real-value))
                (print "Failure")
                (print "Success"))))

(assert (+ 1 1) 2)
(assert (* 2 2) 4)
(assert (if t 1 2) 1)
(assert (if nil 1 2) 2)

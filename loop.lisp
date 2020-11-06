(def loop (lambda (from to body)
            (if (= from to)
              (cons (body from) nil)
              (cons
                (body from)
                (loop (+ from 1) to body)))))

(print (loop 1 10 (lambda (a) a)))

; speed test
(loop 1 1000
      (lambda (a)
        (if (= 0 (% a 100))
          (print a))))

(def map (lambda (fn collection)
           (if collection
             (cons (fn (car collection)) (map fn (cdr collection)))
             (fn (car collection)))))

(def plus-one (lambda (a) (+ a 1)))

(def collection '(1 2 3 4 5))

(print (map plus-one collection))

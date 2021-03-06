#|
Copyright (C) 2013 Michael Fogus <me -at- fogus -dot- me>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
|#

;; Core functions

(define call/cc call-with-current-continuation)

(define (caar lst) (car (car lst)))
(define (cadr lst) (car (cdr lst)))
(define (cdar lst) (cdr (car lst)))
(define (cddr lst) (cdr (cdr lst)))
(define (caaar lst) (car (car (car lst))))
(define (caadr lst) (car (car (cdr lst))))
(define (cadar lst) (car (cdr (car lst))))
(define (caddr lst) (car (cdr (cdr lst))))
(define (cdaar lst) (cdr (car (car lst))))
(define (cdadr lst) (cdr (car (cdr lst))))
(define (cddar lst) (cdr (cdr (car lst))))
(define (cdddr lst) (cdr (cdr (cdr lst))))
(define (caaaar lst) (car (car (car (car lst)))))
(define (caaadr lst) (car (car (car (cdr lst)))))
(define (caadar lst) (car (car (cdr (car lst)))))
(define (caaddr lst) (car (car (cdr (cdr lst)))))
(define (cadaar lst) (car (cdr (car (car lst)))))
(define (cadadr lst) (car (cdr (car (cdr lst)))))
(define (caddar lst) (car (cdr (cdr (car lst)))))
(define (cadddr lst) (car (cdr (cdr (cdr lst)))))
(define (cdaaar lst) (cdr (car (car (car lst)))))
(define (cdaadr lst) (cdr (car (car (cdr lst)))))
(define (cdadar lst) (cdr (car (cdr (car lst)))))
(define (cdaddr lst) (cdr (car (cdr (cdr lst)))))
(define (cddaar lst) (cdr (cdr (car (car lst)))))
(define (cddadr lst) (cdr (cdr (car (cdr lst)))))
(define (cdddar lst) (cdr (cdr (cdr (car lst)))))
(define (cddddr lst) (cdr (cdr (cdr (cdr lst)))))

(define (list-tail lst k)
  (if (zero? k)
    lst
    (list-tail (cdr lst) (- k 1))))

(define (list . elems) elems)
(define (vector . elems) (list->vector elems))

(define (list-ref lst k) (car (list-tail lst k)))

;; Tests

(define x 0)

x
;;=> 0

(begin
  (set! x 5)
  (+ x 1))
;;=> 6

x
;;=> 5

'(1 . 2)
;;=> (1 . 2)

(pair? '(1 . 2))
;;= #t

(pair? 1)
;;=> #f

(pair? '(1 2 3))
;;=> #f

(pair? '())
;;=> #f

(pair? '(1 2 3))
;;=> #t

(cons 1 2)
;;=> (1 . 2)

(pair? (cons 1 2))
;;=> #t

(cons '(a b) 'c)
;;=> ((a b) . c)

(car '(1 . 2))
;;=> 1

(car (cons '(a b) 'c))
;;=> (a b)

(cdr '(1 . 2))
;;=> 2

(cdr (cons '(a b) 'c))
;;=> c

(append '() 'a)
;;=> a

(append '(a b) '(c . d))
;;=> (a b c . d)

(append '(x) '(y))
;;=> (x y)

(append '(x) '(b c d))
;;=> (x b c d)

(append '(a (b)) '((c)))
;;=> (a (b) (c))

(define (add x y) (+ x y))

(add 1 2)
;;=> 3

(define f (lambda (a b . m) m))

(f 1 2)
;;=> ()

(f 1 2 3 4)
;;=> (3 4)

(define (more a b . c) c)

(more 1 2)
;;=> ()

(more 1 2 3 4)
;;=> (3 4)

(+ 3 4)
;;=> 7

(+ 1 2 3)
;;=> 6

(- 3 4 5)
;;=> -6

(- 3 4)
;;=> -1

(null? '())
;;=> #t

(list? '())
;;=> #t

(list? '(1 2 3))
;;=> #t

(list? '(a . b))
;;=> #f

(make-list 3 3)
;;=> (3 3 3)

(make-list 10 'a)
;;=> (a a a a a a a a a a)

(list? (make-list 3 3))
;;=> #t

(make-list 3)
;;=> (0 0 0)

(length '(1 2 3))
;;=> 3

(length '(a (b) (c d e)))
;;=> 3

(length '())
;;=> 0

(reverse '(1 2 3))
;;=> (3 2 1)

(reverse '(a (b c) d (e (f))))
;;=> ((e (f)) d (b c) a)

(zero? 0)
;;=> #t

(zero? 1)
;;=> #f

(zero? '())
;;=> #f

(list-tail '(1 2 3 4 5) 2)
;;=> (3 4 5)

(list 1 2 3)
;;=> (1 2 3)

(list 'a (+ 3 4) 'c)
;;=> (a 7 c)

(list)
;;=> ()

(list-ref '(a b c d) 2)
;;=> c

(symbol->string 'a)
;;=> "a"

(string->symbol "A")
;;=> A

(symbol->string (string->symbol "A"))
;;=> "A"


(char? #\()
;;=> #t

"a\nb"
"a\rb"
"a\|b"
"a\tb"
"a\\b"
"a\"b"

(make-string 3 #\a)
;;=> "aaa"

(make-string 3)
;;=> "zzz"

(string-length "")
;;=> 0

(string-length "a")
;;=> 1

(string-length (make-string 100))
;;=> 100

(string #\a)
;;=> "a"

(string #\a #\b)
;;=> "ab"

(string-ref "abc" 1)
;;=> #\b

(substring "abcd" 1 2)
;;=> "bc"

(string-append "a" "b")
;;=> "ab"

(string-append "a" "b" "c")
;;=> "abc"

(string-append "a" "b" "c" "d")
;;=> "abcd"

(string-append "a")
;;=> "a"

(string-append)
;;=> ""

(string->list "")
;;=> []

(string->list "abcd")
;;=> (#\a #\b #\c #\d)

(string->list "abcd" 1)
;;=> (#\b #\c #\d)

(string->list "abcd" 1 2)
;;=> (#\b)

(list->string '(#\a))
;;=> "a"

(list->string '(#\a #\b))
;;=> "ab"

(list->string '(#\a #\b #\c))
;;=> "abc"

(list->string '())
;;=> ""

(string-copy "abcd")
;;=> "abcd"

(string-copy "abcd" 1)
;;=> "bcd"

(string-copy "abcd" 1 2)
;;=> "bc"

#(0 (2 2 2) "Anna")
;;=> #(0 (2 2 2) "Anna")

(vector? #())
;;=> #t

(vector? 42)
;;=> #f

(vector? '())
;;=> #f

(make-vector 3)
;;=> #(0 0 0)

(make-vector 5 'a)
;;=> #(a a a a a)

(vector? (make-vector 5 'a))
;;=> #t

(list->vector '(1 2 3))
;;=> #(1 2 3)

(vector 'a 'b 'c)
;;=> #(a b c)

(vector-length #())
;;=> 0

(vector-length #(1 3 3))
;;=> 3

(vector-length (make-vector 100))
;;=> 100

(vector-ref '#(1 1 2 3 5 8 13 21) 5)
;;=> 8

(vector->list #())
;;=> ()

(vector->list #(1 2 3))
;;=> (1 2 3)

(vector->list (make-vector 10 'a))
;;=> (a a a a a a a a a a)

(vector->list '#(dah dah didah) 1)
;;=> (dah didah)

(vector->list '#(dah dah didah) 1 2)
;;=> (dah)

(vector->string #(#\a #\b))
;;=> "ab"

(vector->string #(#\a #\b #\c) 1)
;;=> "bc"

(vector->string #(#\a #\b #\c) 1 2)
;;=> "b"

(string->vector "abc")
;;=> #(#\a #\b #\c)

(vector-copy #(1 2 3))
;;=> #(1 2 3)

(vector-copy #(1 2 3) 1)
;;=> #(2 3)

(vector-copy #(1 2 3) 1 2)
;;=> #(2 3)

(vector-append #(a b c) #(d e f))
;;=> #(a b c d e f)










#f
#t


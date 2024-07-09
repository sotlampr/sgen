(define tags '(html head meta body h1 h2 h3 h4 h5 h6 div p a br li ul))

(define (tag-valid? x)
  (and (symbol? x) (member x tags)))

(define (tag? expr) 
  (and
    (list? expr)
    (not (null? expr))
    (tag-valid? (car expr))))

(define (stag? expr)
  (and
    (list? expr)
    (not (null? expr))
    (let ((tag (car expr)))
     (or (eq? tag 'script) (eq? tag 'style)))))

(define (attr? expr)
  (and
    (list? expr)
    (= (length expr) 2)
    (not (char=? (string-ref (symbol->string (car expr)) 0) #\:))
    ))

(define (consume-attrs expr)
  (let
   ([next (car expr)]
     [rest (cdr expr)] )
   (if (and (not (tag? next)) (not (stag? next)) (attr? next))
       (begin
         (format #t " ~a=~s" (car next) (cadr next))
         (if (null? rest) rest (consume-attrs rest)))
       expr)))

(define (to-html fname)
  (call-with-input-file (string-append fname ".ss")
                        (lambda (x)
                          (with-output-to-file (string-append fname ".html")
                                               (lambda () (eval-expr (read x)))))))
(define (:include fname)
  (call-with-input-file (string-append fname ".ss")
                        (lambda (x)
                          (eval-expr (read x)))))

(define (:include-and-link fname text)
  (to-html fname)
  (eval-expr `(a (href ,(string-append "/" fname ".html")) ,text)))

(define (html-escape str)
  (let ([ip (open-string-input-port str)])
    (let-values ([(op k) (open-string-output-port)])
      (let f ()
       (let ([c (read-char ip)])
         (cond
           [(eof-object? c) (k)]
           [else
            (begin
              (case c
                (#\& (put-string op "&amp;"))
                (#\< (put-string op "&lt;"))
                (#\> (put-string op "&gt;"))
                (#\' (put-string op "&apos;"))
                (else (put-char op c)))
              (f)
              )]))))))

(define (eval-expr expr)
  (cond 
    [(string? expr) (format #t "~a" (html-escape expr))]
    [(tag? expr)
     (let ([tag (car expr)]
            [rest (cdr expr)])
       (if (null? rest)
           (format #t "<~a>" tag) 
           (when (not (eq? tag 'br)) (format #t "<~a" tag)
             (set! rest (consume-attrs rest))
             (format #t ">")))
       (for-each eval-expr rest)
       (when (not (eq? tag 'br)) (format #t "</~a>" tag)))]
    [(stag? expr)
     (let ((tag (car expr)) (body (cdr expr)))
       (format #t "<~a>~a</~a>" tag (apply string-append body) tag)) ]
    [(not (eq? (car expr) void)) (apply (eval (car expr)) (cdr expr))]
    [else (raise (format #t "~%Error parsing '~a'" expr))]))

(to-html "index")

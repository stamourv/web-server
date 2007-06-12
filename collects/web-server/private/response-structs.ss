(module response-structs mzscheme
  (require (lib "contract.ss")
           (lib "xml.ss" "xml"))
  
  (define TEXT/HTML-MIME-TYPE #"text/html; charset=utf-8")
  
  (define-struct response/basic (code message seconds mime extras))
  (define-struct (response/full response/basic) (body))
  (define-struct (response/incremental response/basic) (generator))
    
  ; response = (cons string (listof string)), where the first string is a mime-type
  ;          | x-expression
  ;          | (make-response/full ... (listof string))
  ;          | (make-response/incremental ... ((string* -> void) -> void))
  
  ;; response?: any -> boolean
  ;; Determine if an object is a response
  (define (response? x)
    (or (response/basic? x)
        ; this could fail for dotted lists - rewrite andmap
        (and (pair? x) (andmap
                        (lambda (x)
                          (or (string? x)
                              (bytes? x)))
                        x))
        ; insist that the xexpr has a root element
        (and (pair? x) (xexpr? x))))
  
  
  (provide/contract
   [struct response/basic
           ([code number?]
            [message string?]
            [seconds number?]
            [mime bytes?]
            [extras (listof (cons/c symbol? string?))])]            
   [struct (response/full response/basic)
           ([code number?]
            [message string?]
            [seconds number?]
            [mime bytes?]
            [extras (listof (cons/c symbol? string?))]
            [body (listof (or/c string?
                                 bytes?))])]
   [struct (response/incremental response/basic)
           ([code number?]
            [message string?]
            [seconds number?]
            [mime bytes?]
            [extras (listof (cons/c symbol? string?))]
            [generator ((() (listof (or/c bytes? string?)) . ->* . any) . -> . any)])]
   [response? (any/c . -> . boolean?)]
   [TEXT/HTML-MIME-TYPE bytes?]))
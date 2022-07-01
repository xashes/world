#lang racket

(require 2htdp/image
         2htdp/universe)
(module+ test
  (require rackunit rackunit/text-ui)
  )

(provide
 (contract-out
  [struct wine ((loc posn?))]
  [struct posn ((x number?) (y number?))]
  [wine-walk (-> wine? void?)]
  )
 )

;; loc ::= posn
;; size ::= Number
(struct wine (loc) #:transparent #:mutable)

(struct posn (x y) #:transparent)

;; Constants
(define MAX-SPEED 8)

(define/contract (wine-walk wine)
  (-> wine? void?)
  (define dx (random (- MAX-SPEED) MAX-SPEED))
  (define dy (random (- MAX-SPEED) MAX-SPEED))
  (define origin-posn (wine-loc wine))
  (set-wine-loc! wine (posn (+ (posn-x origin-posn) dx)
                            (+ (posn-y origin-posn) dy))))

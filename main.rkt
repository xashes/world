#lang racket

(module+ test
  (require rackunit))

(require 2htdp/image
         2htdp/universe)

;;  Data Definitions

;; wines ::= (listof wine)
(struct world-state (wines) #:transparent #:mutable)

;; loc ::= posn
;; size ::= Number
(struct wine (loc) #:transparent #:mutable)

(struct posn (x y) #:transparent)

;; Constants
(define TICK-RATE 1/10)
(define INIT-WINE-POPULATION 8)
(define WINE-MAX-SPEED 8)

;; Graphical board size
(define WIDTH 800)
(define HEIGHT 600)
(define WINE-SIZE 20)

;; Visual constants
(define MT-SCENE (empty-scene WIDTH HEIGHT))
(define WINE-IMG (circle WINE-SIZE 'solid 'red))

;; Start
(define (start-world)
  (big-bang (initial-world)
            (to-draw render-world)
            (on-tick next-world TICK-RATE)
            )
  )

(define/contract (initial-world)
  (-> world-state?)
  (world-state (make-wines INIT-WINE-POPULATION))
  )

(define/contract (make-wines n)
  (-> positive-integer? (listof wine?))
  (map (λ (x) (make-random-wine)) (range n))
  )

(define/contract (make-random-wine)
  (-> wine?)
  (define x (random WIDTH))
  (define y (random HEIGHT))
  (wine (posn x y))
  )

(define/contract (render-world ws)
  (-> world-state? image?)
  (define wines (world-state-wines ws))
  (wines+scene wines MT-SCENE)
  )

(define/contract (wines+scene wines scene)
  (-> (listof wine?) image? image?)
  (define posns (get-posns-from-wines wines))
  (img-list+scene WINE-IMG posns scene)
  )

(define/contract (get-posns-from-wines wines)
  (-> (listof wine?) (listof posn?))
  (map (λ (wine) (wine-loc wine)) wines)
  )

(define/contract (img+scene img posn scene)
  (-> image? posn? image? image?)
  (place-image img
               (posn-x posn)
               (posn-y posn)
               scene
               )
  )

(define/contract (img-list+scene img posns scene)
  (-> image? (listof posn?) image? image?)
  (foldl (λ (posn scene) (img+scene img posn scene))
         scene
         posns
         )
  )

(define/contract (random-walk wine)
  (-> wine? void?)
  (define dx (random (- WINE-MAX-SPEED) WINE-MAX-SPEED))
  (define dy (random (- WINE-MAX-SPEED) WINE-MAX-SPEED))
  (define origin-posn (wine-loc wine))
  (set-wine-loc! wine (posn (+ (posn-x origin-posn) dx)
                            (+ (posn-y origin-posn) dy))))

(define/contract (next-world ws)
  (-> world-state? world-state?)
  (define wines (world-state-wines ws))
  (map random-walk wines)
  ws
  )

(module+ main

  (start-world)
  )

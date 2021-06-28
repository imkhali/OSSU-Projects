;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname space-invaders-game) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders game - start by running the following command

;; (main (make-game empty empty T0))


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 3)
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))


;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))

(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number[-1,1])
;; interp. the invader is at (x, y) in screen coordinates
;;         and direction is right (1) or left (-1)

(define I1 (make-invader 150 100 1))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -1))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 1)) ;> landed, moving right

;; for testing 
(define INV-CTR-Y          (make-invader    (random WIDTH)               (/ HEIGHT 2) -1))               ;  in center vertically, moving left
(define INV-JB-BEDGE       (make-invader    (random WIDTH) (- HEIGHT INVADER-Y-SPEED)  1))               ;  just before bottom edge, moving right
(define INV-ON-BEDGE       (make-invader    (random WIDTH)                     HEIGHT -1))               ; exactly at bottom edge, moving left
(define INV-OFF-BEDGE      (make-invader    (random WIDTH)              (+ 10 HEIGHT)  1))               ; went below bottom edge, moving right
(define INV-ON-REDGE       (make-invader             WIDTH               (/ HEIGHT 2)  1))               ; on right edge
(define INV-ON-LEDGE       (make-invader                 0               (/ HEIGHT 3) -1))               ; on left edge
(define INV-JB-LEDGE       (make-invader   INVADER-X-SPEED               (/ HEIGHT 3) -1))               ; just before left edge
(define INV-ON-TEDGE       (make-invader (random WIDTH)                             0 -1))               ; on top edge
#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))

;; ListOfInvader is one of:
;;   - empty
;;   - (cons invader ListOfInvader)
;; interp. a list of invaders
(define LOI0 empty)
(define LOI1 (cons I1 empty))
#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))
              (fn-for-loi (rest loi)))]
        )
  )

(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

;; for tests
(define M-ON-NOT-CTR-Y    (make-missile                    50                          100))     ; on-screen
(define M-OFF             (make-missile                    40                          -10))     ; off-screen
(define M-HIT-INV-CTR-Y   (make-missile (invader-x INV-CTR-Y) (+ (invader-y INV-CTR-Y) 10)))     ; exactly hit missile INV-CTR-Y
(define M-HIT>-INV-CTR-Y  (make-missile (invader-x INV-CTR-Y) (+ (invader-y INV-CTR-Y)  5)))     ; > hit missile INV-CTR-Y
(define M-JB-TEDGE        (make-missile                   100                MISSILE-SPEED))     ; just before leaving screen
(define M-ON-TEDGE        (make-missile                   200                            0))     ; on-top-edge
#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))

(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; Added by me
;; ListOfX is one of:
;;   - empty
;;   - (cons X ListOfX)
;; interp. a list of X

#;
(define (fn-for-lox lox)
  (cond [(empty? lox) (...)]
        [else
         (... (fn-for-x (first lox))
              (fn-for-lox (rest lox)))]
        )
  )

(define (fold fn b lox)
  (cond [(empty? lox) b]
        [else
         (fn (first lox)
             (fold fn b (rest lox)))]
        )
  )


;; ==============================

;; Functions
;; Functions part 1

;; game -> game
;; called to initialize the space invaders game. Start with (main (make-game empty empty T0))
(define (main g)
  (big-bang g
    (on-tick advance-game) ; game -> game
    (to-draw render-game)  ; game -> image
    (on-key handle-key)    ; game keyevent -> game
    ))

;; game -> game
;; add invaders randomly, advance current invaders, and advance shot missiles

; (define (advance-game g) g)

(define (advance-game s)
  (if (any-invader-offscreen (game-invaders s))
      s                                        ; game over (termination condition)
      (handle-shoot (tick-game s))
      )
  )


;; ListOfInvader -> Boolean
;; produces true if one or more invaders in ListOfInvader went off screen
(check-expect (any-invader-offscreen empty) false)
(check-expect (any-invader-offscreen (cons INV-CTR-Y (cons INV-JB-BEDGE (cons INV-ON-BEDGE  empty)))) false)
(check-expect (any-invader-offscreen (cons INV-CTR-Y (cons INV-ON-BEDGE (cons INV-OFF-BEDGE empty)))) true) ; last one went off 
                                       
; (define (any-invader-offscreen loi) false)   ; stub

(define (any-invader-offscreen loi)
  (ormap invader-offscreen loi))
#;
(define (any-invader-offscreen loi)
  (cond [(empty? loi) false]         ; there should be something better (like NULL)
        [else
         (or (invader-offscreen (first loi))
             (any-invader-offscreen (rest loi)))]
        )
  )



;; invader -> Boolean
;; produces true if invader has went off-screen (past HEIGHT)
(check-expect (invader-offscreen     INV-CTR-Y) false)
(check-expect (invader-offscreen  INV-ON-BEDGE) false)
(check-expect (invader-offscreen INV-OFF-BEDGE)  true)

; (define (invader-offscreen i) false)
(define (invader-offscreen invader)
  (> (invader-y invader) HEIGHT))

;; game -> game
;; if missile hit target, produces a game with both taken off screen
(check-expect (handle-shoot (make-game empty empty T0)) (make-game empty empty T0))
(check-expect (handle-shoot (make-game (cons INV-CTR-Y (cons INV-JB-BEDGE empty)) (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty)) T1))   ; case missile exactly hit INV-CTR-Y
              (make-game                 (cons INV-JB-BEDGE empty)  (cons M-ON-NOT-CTR-Y                       empty ) T1))  
(check-expect (handle-shoot (make-game (cons INV-CTR-Y (cons INV-JB-BEDGE empty)) (cons M-ON-NOT-CTR-Y (cons M-HIT>-INV-CTR-Y empty)) T1))  ; case missile > hit INV-CTR-Y
              (make-game                 (cons INV-JB-BEDGE empty)  (cons M-ON-NOT-CTR-Y                        empty ) T1))

; (define (handle-shoot g) g)
(define (handle-shoot s)
  (cond [(or (empty? (game-invaders s))
             (empty? (game-missiles s)))
         s]
        [else (make-game
               (invaders-handle-shoot (game-invaders s) (game-missiles s))
               (missiles-handle-shoot (game-invaders s) (game-missiles s))
               (game-tank s))]))

;; ListOfInvader ListOfMissile -> ListOfInvader
;; produce list of invaders after filtering out any invader got shot (if any)
(check-expect (invaders-handle-shoot empty empty) empty)
(check-expect (invaders-handle-shoot (cons INV-CTR-Y (cons INV-JB-BEDGE empty)) (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty)))
              (cons INV-JB-BEDGE empty))
; (define (invaders-handle-shoot loi lom) loi)
(define (invaders-handle-shoot loi lom)
  (cond [(empty? loi) empty]
        [(empty? lom)   loi]
        [else
         (if (any-hit-invader? (first loi) lom)
             (invaders-handle-shoot (rest loi) lom)
             (cons (first loi) (invaders-handle-shoot (rest loi) lom)))
         ]))

;; inavder ListOfMissile -> Boolean
;; return true if invader is shoot (within HIT-RANGE to any missile in ListOfMissile)
(check-expect (any-hit-invader? INV-CTR-Y empty) false)
(check-expect (any-hit-invader? INV-CTR-Y (cons M-ON-NOT-CTR-Y empty)) false)
(check-expect (any-hit-invader? INV-CTR-Y (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty))) true)

; (define (any-hit-invader? i lom) false)

(define (any-hit-invader? i lom)
  (cond [(empty? lom) false]
        [else
         (or (within-hit-range? i (first lom))
             (any-hit-invader? i (rest lom)))]
        )
  )
;; invader missile -> Boolean
;; return true if missile and invader are within HIT-RANGE, false otherwise
(check-expect (within-hit-range? INV-CTR-Y      M-ON-NOT-CTR-Y) false)   ; invader at center and missile not center
(check-expect (within-hit-range? INV-JB-LEDGE  M-HIT-INV-CTR-Y) false)   ; invader at left edge and missile at center
(check-expect (within-hit-range? INV-CTR-Y     M-HIT-INV-CTR-Y)  true)   ; exactly hit CTR-Y
(check-expect (within-hit-range? INV-CTR-Y    M-HIT>-INV-CTR-Y)  true)   ; case > hit CTR-Y

; (define (within-hit-range? i m) false)
(define (within-hit-range? i m)
  (and (<= (abs (- (invader-x i) (missile-x m))) HIT-RANGE)
       (<= (abs (- (invader-y i) (missile-y m))) HIT-RANGE)))

;; --------------------------------------------------------------------- This part is kind of repeatition - exactly like the inavder-handle-shoot but for missiles
;; ListOfInvader ListOfMissile -> ListOfMissile
;; produce list of missiles after filtering out any missile that hit target (if any)
(check-expect (missiles-handle-shoot empty empty) empty)
(check-expect (missiles-handle-shoot (cons INV-CTR-Y (cons INV-JB-LEDGE empty)) (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty)))
              (cons M-ON-NOT-CTR-Y empty))
; (define (missiles-handle-shoot loi lom) loi)
(define (missiles-handle-shoot loi lom)
  (cond [(empty? lom) empty]
        [(empty? loi)   lom]
        [else
         (if (any-hit-missile? (first lom) loi)
             (missiles-handle-shoot loi (rest lom))
             (cons (first lom) (missiles-handle-shoot loi (rest lom))))
         ]))

;; missile ListOfInvader -> Boolean
;; return true if missile shoot an invader (within HIT-RANGE to any invader in ListOfInvader)
(check-expect (any-hit-missile? M-HIT-INV-CTR-Y                                     empty) false)
(check-expect (any-hit-missile? M-ON-NOT-CTR-Y                     (cons INV-CTR-Y empty)) false)
(check-expect (any-hit-missile? M-HIT-INV-CTR-Y (cons INV-JB-LEDGE (cons INV-CTR-Y empty))) true)

; (define (any-hit-missile? m lom) false)

(define (any-hit-missile? m loi)
  (cond [(empty? loi) false]
        [else
         (or (within-hit-range? (first loi) m)
             (any-hit-missile? m (rest loi)))]
        )
  )
; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;; game -> game
;; automatically update positions of invaders, missiles and tanks over time
(check-expect (tick-game (make-game                 empty                empty             T0))
              (           make-game (next-invaders empty) (next-missiles empty) (tick-tank T0))
              )
(check-expect (tick-game (make-game                 (cons INV-CTR-Y (cons INV-JB-LEDGE empty))                (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty))             T1))
              (           make-game (next-invaders (cons INV-CTR-Y (cons INV-JB-LEDGE empty))) (next-missiles (cons M-ON-NOT-CTR-Y (cons M-HIT-INV-CTR-Y empty))) (tick-tank T1))
              )
(check-expect (tick-game (make-game                 (cons INV-CTR-Y (cons INV-JB-LEDGE empty))                (cons M-ON-NOT-CTR-Y (cons M-HIT>-INV-CTR-Y empty))             T2))
              (           make-game (next-invaders (cons INV-CTR-Y (cons INV-JB-LEDGE empty))) (next-missiles (cons M-ON-NOT-CTR-Y (cons M-HIT>-INV-CTR-Y empty)))  (tick-tank T2))
              )      
; (define (tick-game g) g)

(define (tick-game s)
  (make-game (next-invaders (game-invaders s))
             (next-missiles (game-missiles s))
             (tick-tank (game-tank s))))

;; ListOfInvader -> ListOfInvader
;; advance invaders in ListOfInvader to their next-positions and add more invaders per INVADE-RATE

; (define (next-invaders loi) loi)
(define (next-invaders loi)
  (add-invaders (tick-invaders loi))
  )

;; ListOfInvader -> ListOfInvader
;; may add invader to ListOfInvader depending on INVADE-RATE
;; !!! - don't know how to test
; (define (add-invaders loi) loi)
(define (add-invaders loi)
  (if (< (random (* (floor (/ INVADE-RATE 2)) INVADE-RATE)) INVADE-RATE)     ;; my pseudo bad style way to enforce INVADE-RATE, 28 is default on-tick ticks/second rate
      (cons (make-invader (random WIDTH) 0 1) loi)
      loi)
  )
 


;; ListOfInvader -> ListOfInvader
;; advance each invader in ListOfInvader by INVADER-SPEED-X and INVADER-SPEED-Y
;; with invader bouncing off back if hit right (invader-dx become -1) or left edge (invader-dx become 1)
(check-expect (tick-invaders empty) empty)
(check-expect (tick-invaders (cons INV-CTR-Y
                                   (cons INV-JB-LEDGE
                                         (cons INV-ON-REDGE
                                               empty))))
              (cons (make-invader (+ (invader-x INV-CTR-Y) (* (invader-dx INV-CTR-Y) INVADER-X-SPEED)) (+ (invader-y INV-CTR-Y)    INVADER-Y-SPEED)    (invader-dx INV-CTR-Y)) ; add speeds
                    (cons (make-invader (+ (invader-x INV-JB-LEDGE) (* (invader-dx INV-JB-LEDGE) INVADER-X-SPEED)) (+ (invader-y INV-JB-LEDGE) INVADER-Y-SPEED) (invader-dx INV-JB-LEDGE)) ; add speeds
                          (cons (make-invader (+ (invader-x INV-ON-REDGE) (* -1 INVADER-X-SPEED)) (+ (invader-y INV-ON-REDGE) INVADER-Y-SPEED)                        -1) 
                                empty))))

                             
; (define (tick-invaders loi) loi)

(define (tick-invaders loi)
  (cond [(empty? loi) empty]
        [else
         (cons (tick-invader (first loi))
               (tick-invaders (rest loi)))]
        )
  )

;; invader -> invader
;; advance invader to its next x,y position with INVADER-X-SPEED and INVADER-Y-SPEED in direction dx and bouncing back if hit edge
(check-expect (tick-invader INV-CTR-Y)
              (make-invader       (+ (invader-x INV-CTR-Y)      (* (invader-dx INV-CTR-Y) INVADER-X-SPEED)) (+ (invader-y INV-CTR-Y)    INVADER-Y-SPEED)    (invader-dx INV-CTR-Y))) ; add speeds
(check-expect (tick-invader INV-JB-LEDGE)
              (make-invader (+ (invader-x INV-JB-LEDGE)  (* INVADER-X-SPEED (invader-dx INV-JB-LEDGE))) (+ (invader-y INV-JB-LEDGE) INVADER-Y-SPEED) (invader-dx INV-JB-LEDGE))) ; add speeds
(check-expect (tick-invader INV-ON-REDGE)
              (make-invader (+                    WIDTH  (* -1 INVADER-X-SPEED)) (+ (invader-y INV-ON-REDGE) INVADER-Y-SPEED)                        -1)) ; invert dx and dx * speed-x
(check-expect (tick-invader INV-ON-LEDGE)
              (make-invader (+                        0  (* 1 INVADER-X-SPEED)) (+ (invader-y INV-ON-LEDGE) INVADER-Y-SPEED)                         1)) ; invert dx and dx * speed-x
; (define (tick-invader i) i)
(define (tick-invader i)
  (cond [(<= (invader-x i) 0) (make-invader 
                               (+ 0 INVADER-X-SPEED)
                               (+ (invader-y i) INVADER-Y-SPEED)
                               1)
                              ] ; left edge casE
        [(>= (invader-x i) WIDTH) (make-invader
                                   (- WIDTH INVADER-X-SPEED)
                                   (+ (invader-y i) INVADER-Y-SPEED)
                                   -1)] ; right edge case
        [else
         (make-invader
          (+ (* INVADER-X-SPEED (invader-dx i)) (invader-x i))
          (+ (invader-y i) INVADER-Y-SPEED)
          (invader-dx i))]  ; off-edge case
        ))


;; ListOfMissile -> ListOfMissile
;; advance each missile in ListOfMissile by MISSILE-SPEED and take missiles went across and off-screen out
(check-expect (next-missiles empty) empty)
(check-expect (next-missiles (cons M-ON-NOT-CTR-Y empty))
              (cons (make-missile (missile-x M-ON-NOT-CTR-Y) (- (missile-y M-ON-NOT-CTR-Y) MISSILE-SPEED)) empty)
              )
              
(check-expect (next-missiles (cons M-JB-TEDGE (cons M-ON-TEDGE (cons M-OFF empty))))
              (cons (make-missile (missile-x M-JB-TEDGE) (- (missile-y M-JB-TEDGE) MISSILE-SPEED)) empty
                    ))

; (define (next-missiles lom) lom)
(define (next-missiles lom)
  (onscreen-only (tick-missiles lom))
  )

;; ListOfMissile -> ListOfMissile
;; advance each missile in ListOfMissile by MISSILE-SPEED
(check-expect (tick-missiles empty) empty)
(check-expect (tick-missiles (cons M-JB-TEDGE (cons M-ON-TEDGE (cons M-OFF empty))))
              (cons (make-missile (missile-x M-JB-TEDGE) (- (missile-y M-JB-TEDGE) MISSILE-SPEED))
                    (cons (make-missile (missile-x M-ON-TEDGE) (- (missile-y M-ON-TEDGE) MISSILE-SPEED))
                          (cons (make-missile (missile-x M-OFF) (- (missile-y M-OFF) MISSILE-SPEED))
                                empty))))
; (define (tick-missiles lom) lom)

(define (tick-missiles lom)
  (fold cons empty (map tick-missile lom)))
#;
(define (tick-missiles lom)
  (cond [(empty? lom) empty]
        [else
         (cons (tick-missile (first lom))
               (tick-missiles (rest lom)))]
        )
  )

;; missile -> missile
;; advance missile to its next position by MISSILE-SPEED
(check-expect (tick-missile M-JB-TEDGE) (make-missile (missile-x M-JB-TEDGE) (- (missile-y M-JB-TEDGE) MISSILE-SPEED)))
(check-expect (tick-missile M-OFF) (make-missile (missile-x M-OFF) (- (missile-y M-OFF) MISSILE-SPEED)))

; (define (tick-missile m ) m)
(define (tick-missile m)
  (make-missile
   (missile-x m)
   (- (missile-y m) MISSILE-SPEED)))

;; lom -> lom
;; given ListOfMissiles, filter out missiles that went off-screen 
(check-expect (onscreen-only empty) empty)
(check-expect (onscreen-only (cons M-JB-TEDGE (cons M-ON-TEDGE (cons M-OFF empty))))
              (cons M-JB-TEDGE (cons M-ON-TEDGE empty)))
                             
; (define (onscreen-only lom) lom)
(define (onscreen-only lom)
  (cond [(empty? lom) empty]
        [else
         (if  (onscreen? (first lom))
              (cons (first lom) (onscreen-only (rest lom)))
              (onscreen-only (rest lom)))]
        )
  )
;; missile -> Boolean
;; return true if missile still onscreen, false if went off top-edge\
;; !!!
; (define (onscreen? m) false)

(define (onscreen? m)
  (<= 0 (missile-y m) HEIGHT)
  )

;; tank -> tank
;; move tank by TANK-SPEED to right (tank-dir = 1) or left (tank-dir = -1)
(check-expect (tick-tank T0) (make-tank (+ (tank-x T0) (* (tank-dir T0) TANK-SPEED)) (tank-dir T0)))
(check-expect (tick-tank T1) (make-tank (+ (tank-x T1) (* (tank-dir T1) TANK-SPEED)) (tank-dir T1)))
(check-expect (tick-tank (make-tank WIDTH 1)) (make-tank WIDTH 1))
(check-expect (tick-tank (make-tank WIDTH 1)) (make-tank WIDTH 1))

; (define (tick-tank t) t)
(define (tick-tank t)
  (cond [(and (<= (tank-x t)     0) (= (tank-dir t) -1)) (make-tank 0    -1)]
        [(and (>= (tank-x t) WIDTH) (= (tank-dir t)  1)) (make-tank WIDTH 1)]
        [else
         (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) (tank-dir t))]))

; ==================
;; Functions part 2

;; game -> Image
;; render game state (invaders, missiles, and tank) on screen

(check-expect (render-game (make-game empty empty T0))
              (place-image TANK (tank-x T0) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))                    
(check-expect (render-game (make-game (cons I1 empty) (cons M1 empty) T1))
              (render-invaders (cons I1 empty)
                               (render-missiles (cons M1 empty)
                                                (render-tank T1
                                                             BACKGROUND)
                                                )))
(check-expect (render-game (make-game (cons I1 (cons I2 empty)) (cons M1 (cons M1 empty)) T1))
              (render-invaders (cons I1 (cons I2 empty))
                               (render-missiles (cons M1 (cons M1 empty))
                                                (render-tank T1
                                                             BACKGROUND)
                                                )))

;(define (render-game g) BACKGROUND)

(define (render-game s)
  (render-invaders (game-invaders s)
                   (render-missiles (game-missiles s)
                                    (render-tank (game-tank s)
                                                 BACKGROUND))))
;; ListOfInvader Image -> Image
;; render invaders in ListOfInvader as elements to the given image
(check-expect (render-invaders empty BACKGROUND) BACKGROUND)
(check-expect (render-invaders (cons I1 (cons I2 empty)) BACKGROUND)
              (place-image INVADER (invader-x I2) (invader-y I2) (place-image INVADER (invader-x I1) (invader-y I1) BACKGROUND)))

; (define (render-invaders loi img) BACKGROUND)

(define (render-invaders loi img)
  (cond [(empty? loi) img]
        [else
         (render-invader (first loi)
                         (render-invaders (rest loi) img ))]
        )
  )

;; invader Image -> image
;; render invader on image at invader-x and invader-y
(check-expect (render-invader I1 BACKGROUND)
              (place-image INVADER (invader-x I1) (invader-y I1) BACKGROUND))

(define (render-invader i img)
  (place-image INVADER (invader-x i) (invader-y i) img)
  )

;; ListOfMissile Image -> Image
;; render missiles in ListOfMissile as elements to the given image
(check-expect (render-missiles empty BACKGROUND) BACKGROUND)
(check-expect (render-missiles (cons M1 (cons M2 empty)) BACKGROUND)
              (place-image MISSILE (missile-x M2) (missile-y M2) (place-image MISSILE (missile-x M1) (missile-y M1) BACKGROUND)))

; (define (render-missiles lom img) BACKGROUND)
(define (render-missiles lom img)
  (cond [(empty? lom) img]
        [else
         (render-missile (first lom)
                         (render-missiles (rest lom) img ))]
        )
  )
;; missile Image -> image
;; render missile on image at missile-x and missile-y
(check-expect (render-missile M1 BACKGROUND)
              (place-image MISSILE (missile-x M1) (missile-y M1) BACKGROUND))

(define (render-missile m img)
  (place-image MISSILE (missile-x m) (missile-y m) img)
  )
;; tank Image -> Image
;; render tank on the given image in tank-x and tank y
(check-expect (render-tank T1 BACKGROUND)
              (place-image TANK (tank-x T1) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))

; (define (render-tank t img) BACKGROUND)
(define (render-tank t img)
  (place-image TANK (tank-x t) (- HEIGHT TANK-HEIGHT/2) img))

; ===================
;; Functions part 3

;; game keyEvent -> game
;; move tank left or right with left and right arrows resp. and shoot missiles when space bar is pressed
(check-expect (handle-key G0 "up") G0)
(check-expect (handle-key G1 "down") G1)
(check-expect (handle-key G1 "left")
              (make-game (game-invaders G1) (game-missiles G1) (make-tank (tank-x (game-tank G1)) -1)))
      
(check-expect (handle-key G1 "right")
              (make-game (game-invaders G1) (game-missiles G1) (make-tank (tank-x (game-tank G1))  1)))

(check-expect (handle-key G1 " ")
              (make-game (game-invaders G1)
                         (cons (make-missile (tank-x (game-tank G1)) (- HEIGHT TANK-HEIGHT/2)) (game-missiles G1))
                         (game-tank G1)))

; (define (handle-key g ke) g)

(define (handle-key s ke)
  (cond [(key=? ke " ")
         (make-game (game-invaders s)
                    (cons (make-missile (tank-x (game-tank s)) (- HEIGHT TANK-HEIGHT/2)) (game-missiles s))
                    (game-tank s)
                    )]
        [(key=? ke "left")
         (make-game (game-invaders s)
                    (game-missiles s)
                    (make-tank (tank-x (game-tank s)) -1)
                    )]
        [(key=? ke "right")
         (make-game (game-invaders s)
                    (game-missiles s)
                    (make-tank (tank-x (game-tank s))  1)
                    )]
        [else s]
        ))


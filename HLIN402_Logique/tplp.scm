#lang racket

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1 Representation des propositions

(define F '(^ a b))
(define G '(! toto))
(define H '(<-> (^ a c) (v (! b) (-> c (^ Bot Top)))))

(define (neg? F) (eq? F '!))
(define (and? F) (eq? F '^))
(define (or? F) (eq? F 'v))
(define (imp? F) (eq? F '->))
(define (equ? F) (eq? F '<->))
(define (top? F) (eq? F 'Top))
(define (bot? F) (eq? F 'Bot))
(define (symbLog? F) (or (top? F) (bot? F) (and? F) (or? F) (neg? F) (imp? F) (equ? F)))
(define (conBin? F) (or (and? F) (or? F) (imp? F) (equ? F)))
(define (symbProp? F) (and (symbol? F) (not (symbLog? F))))
(define (atomicFbf? F) (or (symbProp? F) (top? F) (bot? F)))
(define (fbf? F)
  (cond ((atomicFbf? F) 					   #t )
        ((list? F) (cond ((and (= (length F) 2) (neg? (car F)))    (fbf? (cadr F)))
                         ((and (= (length F) 3) (conBin? (car F))) (and (fbf? (cadr F)) (fbf? (caddr F))) )
                         (else #f)))
        (else #f)))
(define (conRac F) (car F))
(define (fils F) (cadr F))
(define (filsG F) (cadr F))
(define (filsD F) (caddr F))
(define (negFbf? F) (and (not (atomicFbf? F)) (neg? (conRac F))))
(define (conjFbf? F) (and (not (atomicFbf? F)) (and? (conRac F))))
(define (disjFbf? F) (and (not (atomicFbf? F)) (or? (conRac F))))
(define (implFbf? F) (and (not (atomicFbf? F)) (imp? (conRac F))))
(define (equiFbf? F) (and (not (atomicFbf? F)) (equ? (conRac F))))
 
; Q1
;(display "\nQ1\n")
;(display "F => ") F
;(display "G => ") G
;(display "H => ") H
(define F1 '(<-> (^ a b) (v (! a) b)))
(define F2 '(v (! (v a (! b))) (! (-> a b))))
(define F3 '(^ (! (-> a (v a b))) (! (! (^ a (v b (! c)))))))
(define F4 '(^ (v (! a) (v b d)) (^ (v (! d) c) (^ (v c a) (^ (v (! c) b) (^ (v (! c) (! b)) (^ (v (! b) d))))))))

; Q2
;(display "\nQ2\n")
;(display "(fbf? F) => ") (fbf? F)
;(display "(fbf? G) => ") (fbf? G)
;(display "(fbf? H) => ") (fbf? H)
;(display "(fbf? '(! a b)) => ") (fbf? '(! a b))
;(fbf? F1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2 Syntaxe des propositions

;Q3
(define (nbc F)
  (cond ((atomicFbf? F) 0)
        ((negFbf? F) (+ 1 (nbc (fils F))))
        (else (+ 1 (nbc (filsG F)) (nbc (filsD F))))))

;Q4
(define (prof f)
   (cond ((atomicFbf? f) 0)
        ((negFbf? f) (+ 1 (prof (fils f))))
        (else (+ 1 (max (prof (filsG f)) (prof (filsD f)))))))

  

;Q5
(define (ensSP F)
  (cond ((atomicFbf? F) (set-add '() F))
        ((negFbf? F) (set-union '() (ensSP (fils F))))
        (else (set-union (set-union '() (ensSP (filsG F))) (ensSP (filsD F))))))
  
;Q6
(define (affiche F)
  (cond ((atomicFbf? F) (display F))
        ((negFbf? F)(begin
                      (display (conRac F))
                      (affiche (fils F))))
        (else (begin
                (display "(")
                (affiche (filsG F))
                (display (conRac F))
                (affiche (filsD F))
                (display ")")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 3 Semantique

(define I '((a . 0) (b . 1)))

;Q7
(define I1 '((a . 1) (b . 0) (c . 1))) 
(define I2 '((a . 0) (b . 0) (c . 0))) 
(define I3 '((a . 1) (b . 1) (c . 1))) 

;Q8
(define (intSymb s I)
  (cond ((eq? s 'Top) intTop)
        ((eq? s 'Bot) intBot)
        ((eq? s (car (set-first I))) (cdr (set-first I)))
        (else (intSymb s (cdr I)))))

;Q9
(define (intAnd v1 v2) (* v1 v2))
(define intTop 1)
(define intBot 0)
(define (intNeg v1) (modulo (+ v1 1) 2))
(define (intOr v1 v2) (max v1 v2))
(define (intImp v1 v2) (if (and (= v1 1) (= v2 0)) 0 1))
(define (intEqu v1 v2) (if (= v1 v2) 1 0))
 
;Q10

(define (valV F I)
  (cond ((atomicFbf? F) (intSymb F I))
        ((negFbf? F) (intNeg (valV (fils F) I)))
        ((conjFbf? F) (intAnd (valV (filsG F) I) (valV (filsD F) I)))
        ((disjFbf? F) (intOr (valV (filsG F) I) (valV (filsD F) I)))
        ((implFbf? F) (intImp (valV (filsG F) I) (valV (filsD F) I)))
        ((equiFbf? F) (intEqu (valV (filsG F) I) (valV (filsD F) I)))))
        
;Q11
(define (modele? F I)
  (= (valV F I) 1))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 4 Satisfiabilite, Validite

;Q12
(define EI '(((p . 0) (q . 0)) ((p . 0) (q . 1)) ((p . 1) (q . 0)) ((p . 1) (q . 1))))

;Q13
(define (ensInt ensSymb)
  (if (set-empty? ensSymb) '(())
      (let ( (EI (ensInt (cdr ensSymb))) )
                 (append (map (lambda (I) (set-add I (cons (car ensSymb) 0))) EI)
                         (map (lambda (I) (set-add I (cons (car ensSymb) 1))) EI)))))
                                 
;Q14

(define (satisfiable? F)
  (ormap (lambda (I) (modele? F I)) (ensInt (ensSP F))))

;Q15

(define (valide? F)
  (andmap (lambda (I) (modele? F I)) (ensInt (ensSP F))))

;Q16

(define (insatisfiable? F)
  (set-empty? (filter (lambda (I) (modele? F I)) (ensInt (ensSP F)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 5 Equivalence, Consequence

;Q17

(define (equivalent1? F1 F2)
  (andmap (lambda (I) (= (valV F1 I) (valV F2 I))) (ensInt (set-union (ensSP F1) (ensSP F2)))))

;Q17 bis

(define (equivalent2? F1 F2)
  (valide? (list '<-> F1 F2)))
  
;Q18

(define (consequence2? F1 F2)
  (insatisfiable? (list '^ F1 (list '! F2))))
  
;Q19

(define (ensSPallFbf EF)
  (if (empty? EF)
      '()
      (set-union (ensSP (car EF)) (ensSPallFbf (cdr EF)))))

;Q20

(define (modeleCommun? EF I)
  (andmap (lambda (F) (modele? F I)) EF))

;Q21

(define (contradictoire? EF)
  (not (ormap (lambda (I) (modeleCommun? EF I)) (ensInt (ensSPallFbf EF)))))

;Q22

(define (consequence? EF F)
  (andmap (lambda (I) (if (modeleCommun? EF I) (modele? F I) #t)) (ensInt (set-union (ensSPallFbf EF) (ensSP F)))))

;(define (consequence3? EF F)
;  (contradictoire? (cons (list '! F) EF)))

;Q23
(define (conjonction EF) ; EF est une ensemble de fbf
  (cond  ((set-empty? EF) 'Top)
         ((set-empty? (set-rest EF)) (set-first EF))
         (else (list '^ (set-first EF) (conjonction (set-rest EF))))))

(define (consequenceV? EH C)
  (valide? (cons '-> (list (conjonction EH) C))))
   
;Q24

(define (consequenceI? EF F)
  (insatisfiable? (cons '^ (list (cons '! (list F)) (conjonction EF)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 6 Mise sous forme conjonctive

;Q25
(define (oteEqu F)
  (cond ((atomicFbf? F) F)
        ((negFbf? F) (list '! (oteEqu (fils F))))
        ((not (equiFbf?  F)) (list (conRac F) (oteEqu (filsG F)) (oteEqu (filsD F))))
        (else  ; c'est <->
         (cons '^ (list (cons '-> (list (oteEqu (filsG F)) (oteEqu (filsD F)))) (cons '-> (list (oteEqu (filsD F)) (oteEqu (filsG F)))))))))
         
;Q26

(define (oteImp F)
  (cond ((atomicFbf? F) F)
        ((negFbf? F) (list '! (oteImp (fils F))))
        ((not (implFbf?  F)) (cons (conRac F) (list (oteImp (filsG F)) (oteImp (filsD F)))))
        (else  ; c'est ->
         (cons 'v (list (list '! (oteImp (filsG F))) (oteImp (filsD F)))))))
         

;Q27

(define (oteCste F)
  (cond ((symbProp? F) F)
        ((top? F) (cons 'v (list (list '! 'p) 'p)))
        ((bot? F) (cons '^ (list (list '! 'p) 'p)))
        ((negFbf? F) (list '! (oteCste (fils F))))
        (else (cons (conRac F) (list (oteCste (filsG F)) (oteCste (filsD F)))))))
          
;Q28
(define (redNeg F)
  (cond ((symbProp? F) F) ; cas d'un symbole propositionnel
        ((not (negFbf? F)) (list (conRac F) (redNeg (filsG F))  (redNeg (filsD F)))) ; cas d'un connecteur racine ^ ou v
        (else  ; cas de la négation en connecteur racine ==> on regarde son fils
         (cond ((symbProp? (fils F)) F) ; littéral négatif
               ((negFbf? (fils F)) (redNeg (fils (fils F)))) ; deux négations ==> équivalence de la double négation 
               ((conjFbf? (fils F)) (list 'v (redNeg (list '! (filsG (fils F)))) (redNeg (list '! (filsD (fils F)))))) ; négation d'une conjonction ==> équivalence de De Morgan
               (else (list '^ (redNeg (list '! (filsG (fils F)))) (redNeg (list '! (filsD (fils F)))))))))) ; négation d'une disjonction ==> équivalence de De Morgan

;Q29
(define (distOu F)
  (cond ((symbProp? F) F)
        ((negFbf? F) (list '! (distOu (fils F))))
        ((conjFbf? F) (list '^ (distOu (filsG F)) (distOu (filsD F))))
        (else          ; c'est donc une disjonction
         (let ( (Fg (distOu (filsG F))) (Fd (distOu (filsD F))) )  
           (cond ((conjFbf? Fg)	(list '^   (distOu (list 'v (filsG Fg) Fd))   (distOu (list 'v (filsD Fg) Fd))))
                 ((conjFbf? Fd)	(list '^   (distOu (list 'v Fg (filsG Fd)))   (distOu (list 'v Fg (filsD Fd)))))
                 (else 			; il n'y a plus de ^ dans les sous-formules
                  (list 'v   Fg   Fd)))))))

;Q30

(define (formeConj F)
  (distOu (redNeg (oteCste (oteImp (oteEqu F))))))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 7 Mise sous forme clausale

; Exemple de clause et forme clausale
(define exClause '( p (! r) t)) 
(define exFormeClausale '( (p (! p))  (p q (! r))  ((! r) s)  (p (! r) t)  (p ( ! r))  (r (! t))  (s t) (p (! s))   ((! p ) (! s))))

; Fonction permettant de tester si une fbf est un littéral et d'obtenir le littéral opposé d'un littéral
(define (litteral? F) (or (symbProp? F) (and (negFbf? F) (symbProp? (fils F)))))
(define (oppose L) (if (symbProp? L) (list '! L) (fils L)))
  
; Fonctions permettant de manipuler des ensembles d'ensembles
(define (setSet-member? EC C)
  (cond ((set-empty? EC) #f)
        ((set=? (set-first EC) C) #t)
        (else (setSet-member? (set-rest EC) C))))

(define (setSet-add EC C)
  (cond ((set-empty? EC) (list C))
        ((set=? (set-first EC) C) EC)
        (else (set-add (setSet-add (set-rest EC) C) (set-first EC)))))

(define (setSet-union EC1 EC2)
  (if (set-empty? EC2) EC1
      (setSet-union (setSet-add EC1 (set-first EC2)) (set-rest EC2))))

;Q31

(define (transClause F)
  (cond ((litteral? F) (list F))
        ((negFbf? F) (transClause (fils F)))
        (else (set-union (transClause (filsG F)) (transClause (filsD F))))))

;Q32

(define (transEnsClause F)
  (if (conjFbf? F)
      (setSet-union (transEnsClause (filsG F)) (transEnsClause (filsD F)))
      (list (transClause F))))

;Q33

(define (formeClausale F)
  (transEnsClause (formeConj F)))

;Q34

(define (tautologique C)
  (cond
    ((empty? C) #f)
    ((set-member? (cdr C) (oppose (car C))) #t)
    (else (tautologique (cdr C)))))

;Q35

(define (subsume C1 C2) ;test si C1 subsume C2
  (cond
    ((empty? C1) #t)
    ((set-member? C2 (car C1)) (subsume (cdr C1) C2))
    (else #f)))

;Q36

(define (simplifier FC)
  (letrec ((f (lambda (FC2 sub bool)
                (if bool
                    (if (empty? FC2) (f FC sub #f)
                        (f (cdr FC2) (setSet-union sub (filter (lambda (C) (and (not (set=? (car FC2) C)) (subsume (car FC2) C))) FC)) bool))
                    (cond
                      ((empty? FC2) '())
                      ((set-member? sub (car FC2)) (f (cdr FC2) sub bool))
                      ((tautologique (car FC2)) (f (cdr FC2) sub bool))
                      (else (setSet-union (list (car FC2)) (f (cdr FC2) sub bool))))))))
    (f FC '() #t)))

;;;;;;;;;;;;;;;
; 8  Resolution

;Q37

(define (resolvable C1 C2)
  (letrec ((f (lambda (c1 bool)
                (cond
                  ((empty? c1) bool)
                  ((and (not bool) (set-member? C2 (oppose (car c1)))) (f (cdr c1) #t))
                  ((and bool (set-member? C2 (oppose (car c1)))) #f)
                  (else (f (cdr c1) bool))))))
    (f C1 #f)))

;Q38

(define (resolvante C1 C2)
  (if (resolvable C1 C2)
      (letrec ((f (lambda (c1)                    
                    (cond
                      ((set-member? C2 (oppose (car c1))) c1)
                      (else (f (cdr c1))))))
               (e (car (f C1))))
        (set-remove (set-remove (set-union C1 C2) e) (oppose e)))
  'err))               
        

;Q39

(define (ClauseVideParResolution FC)
  (letrec ((f (lambda (fc acc save)
                (if (empty? fc)
                    (if (set=? acc save) ;on compare la nouvelle fc et l'ancienne
                        (ormap (lambda (c) (set=? c '())) acc)
                        (if (ormap (lambda (c) (set=? c '())) acc) #t
                          (begin
                            (display "                                                   ")
                            (display acc)
                            (f acc acc acc)))) ;on relance avec la nouvelle forme clausale
                    (f (cdr fc) (set-union (filter (lambda (c) (not (eq? c 'err))) (map (lambda (c) (resolvante c (car fc))) acc)) acc) save)))))
    (f FC FC FC)))

;Q40

(define (satisfiableResol F)
  (not (ClauseVideParResolution (simplifier (formeClausale F)))))

(define (valideResol F)
  (ClauseVideParResolution (simplifier (formeClausale (list '! F)))))

(define (consequenceResol EH C)
  (ClauseVideParResolution (simplifier (setSet-union (formeClausale (conjonction EH)) (formeClausale (list '! C))))))


;;;;;;;;;;;;;;;
; 9 Application

;Q41

;Dr Olive O
;Mlle Rose R
;Colonel Moutarde M

;chandelier H
;clef Anglaise A
;corde D

;veranda V
;cuisine C
;bureau B

(define i1 '(v (^ H (^ (! A) (! D))) (v (^ A (^ (! H) (! D))) (^ D (^ (! H) (! A)))))) 
(define i2 '(v (^ V (^ (! C) (! B))) (v (^ C (^ (! V) (! B))) (^ B (^ (! V) (! C))))))
(define i3 '(-> B (! A)))
(define i4 '(-> R (^ C (! D))))
(define i5 '(-> M (! A)))
(define i6 '(! (^ R M)))
(define i7 '(-> (! R) (v B A)))
(define i8 '(<-> V A))
(define i9 '(-> (v (! H) O) R))
(define i10 '(v B C))
(define i11 '(-> C D))
(define i12 '(v O (v R M)))
(define Ei (list i1 i2 i3 i4 i5 i6 i7 i8 i9 i10 i11 i12))

(define s1 '(^ M (^ B H)))
(define s2 '(^ O (^ R (^ C D))))

;Noémie a raison et Arthur a tort

;;;;;;;;;;;;;;;
; 10 Evaluation


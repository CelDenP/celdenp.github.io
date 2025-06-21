;;;CADALYST 07/06  Tip2129: VDLock.lsp  Viewport Lock and Unlock    (c) Theodorus Winata 

;;; Function: Lock/Unlock Viewports
;;; Command Line: VDLock
;;; Description: By locking the Display you ensure your
;;;              model view will not accidentally shift
;;;              if you activate the viewport
;;;
;;; Developed by Theodorus Winata
;;; April 2006
;;;

(defun get-objects ()
  (setq DPL (vlax-ename->vla-object (ssname SSG CNT))
    CNT (1+ CNT)
  );;setq
);;get-objects

;;;********** Error Handler **********
(defun ERR (msg)
  (princ)
);;ERR

;;;********** Main Program **********
(defun C:VDLock (/ CME CNT DPL *ERROR* OP SSG)
  (vl-load-com)
  (setq *ERROR* ERR
        CME (getvar "CMDECHO")
  );;setq
  (setvar "CMDECHO" 0)
  (if (= (getvar "TILEMODE") 1) (setvar "TILEMODE" 0))
  (command "pspace")
  (setq SSG (ssget "X" (list (cons 0 "VIEWPORT")))
    CNT 0
  );;setq
  (initget "Yes No")
  (setq OP (getkword "Блокировка видовых экранов [Yes/No] <Y>: "))
  (cond
    ((or (= OP nil) (= OP "Yes"))
      (repeat (sslength SSG)
        (get-objects)    
    (vla-put-DisplayLocked DPL :vlax-true)
      );;repeat
      (prompt "\n\tВсе видовые экраны заблокированы!")
    );;"Yes"
    ((= OP "No")
      (repeat (sslength SSG)
    (get-objects)
    (vla-put-DisplayLocked DPL :vlax-false)
      );;repeat
      (prompt "\n\tВсе видовые экраны разблокированы!")
    );;"No"
  );;cond
  (setvar "CMDECHO" CME)
  (princ)
);;C:VDLock
(princ
;  (strcat
;    "  "
;    "\"")!"
;  )
)
(princ)

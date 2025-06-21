;;Multi OFFset to 2 side
(defun C:OFFSET2 (/ d obj ent adoc *error* DelObjList ss)
  (defun *error* (msg)(princ msg)(vla-endundomark adoc))
  (vl-load-com)(setvar "CMDECHO" 0)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object))) ;_ end of setq
  (if (null *OFF2*)(setq *OFF2* (abs (getvar "OFFSETDIST")))) ;_ end of if
  (if (zerop *OFF2*)(setq *OFF2* 1)) ;_ end of if
  (setq d (getvar "UNDOCTL"))
  (cond ((= d 0) (vl-cmdf "_.UNDO" "_All"))
        ((= d 3) (vl-cmdf "_.UNDO" "_Control" "_All"))
        (t nil)
  ) ;_ end of cond
  (setq d nil) (vla-startundomark adoc)
  (while (not (numberp d))
    (princ
      (strcat "\n (Слой: "
              (if *OFFLAY*
                "Текущий)"
                "Объект)"
              ) ;_ end of if
              " Величина смещения или слой объектов [Объект/Текущий] <"
      ) ;_ end of strcat
    ) ;_ end of princ
    (princ *OFF2*)(princ ">: ")
    (initget 6 "Текущий Объект Current Object _Current Object Current Object") ;_ end of initget
    (if (null (setq d (getdist)))(setq d *OFF2*)) ;_ end of if
    (cond ((= d "Object") (setq *OFFLAY* nil)) ;_Слой объекта
          ((= d "Current") (setq *OFFLAY* t)) ;_Слой текущий
          (t nil)
    ) ;_ end of cond
  ) ;_ end of while
  (setq *OFF2* d) ;_ end of setq
  (while (setq ss nil
               ss (ssget "_:L")
         ) ;_ end of setq
    (setq d '-1)
    (while (setq obj (ssname ss (setq d (1+ d))))
      (setq ent (vlax-ename->vla-object obj))
      (cond
        ((and (vlax-write-enabled-p ent)
              (vlax-method-applicable-p ent 'Offset)
         ) ;_ end of and
         (setq
           obj (append
                 (vlax-safearray->list
                   (vlax-variant-value (vla-offset ent *OFF2*))
                 ) ;_ end of vlax-safearray->list
                 (vlax-safearray->list
                   (vlax-variant-value (vla-offset ent (- 0 *OFF2*)))
                 ) ;_ end of vlax-safearray->list
               ) ;_ end of append
         ) ;_ end of setq
         (if *OFFLAY*
           (mapcar '(lambda (x) (vla-put-layer x (getvar "CLAYER")))
                   obj
           ) ;_ end of mapcar
         ) ;_ end of if
         (setq DelObjList (cons ent DelObjList))
        )
        (t (princ "\nНе удается создать объект, подобный данному: ")
           (princ (cdr(assoc 0(entget obj))))
         )
      ) ;_ end of cond
    ) ;_ end of while
  ) ;_ end of while
  (initget "Да Нет Yes No _Yes No Yes No")
  (if (= (getkword "\nУдалять исходные объекты? [Да/Нет] <Нет> : ")
         "Yes"
      ) ;_ end of =
    (mapcar '(lambda (x)
               (if (vlax-write-enabled-p x)
                 (vla-erase x)
               ) ;_ end of if
             ) ;_ end of lambda
            DelObjList
    ) ;_ end of mapcar
  ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
) ;_ end of defun
(princ "\nНаберите в командной строке MOFF2")
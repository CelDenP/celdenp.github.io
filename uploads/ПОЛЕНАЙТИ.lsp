(defun c:ПОЛЕНАЙТИ  (/ ent owner txt)

  ;|
*    Подсвечивает объект, с которого взято поле
*    Пример вызова:
(ПОЛЕНАЙТИ)
|;

  (vl-load-com)
  (if (and (= (type (setq ent (vl-catch-all-apply
                                (function
                                  (lambda ()
                                    (car (entsel "\nВыбери поле"))
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                                ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'ename
              ) ;_ end of =
           (setq ent (vlax-ename->vla-object ent))
           (vlax-property-available-p ent 'textstring)
           (not (vl-catch-all-error-p
                  (vl-catch-all-apply
                    (function
                      (lambda ()
                        (vla-fieldcode ent)
                        ) ;_ end of lambda
                      ) ;_ end of function
                    ) ;_ end of vl-catch-all-apply
                  ) ;_ end of vl-catch-all-error-p
                ) ;_ end of not
           (/= (setq txt (vla-fieldcode ent)) (vla-get-textstring ent))
           ) ;_ end of and
    (progn
      (vla-highlight
        (vla-objectidtoobject
          (vla-get-activedocument (vlax-get-acad-object))
          (atof (substr txt (+ 1 (strlen "_ObjId") (vl-string-search "_ObjId" txt))))
          ) ;_ end of vla-objectidtoobject
        :vlax-true
        ) ;_ end of vla-Highlight
      ) ;_ end of progn
    ) ;_ end of if
  (princ) ; Добавлено чтобы не выводило nil в командную строку
) ;_ end of defun
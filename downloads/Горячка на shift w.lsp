 (defun redef (/ sysvar)
  (setq sysvar (mapcar (function (lambda (x / tmp) (setq tmp (getvar (car x))) (setvar (car x) (cdr x)) (cons (car x) tmp))
                                 ) ;_ end of function
                       '(("cmdecho" . 0) ("menuecho" . 0) ("nomutt" . 1))
                       ) ;_ end of mapcar
        ) ;_ end of setq
  (vl-cmdf "_.undefine" "navswheel")
  (eval (read "(defun c:navswheel() (vl-cmdf \"МАСШТАБ"))"))
  (foreach item sysvar (setvar (car item) (cdr item)))
  (princ)
  ) ;_ end of defun
(redef)
(princ)
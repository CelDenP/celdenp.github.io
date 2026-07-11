(defun C:GAP (/ *error* adoc name_ent list_ent dim_value n1)
  (vl-load-com)
  (defun *error* (msg)
    (vla-endundomark adoc)
    (princ "Работа программы прервана пользователем")
  )
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  )
  (initget 6)
  (if (not _var_n)
    (setq _var_n0 200)
  )
  (setq	_var_n
	 (getint (strcat "\nВведите положительное целое число <"
			 (rtos _var_n0)
			 ">: "
		 )
	 )
  )
  (if (not _var_n)
    (setq _var_n _var_n0)
    (setq _var_n0 _var_n)
  )
  (setq name_ent (entsel "\nВыберите размер: "))
  (if name_ent
    (progn
      (setq list_ent (entget (car name_ent)))
      (while (not
	       (= (cdr (assoc 0 list_ent)) "DIMENSION")
	     )
	(setq name_ent (entsel "\nВыберите размер: "))
      )
      (setq list_ent  (entget (car name_ent))
	    dim_value (cdr (assoc 42 list_ent))
	    n1	      (rtos (/ dim_value _var_n) 2 0)
      )
      (entmod
	(subst
	  (cons	1
		(strcat	n1
			"x"
			(itoa _var_n)
			"=<>"
		)
	  )
	  (assoc 1 list_ent)
	  list_ent
	)
      )
    )
    (princ "Размер не выбран!")
  )
  (vla-endundomark adoc)
  (princ))








  (defun C:ПФЗ (/ *error* adoc name_ent list_ent dim_value n1)
  (vl-load-com)
  (defun *error* (msg)
    (vla-endundomark adoc)
    (princ "Работа программы прервана пользователем")
  )
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  )
  (initget 6)
  (if (not _var_n)
    (setq _var_n0 200)
  )
  (setq	_var_n
	 (getint (strcat "\nВведите положительное целое число <"
			 (rtos _var_n0)
			 ">: "
		 )
	 )
  )
  (if (not _var_n)
    (setq _var_n _var_n0)
    (setq _var_n0 _var_n)
  )
  (setq name_ent (entsel "\nВыберите размер: "))
  (if name_ent
    (progn
      (setq list_ent (entget (car name_ent)))
      (while (not
	       (= (cdr (assoc 0 list_ent)) "DIMENSION")
	     )
	(setq name_ent (entsel "\nВыберите размер: "))
      )
      (setq list_ent  (entget (car name_ent))
	    dim_value (cdr (assoc 42 list_ent))
	    n1	      (rtos (/ dim_value _var_n) 2 0)
      )
      (entmod
	(subst
	  (cons	1
		(strcat	n1
			"x"
			(itoa _var_n)
			"=<>"
		)
	  )
	  (assoc 1 list_ent)
	  list_ent
	)
      )
    )
    (princ "Размер не выбран!")
  )
  (vla-endundomark adoc)
  (princ))
(vl-load-com)
; Функция действия на событие описанное в реакторе
(defun pickfirstModified(reac data / )
  (if (cadr (ssgetfirst))
    (setq last_select_selection (cadr (ssgetfirst)))
    )
  )

(setq Misc_Reac (vlr-miscellaneous-reactor nil
          (list '(:VLR-pickfirstModified . pickfirstModified)
            )
          )
      )

(defun c:ПОСЛЕДНИЙ()
  (if (= (type last_select_selection) 'PICKSET)
    (if (> (sslength last_select_selection) 0)
      (progn
    (sssetfirst nil last_select_selection)
    (prompt "\n Последный сформированный набор восстановлен в переменнной last_select_selection")
    )
      (prompt "\n Последный сформированный набор пустой")
      )
    (prompt "\n На чертеже еще не было сформировано ни одного набора")
    )
  (princ)
  )
;------------------------------------------------------------
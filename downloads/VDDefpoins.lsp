(defun C:VDDEFPOINTS (/ vpLayer id1 pl)
  ;;;Перенести видовые экраны на слой
  ;;;Включить блокировку экрана
 (vl-load-com)
 (setq vpLayer "Defpoints")  ;;_Имя слоя видового экрана
(if (not(tblobjname "LAYER"  vpLayer)) 
(entmake (list (cons 0 "LAYER")
                 (cons 100 "AcDbSymbolTableRecord")
                 (cons 100 "AcDbLayerTableRecord")
                 (cons 2 vpLayer)
                 (cons 70 0)))
  )
    (mip:layer-status-save)
  (vlax-for lay (vla-get-layouts
                  (vla-get-activedocument (vlax-get-acad-object))
                ) ;_ end of vla-get-layouts
    (setq id1 nil)                                ; ignore the first vp
    (if (eq :vlax-false (vla-get-modeltype lay))
      (progn
        (princ (strcat "\n*** Лист - " (vla-get-name lay) "  ***"))
        (vlax-for obj (vla-get-block lay)         ; for each obj in layout
          (if (and (= (vla-get-objectname obj) "AcDbViewport")
                   (vlax-write-enabled-p obj)
                   (or id1 (not (setq id1 t))) ;_Пропускаем первый ВЭ
              ) ;_ end of and
            (progn
              (vla-put-layer obj vpLayer)  ;;; Видовой экран на слой
              (vla-put-color obj acbylayer) ;;; Цвет послою
              (vla-put-displaylocked obj :vlax-true) ;;;_ Включаем блокировку видового экрана
;;;Если ВЭ подрезан полилинией, туда же и полилинию
              (if (and (setq pl
                              (cdr (assoc 340
                                          (entget (vlax-vla-object->ename obj))
                                   ) ;_ end of assoc
                              ) ;_ end of cdr
                       ) ;_ end of setq
                       (setq pl (vlax-ename->vla-object pl))
                       (vlax-write-enabled-p pl)
                  ) ;_ end of and
                (progn                       ;;;Если ВЭ подрезан полилинией, туда же и полилинию
                  (vla-put-layer pl vpLayer)
                  (vla-put-color pl acbylayer)
                ) ;_ end of progn
              ) ;_ end of if
            ) ;_ end of progn
          ) ;_ end of if
        ) ;_ end of vlax-for
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of vlax-for
  (mip:layer-status-restore)
  (princ)
)
(defun mip:layer-status-restore ()
    (foreach item *MIP_LAYER_LST*
      (if (not (vlax-erased-p (car item)))
        (vl-catch-all-apply
          '(lambda ()
             (vla-put-lock
               (car item)
               (cdr (assoc "lock" (cdr item)))
             ) ;_ end of vla-put-lock
             (vla-put-freeze
               (car item)
               (cdr (assoc "freeze" (cdr item)))
             ) ;_ end of vla-put-freeze
           ) ;_ end of lambda 
        ) ;_ end of vl-catch-all-apply 
      ) ;_ end of if 
    ) ;_ end of foreach
    (setq *MIP_LAYER_LST* nil)
  ) ;_ end of defun 

  (defun mip:layer-status-save ()
    (setq *MIP_LAYER_LST* nil)
    (vlax-for item
                   (vla-get-layers
                     (vla-get-activedocument (vlax-get-acad-object))
                   ) ;_ end of vla-get-layers
      (setq *MIP_LAYER_LST*
             (cons (list item
                         (cons "freeze" (vla-get-freeze item))
                         (cons "lock" (vla-get-lock item))
                   ) ;_ end of cons 
                   *MIP_LAYER_LST*
             ) ;_ end of cons 
      ) ;_ end of setq 
      (vla-put-lock item :vlax-false)
      (if (= (vla-get-freeze item) :vlax-true)
        (vl-catch-all-apply
          '(lambda () (vla-put-freeze item :vlax-false))
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of if
    ) ;_ end of vlax-for
  ) ;_ end of defun 
(princ "\nType VpFind in command line")(princ)
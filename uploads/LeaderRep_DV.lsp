(vl-load-com)

(defun c:LeaderRep_DV ( / doc ss i ent obj hasDogleg dogLen contentType curDir)
  ;; Инициализация и старт группы отмены
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc)
  
  ;; Выборка всех мультивыносок
  (if (setq ss (ssget "X" '((0 . "MULTILEADER"))))
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        
        ;; 1. Обработка полки и отступа
        (setq hasDogleg (vl-catch-all-apply 'vla-get-DogLegged (list obj)))
        (setq dogLen (vl-catch-all-apply 'vla-get-DoglegLength (list obj)))
        
        (if (and (not (vl-catch-all-error-p hasDogleg))
                 (not (vl-catch-all-error-p dogLen)))
          (progn
            (if (or (= hasDogleg :vlax-false) (= hasDogleg 0))
              ;; Полка отключена: только обнуляем длину
              (vl-catch-all-apply 'vla-put-DoglegLength (list obj 0.0))
              (progn
                ;; Полка включена: переносим длину в отступ, отключаем полку, обнуляем длину
                (vl-catch-all-apply 'vla-put-LandingGap (list obj dogLen))
                (vl-catch-all-apply 'vla-put-DogLegged (list obj :vlax-false))
                (vl-catch-all-apply 'vla-put-DoglegLength (list obj 0.0))
              )
            )
          )
        )

        ;; 2. Фикс бага отображения (только для MText)
        (setq contentType (vl-catch-all-apply 'vla-get-ContentType (list obj)))
        (if (and (not (vl-catch-all-error-p contentType)) (= contentType 2))
          (progn
            (setq curDir (vl-catch-all-apply 'vla-get-TextAttachmentDirection (list obj)))
            (if (not (vl-catch-all-error-p curDir))
              (if (or (= curDir 0) (= curDir :vlax-false))
                (progn
                  ;; Горизонтально -> Вертикально -> Горизонтально
                  (vl-catch-all-apply 'vla-put-TextAttachmentDirection (list obj 1))
                  (vl-catch-all-apply 'vla-put-TextAttachmentDirection (list obj 0))
                )
                (progn
                  ;; Вертикально -> Горизонтально -> Вертикально
                  (vl-catch-all-apply 'vla-put-TextAttachmentDirection (list obj 0))
                  (vl-catch-all-apply 'vla-put-TextAttachmentDirection (list obj 1))
                )
              )
            )
          )
        )

        ;; Обновление графики
        (vl-catch-all-apply 'vla-update (list obj))
        
        (setq i (1+ i))
      )
      (princ (strcat "\n[LeaderRep_DV] Обработано мультивыносок: " (itoa (sslength ss))))
    )
    (princ "\n[LeaderRep_DV] Мультивыноски не найдены.")
  )
  
  (vla-EndUndoMark doc)
  (princ)
)

(princ "\nКоманда LeaderRep_DV загружена.")
(princ)
(defun C:СЧИТАТЬ ()
  (setq ss (ssget '((0 . "MULTILEADER")))) ; Выбираем только мультивыноски
  (if ss
    (progn
      (setq text_counts (make-text-count-list ss)) ; Создаем список (текст . количество)
      (if text_counts
        (progn
          (display-console text_counts) ; Выводим данные в консоль
        )
        (princ "\nНет мультивыносок с текстом.")
      )
    )
    (princ "\nМультивыноски не выбраны.")
  )
  (princ)
)

;; Функция для создания списка (текст . количество)
(defun make-text-count-list (ss)
  (setq text_list '())
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq mtext_obj (vlax-ename->vla-object ent))
    (setq mtext (vla-get-TextString mtext_obj))
    (if mtext
        (progn
            (setq found nil)
            (setq new_text_list '()) ; Создаем новый список для изменений
            (foreach item text_list
                (if (equal (car item) mtext)
                    (progn
                        (setq found t)
                        (setq new_text_list (append new_text_list (list (cons (car item) (1+ (cdr item))))))
                    )
                    (setq new_text_list (append new_text_list (list item))) ; Если не нашли, то вставляем старый
                )

            )
            (setq text_list new_text_list) ;Обновляем список после прохода по нему
            (if (not found)
                (setq text_list (append text_list (list (cons mtext 1))))
            )
            
        )
        (princ "\nМультивыноска без текста, пропускаем.")
    )
    
    (setq i (1+ i))
  )
  text_list
)

;; Функция для вывода данных в консоль
(defun display-console (text_counts)
  (princ "\n----- Текст | Количество -----")
  (princ "\n---------------------------")
  (foreach item text_counts
    (princ (strcat "\n" (car item) " | " (itoa (cdr item))))
  )
  (princ "\n---------------------------")
  (princ "\nГотово.")
  (princ)
)

(princ "\nКоманда СЧИТАТЬ загружена.")
(princ)
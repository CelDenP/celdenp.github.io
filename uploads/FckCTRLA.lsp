(defun redef (/ sysvar)
  ;; Сохраняем системные переменные и отключаем эхо, чтобы undefine прошел незаметно
  (setq sysvar (mapcar (function (lambda (x / tmp) (setq tmp (getvar (car x))) (setvar (car x) (cdr x)) (cons (car x) tmp))
                                 ) ;_ end of function
                       '(("cmdecho" . 0) ("menuecho" . 0) ("nomutt" . 1))
                       ) ;_ end of mapcar
        ) ;_ end of setq
  
  ;; Отменяем встроенные команды выбора всего (обе вариации, чтобы наверняка)
  (vl-cmdf "_.undefine" "ai_selall")
  (vl-cmdf "_.undefine" "selectall")

  ;; Переопределяем ai_selall через eval read, интегрируя логику с вопросом
  (eval (read "
    (defun c:ai_selall( / kw )
      (initget \"Да Нет _ Yes No\")
      (setq kw (getkword \"\\nВыбрать все? [Да/Нет] <Нет>: \"))
      (if (= kw \"Yes\")
        (progn
          ;; ssget \"_X\" выбирает всё, а фильтр (410 . CTAB) ограничивает выбор только текущим листом/моделью
          (sssetfirst nil (ssget \"_X\" (list (cons 410 (getvar \"CTAB\")))))
          (princ \"\\nВсе объекты выделены.\")
        )
        (princ \"\\nОтменено. Объекты не выбраны.\")
      )
      (princ)
    )
  "))
  
  ;; Дублируем функцию для команды SELECTALL (которую обычно вызывает Ctrl+A)
  (eval (read "(defun c:selectall() (c:ai_selall))"))

  ;; Восстанавливаем системные переменные на исходные
  (foreach item sysvar (setvar (car item) (cdr item)))
  (princ)
  ) ;_ end of defun

;; Запускаем функцию переопределения
(redef)
(princ)
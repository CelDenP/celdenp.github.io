

(vl-load-com)


(defun *error* (msg)
  (princ)
)



(defun c:ГЕОХРЕНЬ()
   (initget 1 "Полилиния Точки")
   (setq x (getkword "\nПостроить ведомость по [Полилиния/Точки]: ")) 
   (if (= x "Полилиния") (ExportInExcel) (geo_point_table)) 
);_end defun



(defun geo-create-object (AppString)  
  (vlax-create-object AppString)
);_end defun






(defun geo_get_distance (pnt1 pnt2) 
   (setq pnt1 (list (car pnt1) (cadr pnt1)))
   (setq pnt2 (list (car pnt2) (cadr pnt2)))
   (distance pnt1 pnt2) 
);_end defun


(defun geo_get_angle (pnt1 pnt2) 
   (setq pnt1 (list (car pnt1) (cadr pnt1)))
   (setq pnt2 (list (car pnt2) (cadr pnt2)))
   (angle pnt1 pnt2) 
);_end defun






(defun geo-add-text (TextString InsertionPoint Height Alignment Rotation / obj)
  (if (null Alignment) (setq Alignment acAlignmentLeft))
  (setq obj (vla-addtext 
                (vla-get-modelspace (vla-get-activedocument(vlax-get-acad-object))) TextString 
    (if (or (= Alignment acAlignmentAligned)  
            (= Alignment acAlignmentFit))          
        (vlax-3d-point (car InsertionPoint)) 
        (vlax-3d-point InsertionPoint)
     ) Height))
  (cond
    ((= Alignment acAlignmentLeft) (vla-put-rotation obj Rotation))
    ((or (= Alignment acAlignmentAligned)
         (= Alignment acAlignmentFit))
     (vla-put-alignment obj Alignment)
     (vla-put-textalignmentpoint obj (vlax-3d-point (cadr InsertionPoint)))
    )
    (T
      (vla-put-alignment obj Alignment)
      (vla-put-textalignmentpoint obj (vlax-3d-point InsertionPoint))
      (vla-put-rotation obj Rotation)
    )
    (vla-update obj)
  );_end cond
      
);_end defun





(defun geo-add-line (StartPoint EndPoint Lineweight / obj)
  (setq obj (vla-addline 
                (vla-get-modelspace (vla-get-activedocument(vlax-get-acad-object))) 
            (vlax-3d-point StartPoint) (vlax-3d-point EndPoint)))

  (cond
    ((vlax-write-enabled-p obj)
      (if Lineweight (vla-put-lineweight obj Lineweight)) 
      (vla-update obj)
  ))         
);_end defun





(defun list-massoc (key alist)
  (mapcar 'cdr (vl-remove-if-not (function (lambda (x) (= key (car x)))) alist))
) 



(defun pline-list-vertex (ent / list_vertex tmp_ent type_ent)
    (setq tmp_ent  ent
          ent      (entget ent)
          type_ent (cdr (assoc 0 ent))
    ) ;_ end of setq
    (cond
        ((= "LWPOLYLINE" type_ent)
         (list (list-massoc 10 ent) (= 1 (logand 1 (cdr (assoc 70 ent)))))
        )
        ((= "POLYLINE" type_ent)
         (reverse
             (cons (= 1 (logand 1 (cdr (assoc 70 ent))))
                   (while (and (setq tmp_ent (entnext tmp_ent))
                               (/= (cdr (assoc 0 (setq ent (entget tmp_ent))))
                                   "SEQEND"
                               ) ;_ end of =
                          ) ;_ end of and
                       (setq list_vertex (cons (cdr (assoc 10 ent)) list_vertex))
                   ) ;_ end of while
             ) ;_ end of cons
         ) ;_ end of reverse
        )
        ((= "LINE" type_ent)
         (list (cons (cdr (assoc 10 ent)) (cons (cdr (assoc 11 ent)) nil)) nil)
        )
        (t nil)
    ) ;_ end of cond
) ;_ end of defun



(defun ExportInExcel ()

    (setq ent (car (entsel "\nУкажите полилинию: "))) 
    (setq lst (car (pline-list-vertex ent)))
    (setq point_count (length lst))
    (setq point_number 0)
    
    
    ;(vl-load-com)
    (setq g_oex (vlax-get-or-create-object "Excel.Application"))
    (vlax-put-property g_oex 'SheetsInNewWorkbook 1)
    (vlax-put-property g_oex 'Visible :vlax-true)
    (setq g_wbs (vlax-get-property g_oex 'Workbooks))
    (setq g_cb (vlax-invoke-method g_wbs 'Add))
    (setq g_shs (vlax-get-property g_cb 'Sheets))
    (setq g_csh (vlax-get-property g_shs 'Item 1))
    (vlax-put-property g_csh 'Name "Координаты")


    (repeat point_count
       (setq pt (nth point_number lst));координаты текущей узловой точки
       (setq pt_next (nth (rem (1+ point_number) point_count) lst));координаты следующей узловой точки (по кругу)
       (setq X (car pt));координата X точки
       (setq Y (cadr pt));кооордината Y точки
       (setq X_next (car pt_next));координата X следующей точки
       (setq Y_next (cadr pt_next));координата Y следующей точки
       (setq Dist (geo_get_distance pt pt_next));расстояние между двумя координатами
       (setq Ang (geo_get_angle (list Y X) (list Y_next X_next)));угол между двумя координатами
       (setq StAng (angtos ang 1 3));Преобразовываем в строку
       (setq StAng (vl-string-subst "° " "d" StAng));Заменяем символ d(град) на символ '° '
       (setq StAng (vl-string-subst "' " "'" stang));Заменяем символ '(мин) на символ '' '    


       (setq RangeN (strcat "A" (itoa (1+ point_number))));Диапазон ячеек для номера точки
       (setq RangeX (strcat "B" (itoa (1+ point_number))));Диапазон ячеек для координаты X
       (setq RangeY (strcat "C" (itoa (1+ point_number))));Диапазон ячеек для координаты Y
       (setq RangeD (strcat "D" (itoa (1+ point_number))));Диапазон ячеек для расстояния  
       (setq RangeA (strcat "E" (itoa (1+ point_number))));Диапазон ячеек для угла        

       (setq g_r0 (vlax-get-property g_oex "Range" RangeN))
       (setq g_r1 (vlax-get-property g_oex "Range" RangeX))
       (setq g_r2 (vlax-get-property g_oex "Range" RangeY))
       (setq g_r3 (vlax-get-property g_oex "Range" RangeD))
       (setq g_r4 (vlax-get-property g_oex "Range" RangeA))

       (vlax-put-property g_r0 "value2" (1+ point_number))
       (vlax-put-property g_r1 "value2" (rtos Y 2 2))
       (vlax-put-property g_r2 "value2" (rtos X 2 2))
       (vlax-put-property g_r3 "value2" (rtos Dist 2 2))
       (vlax-put-property g_r4 "value2" StAng)

       (setq point_number (1+ point_number))
    );end of repeat
    

    (if (and g_r0 (not (vlax-object-released-p g_r0)))
        (vlax-release-object g_r0))
    
    (if (and g_r1 (not (vlax-object-released-p g_r1)))
        (vlax-release-object g_r1))
    
    (if (and g_r2 (not (vlax-object-released-p g_r2)))
        (vlax-release-object g_r2))

    (if (and g_r3 (not (vlax-object-released-p g_r3)))
        (vlax-release-object g_r3))

    (if (and g_r4 (not (vlax-object-released-p g_r4)))
        (vlax-release-object g_r4))

    (if (and g_csh (not (vlax-object-released-p g_csh)))
        (vlax-release-object g_csh))

    (if (and g_shs (not (vlax-object-released-p g_shs)))
        (vlax-release-object g_shs))

    (if (and g_cb (not (vlax-object-released-p g_cb)))
        (vlax-release-object g_cb))

    (if (and g_wbs (not (vlax-object-released-p g_wbs)))
        (vlax-release-object g_wbs))
    
    (if (and g_oex (not (vlax-object-released-p g_oex)))
        (vlax-release-object g_oex))
    ;Обнуление использованных глобальных переменных
    (setq g_r0 nil g_r1 nil  g_r2 nil g_r3 nil g_r3 nil g_csh nil g_shs nil g_cb nil g_wbs nil g_oex nil)
    ;Сборка мусора
    (gc)
    
)





(defun geo_point_table ()
  (setq pnt nil)
  (setq nline 0)
  (setq rows nil);список для всех координат типа: ((x,y,z)(x,y,z)...)
  
  ;Запрос на ввод точек
  (while 
    (setq pnt (getpoint "\nУкажите координату: "))
    (setq nline (1+ nline));увеличиваем количество строк на 1
    ;формируем список с координатами
    (setq row pnt);списку row присваеваем список pnt с координатами выбранной точки
    (setq rows (append rows (list row) ));добавляем список row c коорд. выбранной точки в список со всеми коорд. rows    
  );while  

  ;Запрос на ввод коорд. левого верхнего угла таблицы  
  (setq InsertionPoint nil)                  
  (setq InsertionPoint (getpoint "\nУкажите координаты левого верхнего угла таблицы: "))

  ;Запоминаем значения сист.переменных                   
  (setq ORT (getvar "ORTHOMODE"));ORTHO                  
  (setq SN (getvar "SNAPMODE"));SNAP                     
  (setq OSN (getvar "OSMODE"));OSNAP
  (setq DIMZ (getvar "DIMZIN"));DIMZIN
  (setq TEXT (getvar "TEXTSTYLE"));TEXTSTYLE
  (setq COLOR(getvar "CECOLOR"));CECOLOR
  ;Задаём значения сист.переменным                       
  (setvar "ORTHOMODE" 0);ORTHO                           
  (setvar "SNAPMODE" 0);SNAP                             
  (setvar "OSMODE" 0);OSNAP                              
  (setvar "DIMZIN" 0);DIMZIN
  (setvar "CECOLOR" "251");CECOLOR

  (DrawLines InsertionPoint nline);создаём линии таблицы
  (setvar "CECOLOR" COLOR);CECOLOR
  (DrawText InsertionPoint nline 2.0 rows);создаём текст в таблице

  ;возвращаем знач. сист.переменных в начальное состояние
  (setvar "ORTHOMODE" ORT);ORTHO                         
  (setvar "SNAPMODE" SN);SNAP                            
  (setvar "OSMODE" OSN);OSNAP                            
  (setvar "DIMZIN" DIMZ);DIMZIN
  (setvar "TEXTSTYLE" TEXT);TEXTSTYLE

);_end defun geo-draw-table



(
defun DrawLines(InsertionPoint nline)
  ;InsertionPoint - точка вставки
  ;nline - количество строк
  (setq width 104 h 4);ширина таблицы\высота строк\
  
  ;чертим гор.линии шапки таблицы
  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-line (list xx yy) (list (+ xx width) yy) acLnWtByLayer);первая линия, с началом в точке InsertionPoint
  (geo-add-line (list (+ xx 13) (- yy h)) (list (+ xx 57) (- yy h)) acLnWtByLayer);вторая линия  
  (geo-add-line (list xx (- yy 8)) (list (+ xx width) (- yy 8)) acLnWtByLayer);третья линия

  ;чертим гор. линии таблицы
  (setq yy (- yy 12))
  (repeat nline
    (geo-add-line (list xx yy) (list (+ xx width) yy) acLnWtByLayer)
    (setq yy (- yy h))
  );_end repeat

  ;чертим вертикальные линии таблицы
  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-line (list xx yy) (list xx (- yy 8 (* h nline))) acLnWtByLayer);первая линия  
  (geo-add-line (list (+ xx 13) yy) (list (+ xx 13) (- yy 8 (* h nline))) acLnWtByLayer);вторая линия
  (geo-add-line (list (+ xx 35) (- yy h)) (list (+ xx 35) (- yy 8 (* h nline))) acLnWtByLayer);третья линия
  (geo-add-line (list (+ xx 57) yy) (list (+ xx 57) (- yy 8 (* h nline))) acLnWtByLayer);четвёртая линия 
  (geo-add-line (list (+ xx 74) yy) (list (+ xx 74) (- yy 8 (* h nline))) acLnWtByLayer);пятая линия
  (geo-add-line (list (+ xx 91) yy) (list (+ xx 91) (- yy 8 (* h nline))) acLnWtByLayer);шестая линия
  (geo-add-line (list (+ xx 104) yy) (list (+ xx 104) (- yy 8 (* h nline))) acLnWtByLayer);седьмая линия    

);_end defun DrawLines



(
defun DrawText(InsertionPoint nline h rows)
  ;InsertionPoint - коорд. левого верхнего угла таблицы
  ;nline - количество строк
  ;h - высота текста
  ;rows - список со всеми координатами типа: ((x,y,z)(x,y,z)...)
  
  ;Шапка таблицы
  ;(command "_STYLE" "Table(Geocad)" "Times New Roman" 0.0 1.0 0.0 "N" "N");создаём новый текст.стиль "Table(Geocad)"
  ;(setvar "TEXTSTYLE" "Table(Geocad)");TEXTSTYLE

  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-text "Номер" (list (+ xx 2.5) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "точки" (list (+ xx 3) (- yy 6)) h acAlignmentLeft 0)
  (geo-add-text "К О О Р Д И Н А Т Ы" (list (+ xx 21) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "X" (list (+ xx 23) (- yy 7)) h acAlignmentLeft 0)
  (geo-add-text "Y" (list (+ xx 44.5) (- yy 7)) h acAlignmentLeft 0)
  (geo-add-text "Дир.углы" (list (+ xx 60) (- yy 4.5)) h acAlignmentLeft 0)
  (geo-add-text "Меры" (list (+ xx 79) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "линий,м" (list (+ xx 77.5) (- yy 6)) h acAlignmentLeft 0)
  (geo-add-text "На" (list (+ xx 96) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "точку" (list (+ xx 94) (- yy 6)) h acAlignmentLeft 0)

  ;Таблица
  (setq i 1);счётчик
  (setq nlist 0);список с коорд.(x,y,z) в списке со всеми коорд. 
  (repeat nline
    ;номера точек
    (geo-add-text (rtos i 2 0) (list (+ xx 6.5) (- yy 11)) h acAlignmentCenter 0);выводим в перв. столбец номер точки

    (if (= i nline) (setq i 0));если последняя точка, в последнем столбце для точек пишем начальную точку
    (geo-add-text (rtos (1+ i) 2 0) (list (+ xx 97.5) (- yy 11)) h acAlignmentCenter 0);выводим в последний столбец номер точки

    ;координаты X и Y
    (setq kx (nth 0 (nth nlist rows)));коорд. X
    (setq ky (nth 1 (nth nlist rows)));коорд. Y
    (geo-add-text (rtos ky 2 2) (list (+ xx 24) (- yy 11)) h acAlignmentCenter 0);выводим X\переворачиваем координаты
    (geo-add-text (rtos kx 2 2) (list (+ xx 46) (- yy 11)) h acAlignmentCenter 0);выводим Y\переворачиваем координаты
     
    ;Дир.углы
    (setq a1 (nth nlist rows));первая координата
    (setq a2 (nth (rem (1+ nlist) nline) rows));вторая координата
    
    (setq x1 (car a1) y1 (cadr a1));выбираем из списка координат а1 x и y
    (setq x2 (car a2) y2 (cadr a2));выбираем из списка координат а2 x и y    
    (setq k1 (list y1 x1));меняем x и y и заносим в список 
    (setq k2 (list y2 x2));меняем x и y и заносим в список 


    (setq ang (geo_get_angle k1 k2));вычисляем угол\переворачиваем координаты
    (setq stang (angtos ang 1 3));преобразуем угол в стороку с точностью 3
    (setq stang (vl-string-subst "° " "d" stang));заменяем символ d(град) на символ '° '
    (setq stang (vl-string-subst "' " "'" stang));заменяем символ '(мин) на символ '' '(c пробелом)
    (geo-add-text stang (list (+ xx 65.5) (- yy 11)) h acAlignmentCenter 0);выводим угол в град,мин,сек. 

    ;Расстояние
    (setq pnt1 (nth nlist rows));первая координата
    (setq pnt2 (nth (rem (1+ nlist) nline) rows));вторая координата
    (setq dist (geo_get_distance pnt1 pnt2))
    (geo-add-text (rtos dist 2 2) (list (+ xx 82.5) (- yy 11)) h acAlignmentCenter 0);выводим расстояние
  
    (setq i (1+ i));увеличиваем i на 1
    (setq yy (- yy 4));уменьшаем yy на 4
    (setq nlist (1+ nlist));увеличиваем nlist на 1
  )

  
);_end defun DrawText
;----------------------------------------------------------------------------------------------------------------------------
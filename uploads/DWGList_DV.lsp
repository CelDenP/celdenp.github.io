(vl-load-com)

(defun c:DWGList_DV ( / ss numLst titleLst i ent obj layer typ 
                                nPt tPt dist minDist closestTitle matchedPairs 
                                ins-pt doc space util
                                valA valB numA numB nObj tObj 
                                idNum idTitle numField titleField 
                                rowHeight col1Width col2Width padding textHeight lsFactor
                                rowIndex currentY ptNum ptTitle ptNumWCS ptTitleWCS 
                                mtextNum mtextTitle topOffset dummy err numLines minPt maxPt h ucsAngle )
                          
  ;; ================= НАСТРОЙКИ РАЗМЕРОВ =================
  (setq rowHeight 800.0)      ; Высота одной ячейки (строки)
  (setq col1Width 1500.0)     ; Ширина столбца "Лист"
  (setq col2Width 14000.0)    ; Ширина столбца "Наименование"
  
  (setq padding 200.0)        ; Отступ текста наименования от левой линии столбца
  (setq textHeight 270.0)     ; Высота текста
  
  ;; Вычисляем множитель для точного межстрочного интервала 800
  (setq lsFactor (/ rowHeight (* textHeight (/ 5.0 3.0)))) 
  ;; ======================================================

  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq space (if (= (vla-get-ActiveSpace doc) 1)
                  (vla-get-ModelSpace doc)
                  (vla-get-PaperSpace doc)))
  (setq util (vla-get-Utility doc))

  (prompt "\nВыберите рамкой номера и названия листов (или введите 'ALL'): ")
  (setq ss (ssget '((0 . "TEXT,MTEXT") (8 . "`#Автонум,`#Лист"))))
  
  (if (not ss)
    (progn (princ "\nНичего не выбрано.") (exit))
  )

  (setq numLst nil titleLst nil i 0)
  (while (< i (sslength ss))
    (setq ent (ssname ss i))
    (setq obj (vlax-ename->vla-object ent))
    (setq layer (strcase (vla-get-Layer obj))) 
    (setq typ (vla-get-ObjectName obj))
    
    (if (and (= layer (strcase "#Автонум")) (= typ "AcDbText"))
        (setq numLst (cons obj numLst))
    )
    (if (and (= layer (strcase "#Лист")) (= typ "AcDbMText"))
        (setq titleLst (cons obj titleLst))
    )
    (setq i (1+ i))
  )

  (if (or (not numLst) (not titleLst) (= (length numLst) 0) (= (length titleLst) 0))
    (progn (princ "\nОшибка: Не найдены объекты на одном из слоев.") (exit))
  )

  ;; Сопоставление номеров и названий
  (setq matchedPairs nil)
  (foreach nObj numLst
    ;; vla-get-InsertionPoint всегда отдает мировые координаты (МСК)
    (setq nPt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint nObj))))
    (setq minDist 1e99 closestTitle nil)
    
    (foreach tObj titleLst
      (setq tPt (vlax-safearray->list (vlax-variant-value (vla-get-InsertionPoint tObj))))
      (setq dist (distance nPt tPt))
      (if (< dist minDist)
        (progn (setq minDist dist) (setq closestTitle tObj))
      )
    )
    (setq matchedPairs (cons (list nObj closestTitle) matchedPairs))
  )

  ;; Сортировка по номерам
  (setq matchedPairs
        (vl-sort matchedPairs
                 (function (lambda (a b)
                    (setq valA (vla-get-TextString (car a)))
                    (setq valB (vla-get-TextString (car b)))
                    (setq numA (atof valA) numB (atof valB))
                    (if (and (> numA 0) (> numB 0) (/= numA numB))
                        (< numA numB) (< valA valB) 
                    )
                 ))
        )
  )

  ;; ЗАПРОС ТОЧКИ ВСТАВКИ (Координаты получаем в ПСК / UCS пользователя)
  (setq ins-pt (getpoint "\nУкажите точку вставки: "))
  (if (not ins-pt) (exit))
  
  ;; Получаем угол поворота ПСК относительно Мировой системы координат
  (setq ucsAngle (angle '(0 0 0) (trans '(1 0 0) 1 0 t))) 

  (defun get-obj-id-str (obj util)
    (if (vlax-method-applicable-p util 'GetObjectIdString)
        (vla-GetObjectIdString util obj :vlax-false)
        (itoa (vla-get-ObjectId obj))
    )
  )

  ;; Генерация МТекстов построчно
  (setq rowIndex 0)
  (foreach pair matchedPairs
    (setq nObj (car pair))
    (setq tObj (cadr pair))
    
    (setq idNum (get-obj-id-str nObj util))
    (setq idTitle (get-obj-id-str tObj util))
    
    (setq numField (strcat "%<\\AcObjProp Object(%<\\_ObjId " idNum ">%).TextString>%"))
    (setq titleField (strcat "%<\\AcObjProp Object(%<\\_ObjId " idTitle ">%).TextString>%"))
    
    ;; Высчитываем координаты в системе ПСК пользователя (как он их видит на экране)
    (setq currentY (- (cadr ins-pt) (* rowIndex rowHeight)))
    
    (setq ptNum (list (+ (car ins-pt) (/ col1Width 2.0))
                      (- currentY (/ rowHeight 2.0))
                      (caddr ins-pt)))
                      
    (setq topOffset (/ (- rowHeight textHeight) 2.0))
    (setq ptTitle (list (+ (car ins-pt) col1Width padding)
                        (- currentY topOffset)
                        (caddr ins-pt)))

    ;; ПЕРЕВОД КООРДИНАТ: Из ПСК (1) в МСК (0) для корректной работы ActiveX
    (setq ptNumWCS (trans ptNum 1 0))
    (setq ptTitleWCS (trans ptTitle 1 0))

    ;; --- УМНЫЙ ПРОСЧЕТ КОЛИЧЕСТВА СТРОК ---
    (setq numLines 1)
    (setq dummy (vla-AddMText space (vlax-3d-point ptTitleWCS) (- col2Width (* padding 2.0)) (vla-get-TextString tObj)))
    (vla-put-Height dummy textHeight)
    (vla-put-LineSpacingStyle dummy 2) 
    (vla-put-LineSpacingFactor dummy lsFactor)
    
    (setq err (vl-catch-all-apply 'vla-getBoundingBox (list dummy 'minPt 'maxPt)))
    (if (not (vl-catch-all-error-p err))
      (progn
        (setq h (- (cadr (vlax-safearray->list maxPt)) (cadr (vlax-safearray->list minPt))))
        (setq numLines (1+ (fix (/ h rowHeight)))) 
      )
    )
    (vla-Delete dummy) 
    ;; --------------------------------------

    ;; 1. Вставляем МТекст НОМЕРА 
    (setq mtextNum (vla-AddMText space (vlax-3d-point ptNumWCS) 0.0 numField))
    (vla-put-Height mtextNum textHeight)
    (vla-put-AttachmentPoint mtextNum 5) 
    (vla-put-InsertionPoint mtextNum (vlax-3d-point ptNumWCS))
    ;; Применяем поворот (если ПСК была повернута)
    (if (/= ucsAngle 0.0) (vla-put-Rotation mtextNum ucsAngle))

    ;; 2. Вставляем МТекст НАЗВАНИЯ 
    (setq mtextTitle (vla-AddMText space (vlax-3d-point ptTitleWCS) (- col2Width (* padding 2.0)) titleField))
    (vla-put-Height mtextTitle textHeight)
    (vla-put-AttachmentPoint mtextTitle 1) 
    (vla-put-InsertionPoint mtextTitle (vlax-3d-point ptTitleWCS))
    (if (/= ucsAngle 0.0) (vla-put-Rotation mtextTitle ucsAngle))
    
    (vla-put-LineSpacingStyle mtextTitle 2) 
    (vla-put-LineSpacingFactor mtextTitle lsFactor)

    ;; Смещаем индекс вниз
    (setq rowIndex (+ rowIndex numLines))
  )
  
  (princ "\nСтроки успешно заполнены!")
  (princ)
)

(princ "\nКоманда DWGList_DV успешно загружена!")
(princ)
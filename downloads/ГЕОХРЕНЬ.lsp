

(vl-load-com)


(defun *error* (msg)
  (princ)
)



(defun c:��������()
   (initget 1 "��������� �����")
   (setq x (getkword "\n��������� ��������� �� [���������/�����]: ")) 
   (if (= x "���������") (ExportInExcel) (geo_point_table)) 
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

    (setq ent (car (entsel "\n������� ���������: "))) 
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
    (vlax-put-property g_csh 'Name "����������")


    (repeat point_count
       (setq pt (nth point_number lst));���������� ������� ������� �����
       (setq pt_next (nth (rem (1+ point_number) point_count) lst));���������� ��������� ������� ����� (�� �����)
       (setq X (car pt));���������� X �����
       (setq Y (cadr pt));����������� Y �����
       (setq X_next (car pt_next));���������� X ��������� �����
       (setq Y_next (cadr pt_next));���������� Y ��������� �����
       (setq Dist (geo_get_distance pt pt_next));���������� ����� ����� ������������
       (setq Ang (geo_get_angle (list Y X) (list Y_next X_next)));���� ����� ����� ������������
       (setq StAng (angtos ang 1 3));��������������� � ������
       (setq StAng (vl-string-subst "� " "d" StAng));�������� ������ d(����) �� ������ '� '
       (setq StAng (vl-string-subst "' " "'" stang));�������� ������ '(���) �� ������ '' '    


       (setq RangeN (strcat "A" (itoa (1+ point_number))));�������� ����� ��� ������ �����
       (setq RangeX (strcat "B" (itoa (1+ point_number))));�������� ����� ��� ���������� X
       (setq RangeY (strcat "C" (itoa (1+ point_number))));�������� ����� ��� ���������� Y
       (setq RangeD (strcat "D" (itoa (1+ point_number))));�������� ����� ��� ����������  
       (setq RangeA (strcat "E" (itoa (1+ point_number))));�������� ����� ��� ����        

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
    ;��������� �������������� ���������� ����������
    (setq g_r0 nil g_r1 nil  g_r2 nil g_r3 nil g_r3 nil g_csh nil g_shs nil g_cb nil g_wbs nil g_oex nil)
    ;������ ������
    (gc)
    
)





(defun geo_point_table ()
  (setq pnt nil)
  (setq nline 0)
  (setq rows nil);������ ��� ���� ��������� ����: ((x,y,z)(x,y,z)...)
  
  ;������ �� ���� �����
  (while 
    (setq pnt (getpoint "\n������� ����������: "))
    (setq nline (1+ nline));����������� ���������� ����� �� 1
    ;��������� ������ � ������������
    (setq row pnt);������ row ����������� ������ pnt � ������������ ��������� �����
    (setq rows (append rows (list row) ));��������� ������ row c �����. ��������� ����� � ������ �� ����� �����. rows    
  );while  

  ;������ �� ���� �����. ������ �������� ���� �������  
  (setq InsertionPoint nil)                  
  (setq InsertionPoint (getpoint "\n������� ���������� ������ �������� ���� �������: "))

  ;���������� �������� ����.����������                   
  (setq ORT (getvar "ORTHOMODE"));ORTHO                  
  (setq SN (getvar "SNAPMODE"));SNAP                     
  (setq OSN (getvar "OSMODE"));OSNAP
  (setq DIMZ (getvar "DIMZIN"));DIMZIN
  (setq TEXT (getvar "TEXTSTYLE"));TEXTSTYLE
  (setq COLOR(getvar "CECOLOR"));CECOLOR
  ;����� �������� ����.����������                       
  (setvar "ORTHOMODE" 0);ORTHO                           
  (setvar "SNAPMODE" 0);SNAP                             
  (setvar "OSMODE" 0);OSNAP                              
  (setvar "DIMZIN" 0);DIMZIN
  (setvar "CECOLOR" "251");CECOLOR

  (DrawLines InsertionPoint nline);������ ����� �������
  (setvar "CECOLOR" COLOR);CECOLOR
  (DrawText InsertionPoint nline 2.0 rows);������ ����� � �������

  ;���������� ����. ����.���������� � ��������� ���������
  (setvar "ORTHOMODE" ORT);ORTHO                         
  (setvar "SNAPMODE" SN);SNAP                            
  (setvar "OSMODE" OSN);OSNAP                            
  (setvar "DIMZIN" DIMZ);DIMZIN
  (setvar "TEXTSTYLE" TEXT);TEXTSTYLE

);_end defun geo-draw-table



(
defun DrawLines(InsertionPoint nline)
  ;InsertionPoint - ����� �������
  ;nline - ���������� �����
  (setq width 104 h 4);������ �������\������ �����\
  
  ;������ ���.����� ����� �������
  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-line (list xx yy) (list (+ xx width) yy) acLnWtByLayer);������ �����, � ������� � ����� InsertionPoint
  (geo-add-line (list (+ xx 13) (- yy h)) (list (+ xx 57) (- yy h)) acLnWtByLayer);������ �����  
  (geo-add-line (list xx (- yy 8)) (list (+ xx width) (- yy 8)) acLnWtByLayer);������ �����

  ;������ ���. ����� �������
  (setq yy (- yy 12))
  (repeat nline
    (geo-add-line (list xx yy) (list (+ xx width) yy) acLnWtByLayer)
    (setq yy (- yy h))
  );_end repeat

  ;������ ������������ ����� �������
  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-line (list xx yy) (list xx (- yy 8 (* h nline))) acLnWtByLayer);������ �����  
  (geo-add-line (list (+ xx 13) yy) (list (+ xx 13) (- yy 8 (* h nline))) acLnWtByLayer);������ �����
  (geo-add-line (list (+ xx 35) (- yy h)) (list (+ xx 35) (- yy 8 (* h nline))) acLnWtByLayer);������ �����
  (geo-add-line (list (+ xx 57) yy) (list (+ xx 57) (- yy 8 (* h nline))) acLnWtByLayer);�������� ����� 
  (geo-add-line (list (+ xx 74) yy) (list (+ xx 74) (- yy 8 (* h nline))) acLnWtByLayer);����� �����
  (geo-add-line (list (+ xx 91) yy) (list (+ xx 91) (- yy 8 (* h nline))) acLnWtByLayer);������ �����
  (geo-add-line (list (+ xx 104) yy) (list (+ xx 104) (- yy 8 (* h nline))) acLnWtByLayer);������� �����    

);_end defun DrawLines



(
defun DrawText(InsertionPoint nline h rows)
  ;InsertionPoint - �����. ������ �������� ���� �������
  ;nline - ���������� �����
  ;h - ������ ������
  ;rows - ������ �� ����� ������������ ����: ((x,y,z)(x,y,z)...)
  
  ;����� �������
  ;(command "_STYLE" "Table(Geocad)" "Times New Roman" 0.0 1.0 0.0 "N" "N");������ ����� �����.����� "Table(Geocad)"
  ;(setvar "TEXTSTYLE" "Table(Geocad)");TEXTSTYLE

  (setq xx (car InsertionPoint) yy (cadr InsertionPoint))
  (geo-add-text "�����" (list (+ xx 2.5) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "�����" (list (+ xx 3) (- yy 6)) h acAlignmentLeft 0)
  (geo-add-text "� � � � � � � � � �" (list (+ xx 21) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "X" (list (+ xx 23) (- yy 7)) h acAlignmentLeft 0)
  (geo-add-text "Y" (list (+ xx 44.5) (- yy 7)) h acAlignmentLeft 0)
  (geo-add-text "���.����" (list (+ xx 60) (- yy 4.5)) h acAlignmentLeft 0)
  (geo-add-text "����" (list (+ xx 79) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "�����,�" (list (+ xx 77.5) (- yy 6)) h acAlignmentLeft 0)
  (geo-add-text "��" (list (+ xx 96) (- yy 3)) h acAlignmentLeft 0)
  (geo-add-text "�����" (list (+ xx 94) (- yy 6)) h acAlignmentLeft 0)

  ;�������
  (setq i 1);�������
  (setq nlist 0);������ � �����.(x,y,z) � ������ �� ����� �����. 
  (repeat nline
    ;������ �����
    (geo-add-text (rtos i 2 0) (list (+ xx 6.5) (- yy 11)) h acAlignmentCenter 0);������� � ����. ������� ����� �����

    (if (= i nline) (setq i 0));���� ��������� �����, � ��������� ������� ��� ����� ����� ��������� �����
    (geo-add-text (rtos (1+ i) 2 0) (list (+ xx 97.5) (- yy 11)) h acAlignmentCenter 0);������� � ��������� ������� ����� �����

    ;���������� X � Y
    (setq kx (nth 0 (nth nlist rows)));�����. X
    (setq ky (nth 1 (nth nlist rows)));�����. Y
    (geo-add-text (rtos ky 2 2) (list (+ xx 24) (- yy 11)) h acAlignmentCenter 0);������� X\�������������� ����������
    (geo-add-text (rtos kx 2 2) (list (+ xx 46) (- yy 11)) h acAlignmentCenter 0);������� Y\�������������� ����������
     
    ;���.����
    (setq a1 (nth nlist rows));������ ����������
    (setq a2 (nth (rem (1+ nlist) nline) rows));������ ����������
    
    (setq x1 (car a1) y1 (cadr a1));�������� �� ������ ��������� �1 x � y
    (setq x2 (car a2) y2 (cadr a2));�������� �� ������ ��������� �2 x � y    
    (setq k1 (list y1 x1));������ x � y � ������� � ������ 
    (setq k2 (list y2 x2));������ x � y � ������� � ������ 


    (setq ang (geo_get_angle k1 k2));��������� ����\�������������� ����������
    (setq stang (angtos ang 1 3));����������� ���� � ������� � ��������� 3
    (setq stang (vl-string-subst "� " "d" stang));�������� ������ d(����) �� ������ '� '
    (setq stang (vl-string-subst "' " "'" stang));�������� ������ '(���) �� ������ '' '(c ��������)
    (geo-add-text stang (list (+ xx 65.5) (- yy 11)) h acAlignmentCenter 0);������� ���� � ����,���,���. 

    ;����������
    (setq pnt1 (nth nlist rows));������ ����������
    (setq pnt2 (nth (rem (1+ nlist) nline) rows));������ ����������
    (setq dist (geo_get_distance pnt1 pnt2))
    (geo-add-text (rtos dist 2 2) (list (+ xx 82.5) (- yy 11)) h acAlignmentCenter 0);������� ����������
  
    (setq i (1+ i));����������� i �� 1
    (setq yy (- yy 4));��������� yy �� 4
    (setq nlist (1+ nlist));����������� nlist �� 1
  )

  
);_end defun DrawText
;----------------------------------------------------------------------------------------------------------------------------
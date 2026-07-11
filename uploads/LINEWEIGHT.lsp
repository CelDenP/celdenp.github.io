 (vl-load-com)

(defun c:LINEWEIGHT (/ adoc layers att)
(defun C:PFL (/ adoc blocks  ent lays ss i color linetype lineweight *error*)
;;;Properties From Layer
   (defun *error* (msg)
   (setvar "MODEMACRO" "")
   (princ msg)
   (vla-regen aDOC acactiveviewport)
   (bg:progress-clear)
   (bg:layer-status-restore)
   (princ)
 ) ;_ end of defun

 (vl-load-com)
 (command "_.UNDO" "_Mark")
 (setvar "CLAYER" "0")
 (pfl)
 (command "_.Regenall")
 (princ "\n*** Command _.UNDO _Back restore previous settings")
 (princ)
 ) ;_ end of defun
(defun pfl ( / layer-list aDOC count  *error* color linetype lineweight lays count)
 (defun *error* (msg)
   (setvar "MODEMACRO" "")
   (princ msg)
   (vla-regen aDOC acactiveviewport)
   (bg:progress-clear)
   (bg:layer-status-restore)
   (princ)
 ) ;_ end of defun
 (defun _loc_fun ()
   (if	(= (vla-get-IsXref Blk) :vlax-false)
     (progn
(setq count 0)
(if (> (vla-get-count Blk) 100)
  (bg:progress-init
    (strcat (vla-get-name Blk) " :")
    (vla-get-count Blk)
  ) ;_ end of bg:progress-init
  (progn
    (setvar "MODEMACRO" (vla-get-name Blk))
  ) ;_ end of progn
) ;_ end of if
(vlax-for Obj Blk
         (setq lay        (vla-item lays (vla-get-layer Obj))
                color      (vla-get-color lay)
                linetype   (vla-get-linetype lay)
                lineweight (vla-get-lineweight lay)
          ) ;_ end of setq
         (bg:progress (setq count (1+ count)))
         (vl-catch-all-apply
            '(lambda ()
               (if (eq (vla-get-color Obj) acByLayer)(vla-put-color Obj color))
               (if (eq (vla-get-linetype Obj) "ByLayer") (vla-put-linetype Obj linetype))
               (if (eq (vla-get-lineweight Obj) acLnWtByLayer)(vla-put-lineweight Obj lineweight))
             ) ;_ end of lambda
          ) ;_ end of vl-catch-all-apply
         ) ;_ end of vlax-for
(bg:progress-clear)
     ) ;_ end of progn
   ) ;_ end of if
 ) ;_ end of defun
 (setq	aDOC	   (vla-get-activedocument (vlax-get-acad-object))
       lays (vla-get-layers adoc)
 ) ;_ end of setq
;;;  (grtext -1 "Stage 1. Viewing of layers")
 (bg:layer-status-save)
 (vlax-for Blk (vla-get-Blocks aDOC)
   (if (eq (vla-get-IsLayout Blk) :vlax-true)
     (_loc_fun)))
 (bg:layer-status-restore)
;;;  ???????
 (setq *PD_LAYER_LST* nil)
)
(defun bg:progress-clear ()
 (setq *BG:PROGRESS:MSG* nil)
 (setq *BG:PROGRESS:MAXLEN* nil)
 (setq *BG:PROGRESS:LPS* nil)
 (setvar "MODEMACRO" (vl-princ-to-string *BG:PROGRESS:OM*))
 ;;;(vla-regen (vla-get-activedocument (vlax-get-acad-object)) acactiveviewport)
 (princ)
 )
(defun bg:progress-init (msg maxlen)
 ;;; msg - message
 ;;; maxlen - max count
 (setq *BG:PROGRESS:OM* (getvar "MODEMACRO"))
 (setq *BG:PROGRESS:MSG* (vl-princ-to-string msg))
 (setq *BG:PROGRESS:MAXLEN* maxlen)
 (setq *BG:PROGRESS:LPS* '-1)(princ)
 )
(defun bg:progress ( currvalue / persent str1 count)
 (if *BG:PROGRESS:MAXLEN*
   (progn
 (setq persent (fix (/ currvalue 0.01 *BG:PROGRESS:MAXLEN*)))
 ;;;Every 5 %
 (setq count (fix(* persent 0.2)))
 (setq str1 "")
 (if (/= count *BG:PROGRESS:LPS*)
   (progn
     ;;(setq str1 "")
     (repeat persent (setq str1 (strcat str1 "|")))
     )
   )
      ;;; currvalue - current value
     (setvar "MODEMACRO"
             (strcat (vl-princ-to-string *BG:PROGRESS:MSG*)
                     " "
                     (itoa persent)
                     " % "
                     str1
                     )
             )
     (setq *BG:PROGRESS:LPS* persent)
 )
   )
 )
(defun bg:layer-status-restore ()
   (foreach item *PD_LAYER_LST*
     (if (not (vlax-erased-p (car item)))
       (vl-catch-all-apply
         '(lambda ()
            (vla-put-lock (car item) (cdr (assoc "lock" (cdr item))))
            (vla-put-freeze (car item) (cdr (assoc "freeze" (cdr item))))
            ) ;_ end of lambda
         ) ;_ end of vl-catch-all-apply
       ) ;_ end of if
     ) ;_ end of foreach
   (setq *PD_LAYER_LST* nil)
   ) ;_ end of defun

 (defun bg:layer-status-save ()
   (setq *PD_LAYER_LST* nil)
   (vlax-for item (vla-get-layers (vla-get-activedocument (vlax-get-acad-object)))
     (setq *PD_LAYER_LST* (cons (list item
                                 (cons "freeze" (vla-get-freeze item))
                                 (cons "lock" (vla-get-lock item))
                                 ) ;_ end of cons
                           *PD_LAYER_LST*
                           ) ;_ end of cons
           ) ;_ end of setq
     (vla-put-lock item :vlax-false)
     (if (= (vla-get-freeze item) :vlax-true)
     (vl-catch-all-apply '(lambda () (vla-put-freeze item :vlax-false))))
     ) ;_ end of vlax-for
   ) ;_ end of defun
  (defun _kpblc-conv-ent-to-vla (ent_value / res)
    (cond
      ((= (type ent_value) 'vla-object) ent_value)
      ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
      ((setq res (_kpblc-conv-ent-to-ename ent_value))
       (vlax-ename->vla-object res)
       )
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-ename (ent_value /)
    (cond
      ((= (type ent_value) 'vla-object)
       (vlax-vla-object->ename ent_value)
       )
      ((= (type ent_value) 'ename) ent_value)
          ;((= (type ent_value) 'str) (handent ent_value))
      ((= (type ent_value) 'list) (cdr (assoc -1 ent_value)))
      (t nil)
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-vla-to-list (value / res)
    (cond
      ((listp value)
       (mapcar (function _kpblc-conv-vla-to-list) value)
       )
      ((= (type value) 'variant)
       (_kpblc-conv-vla-to-list (vlax-variant-value value))
       )
      ((= (type value) 'safearray)
       (if (>= (vlax-safearray-get-u-bound value 1) 0)
         (_kpblc-conv-vla-to-list (vlax-safearray->list value))
         ) ;_ end of if
       )
      ((and (member (type value) (list 'ename 'str 'vla-object))
            (= (type (_kpblc-conv-ent-to-vla value)) 'vla-object)
            (vlax-property-available-p (_kpblc-conv-ent-to-vla value) 'count)
            ) ;_ end of and
       (vlax-for sub (_kpblc-conv-ent-to-vla value)
         (setq res (cons sub res))
         ) ;_ end of vlax-for
       )
      (t value)
      ) ;_ end of cond
    ) ;_ end of defun


  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (setq layers (mapcar
                 (function
                   (lambda (x)
                     (append (list (cons "obj" x))
                             (mapcar
                               (function
                                 (lambda (prop / tmp)
                                   (setq tmp (vlax-get-property x (car prop)))
                                   (vl-catch-all-apply
                                     (function
                                       (lambda ()
                                         (vlax-put-property x (car prop) (cdr prop))
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     ) ;_ end of vl-catch-all-apply
                                   (cons (car prop) tmp)
                                   ) ;_ end of lambda
                                 ) ;_ end of function
                               (list (cons "freeze" :vlax-false)
                                     (cons "lock" :vlax-false)
                                     ) ;_ end of list
                               ) ;_ end of mapcar
                             ) ;_ end of append
                     ) ;_ end of LAMBDA
                   ) ;_ end of function
                 (vl-remove-if
                   (function
                     (lambda (x)
                       (wcmatch (strcase (vla-get-name x)) "*|*")
                       ) ;_ end of LAMBDA
                     ) ;_ end of function
                   (_kpblc-conv-vla-to-list (vla-get-layers adoc))
                   ) ;_ end of vl-remove-if
                 ) ;_ end of mapcar
        ) ;_ end of setq
  (foreach item layers
    (vla-put-lineweight (cdr (assoc "obj" item))
                        (if (or (= (vla-get-lineweight (cdr (assoc "obj" item))) aclnwtbylwdefault)
                                (<= (vla-get-lineweight (cdr (assoc "obj" item))) aclnwt025)
                                ) ;_ end of or
                          aclnwt013
                          aclnwt030
                          ) ;_ end of if
                        ) ;_ end of vla-put-lineweight
    ) ;_ end of foreach
  (vlax-for blk_def (vla-get-blocks adoc)
    (if (equal (vla-get-isxref blk_def) :vlax-false)
      (if (wcmatch (if (vlax-property-available-p blk_def 'effectivename)
                     (vla-get-effectivename blk_def)
                     (vla-get-name blk_def)
                     ) ;_ end of if
                   "`*D*"
                   ) ;_ end of WCMATCH
        (vlax-for ent blk_def
          (vl-catch-all-apply
            (function
              (lambda ()
                (vla-put-lineweight ent aclnwt013)
                ) ;_ end of lambda
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of vlax-for
        (vlax-for ent blk_def
          (if (and (wcmatch (strcase (vla-get-objectname ent)) "*BLOCK*")
                   (setq att (append (_kpblc-conv-vla-to-list (vla-getattributes ent))
                                     (_kpblc-conv-vla-to-list (vla-getconstantattributes ent))
                                     ) ;_ end of append
                         ) ;_ end of setq
                   ) ;_ end of and
            (foreach _att att
              (vl-catch-all-apply
                (function
                  (lambda ()
                    (vla-put-lineweight _att aclnwt013)
                    ) ;_ end of lambda
                  ) ;_ end of function
                ) ;_ end of vl-catch-all-apply
              ) ;_ end of foreach
            ) ;_ end of if
          (vl-catch-all-apply
            (function
              (lambda ()
                (vla-put-lineweight ent
                                    (cond
                                      ((wcmatch (strcase (vla-get-objectname ent)) "*TEXT,*ATTR*") aclnwt013)
                                      ((<= (vla-get-lineweight ent) aclnwt025) aclnwt013)
                                      (t aclnwt030)
                                      ) ;_ end of cond
                                    ) ;_ end of vla-put-lineweight
                ) ;_ end of LAMBDA
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of vlax-for
        ) ;_ end of if
      ) ;_ end of if
    ) ;_ end of vlax-for
  (foreach item layers
    (foreach prop (cdr item)
      (vl-catch-all-apply
        (function
          (lambda ()
            (vlax-put-property (cdr (assoc "obj" item)) (car prop) (cdr prop))
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of foreach
    ) ;_ end of foreach
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

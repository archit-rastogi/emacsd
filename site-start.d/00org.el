;;; org.el --- Initialize org mode customizations

;;; Commentary:
;;

;;; Code:
(use-package org
  :bind ("C-c c" . org-capture)
  :config
  (org-babel-do-load-languages
       'org-babel-load-languages
       '((ipython . t)
         (emacs-lisp . t)
         (shell . t)
         (http . t)
         (R . t)
         (dot . t)
         (python . t)
         )
       )
  (add-hook 'org-mode-hook 'turn-on-font-lock)
  ;; save clock history across emacs sessions
  (org-clock-persistence-insinuate)
  :custom

   (org-startup-indented t)
   (org-clock-persist 'history)
   ;; org TODO cycle
   (org-todo-keywords
    '((sequence "TODO" "WIP" "|" "DONE(d)" "DELEGATED(d)")
      (sequence "NOT STARTED" "IN PROGRESS(!)" "|" "PASSED(p!)" "FAILED(f@)" "BLOCKED(b@)")
      (sequence "|" "INVALID(i@)")
      )
    )
   (org-todo-keyword-faces
    '(("NOT STARTED" . "dark cyan")
      ("PASSED" . "SeaGreen2")
      ("FAILED" . "red")
      ("BLOCKED" . "brown")
      ("IN PROGRESS" . "khaki2")
      )
    )
   
   ;; capture time stamps when TODO state changes
   (org-log-done 'time)
   ;; setting prioirty to numerals, each corresponding to P0, P1 and P2
   (org-highest-priority ?0)
   (org-lowest-priority ?2)
   (org-default-priority ?0)
   (org-clock-idle-time 10)
   (org-log-into-drawer t)
   (org-hierarchical-todo-statistics nil)
)

(provide '00org)

;;; 00org.el ends here

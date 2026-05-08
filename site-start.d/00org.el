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
      (sequence "IDEA(I)" "GOAL(G)" "OUTCOME(O)" "INSIGHT(S)" "REFERENCE(R)" "THOUGHT(T)" "|" "ACHIEVED(A)" "DISCARDED(D)")
      ;; IDEA  -- usually has an application
      ;; THOUGHT is open ended, it may crap, useful, may need refinement. It could lead to some IDEA
      ;; OUTCOME -- a measurable end result
      ;; INSIGHT -- adds another dinmension, brings color or interpretation to a subject
      ;; REFERENCE -- link artifacts like a conversation, web link, etc.
      ;; GOAL -- can be a project or an IDEA that needs to be implemented.
      ;;     A goal subsumes multiple tasks, ideas, outcomes, insights and references.
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
   (org-highest-priority 0)
   (org-lowest-priority 2)
   (org-default-priority 0)
   (org-clock-idle-time 10)
   (org-log-into-drawer t)
   (org-hierarchical-todo-statistics nil)
)

(provide '00org)

;;; 00org.el ends here

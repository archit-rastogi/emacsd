;;; gemini-commit.el --- Gemini CLI commit messages -*- lexical-binding: t; -*-

;;; my-utils.el --- Initialize org mode customizations

;;; Commentary:
;;

;;; Code:

;;; gemini-commit.el — drive gemini CLI from Emacs, no API key needed

(defgroup gemini-commit nil
  "Generate commit messages via the Gemini CLI (OAuth)."
  :group 'tools)

(defcustom gemini-commit-executable "gemini"
  "Path to the gemini CLI binary."
  :type 'string
  :group 'gemini-commit)

(defcustom gemini-commit-prompt
  "Generate a git commit message following Conventional Commits spec \
(feat/fix/docs/refactor/chore etc). Be concise. Return ONLY the commit \
message, no explanation, no markdown fences."
  "System prompt passed to gemini -p."
  :type 'string
  :group 'gemini-commit)

(defun gemini-commit--get-diff ()
  "Return the staged diff string, or nil if nothing is staged."
  (let ((diff (shell-command-to-string "git diff --cached")))
    (if (string-blank-p diff) nil diff)))

(defun gemini-commit--parse-json-response (raw)
  "Extract the .response field from gemini --output-format json output RAW."
  (condition-case _
      (let* ((json-object-type 'alist)
             (parsed (json-read-from-string raw)))
        (string-trim (alist-get 'response parsed)))
    (error (string-trim raw))))   ; fall back to raw if not JSON

(defun gemini-commit-generate ()
  "Generate a commit message using gemini cli for currently staged changes."
  (interactive)
  (let ((diff (gemini-commit--get-diff)))
    (unless diff
      (user-error "No staged changes — run `git add` first"))
    (message "⏳ Asking Gemini for a commit message...")
    (let* ((proc-buf  (generate-new-buffer " *gemini-commit-stdout*"))
           (err-buf   (generate-new-buffer " *gemini-commit-stderr*"))  ; ✅ sink for noise
           (proc (make-process
                  :name            "gemini-commit"
                  :buffer          proc-buf   ; stdout only
                  :stderr          err-buf    ; ✅ keychain warnings go here
                  :command         (list gemini-commit-executable
                                         "-p" gemini-commit-prompt
                                         "-m" "gemini-2.5-flash-lite"
                                         "--output-format" "json")
                  :connection-type 'pipe
                  :sentinel
                  (lambda (p _event)
                    (when (eq (process-status p) 'exit)
                      (let* ((raw (with-current-buffer (process-buffer p)
                                    (buffer-string)))
                             (msg (gemini-commit--parse-json-response raw)))
                        (kill-buffer (process-buffer p))
                        (kill-buffer err-buf)          ; ✅ discard stderr buf
                        (if (string-blank-p msg)
                            (message "❌ Gemini returned an empty message.")
                          (let ((commit-buf (get-buffer "COMMIT_EDITMSG")))
                            (if commit-buf
                                (with-current-buffer commit-buf
                                  (goto-char (point-min))
                                  (insert msg "\n\n"))
                              (with-current-buffer
                                  (get-buffer-create "*Gemini Commit Message*")
                                (erase-buffer)
                                (insert msg)
                                (pop-to-buffer (current-buffer)))))
                          (message "✅ Gemini commit message inserted."))))))))
      (process-send-string proc diff)
      (process-send-eof proc))))

(require 'consult)
(require 'seq)
(defun my/consult-magit-status-only ()
  "Switch to an open magit-status buffer using consult."
  (interactive)
  (let* ((magit-buffers (thread-last (buffer-list)
                         (seq-filter (lambda (buf)
                                       (with-current-buffer buf
                                         (derived-mode-p 'magit-status-mode))))
                         (mapcar #'buffer-name)
                         )
                        )
         (selected (if magit-buffers
                       (consult--read magit-buffers
                                      :prompt "Magit Status Buffers: "
                                      :category 'buffer
                                      :sort t
                                      :require-match t)
                     )
                   )
         )
    (if selected
        (switch-to-buffer selected)
      (user-error "No active Magit status buffers found")
      )
    )
  )

(defun my/unix-timestamp-to-org-date (start end &optional arg)
  "Convert a Unix timestamp at START till END to an Org-mode date string.
If ARG is non-nil, use local time instead of UTC."
  (interactive "r\nP")
  (let* ((ts-string (buffer-substring-no-properties start end))
         (ts (string-to-number ts-string))
         (formatted (if arg (format-time-string "<%Y-%m-%d %a %H:%M:%S %Z>" (seconds-to-time ts))
                      ;; default: force UTC
                      (format-time-string "<%Y-%m-%d %a %H:%M:%S %Z>" (seconds-to-time ts) 't)
                      )))
    (goto-char end)
    (insert " " formatted))
  )

(defun yank-to-mark-current-or-other-frame ()
  "Copy current region and yank to last mark position in the same window."
  (interactive)
  ;; set mark and copy
  (kill-ring-save (region-beginning) (region-end))
  ;; go to the position and yank
  (pop-global-mark)
  (yank)
  )

(defun my/get-api-key ()
  "Retrieve the API key for GitHub from auth-source."
  (let ((match (car (auth-source-search :host "api.github.com" :user "yourname"))))
    (if match
        (let ((secret (plist-get match :secret)))
          (if (functionp secret)
              (funcall secret) ;; auth-source often returns a function to evaluate
            secret))
      (error "Credentials not found in auth-source"))))

(defun my/completion-link-action (path)
  "The action to perform when clicking or hitting RET on the link."
  (if (file-directory-p path)
      (dired path)
    (find-file path))
  )

(defvar my/link-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET")
      (lambda () (interactive) (my/completion-link-action (get-text-property (point) 'path-data))))
    map)
  "Keymap for our custom completion links.")

(declare-function consult-snapfile-project-root "consult-snapfile")
(declare-function consult-snapfile-read "consult-snapfile")

(defun my/agent-shell--normalize-agent-path (path)
  "Normalize PATH for an @ reference in agent-shell.
Strip leading `#' markers from Consult async completion and repeated `@'
prefixes so Embark-injected targets become a single @-prefixed reference."
  (let ((s (string-trim (substring-no-properties path))))
    (while (string-prefix-p "#" s)
      (setq s (substring s 1)))
    (while (string-prefix-p "@" s)
      (setq s (substring s 1)))
    (string-trim s)))

(defun my/agent-shell--insert-one-agent-path (path)
  "Insert one propertized @PATH line (PATH must be already normalized)."
  (unless (string-empty-p path)
    (insert (propertize (concat "@" path)
                        'face 'link
                        'keymap my/link-keymap
                        'path-data path)
            "\n")))

(defun my/agent-shell-fuzzy-insert-file (&optional arg)
  "Insert file/dir references via consult-snapfile fuzzy matching.

No live file preview and no visiting the candidate on RET: consult's file
`state' would otherwise open the file on exit and leave point there.

The minibuffer shows no extra `#' separator because this command binds
`consult-async-split-style' to nil around the picker (see manual:
`consult-async-split-styles-alist').

\\[universal-argument]: include directories as well as files (`paths' mode).

When registered in `embark-multitarget-actions', Embark \\='act-all passes a
list of targets; each is inserted without another minibuffer prompt.

On cancel, inserts bare @ for manual typing."
  (interactive "P")
  (cond
   ;; Embark `embark-act-all' with this command on `embark-multitarget-actions':
   ;; non-interactive call with (STRING ...) candidates.
   ((and arg (listp arg) (stringp (car arg)))
    (dolist (path arg)
      (my/agent-shell--insert-one-agent-path (my/agent-shell--normalize-agent-path path))))
   ((not (fboundp 'consult-snapfile-read))
    (self-insert-command 1 ?@)
    (completion-at-point))
   (t
    (let* ((root (expand-file-name (consult-snapfile-project-root)))
           (default-directory root)
           (use-paths (> (prefix-numeric-value arg) 1))
           (prompt (format "@ %s [%s]: "
                           (if use-paths "Path" "File")
                           (abbreviate-file-name root)))
           (selected (condition-case nil
                         (let ((consult-async-split-style nil)
                               ;; Default `consult-preview-key' is `any'; combined with
                               ;; `consult-snapfile-read''s file state that enables preview
                               ;; and, worse, `consult--file-state''s `return' action opens
                               ;; the chosen file so `insert' runs there instead of agent-shell.
                               (consult-preview-key nil))
                           (consult-snapfile-read
                            :cwd root
                            :mode (if use-paths 'paths 'files)
                            :prompt prompt
                            :require-match t
                            :category 'file
                            :history 'file-name-history
                            ;; Override default file state so RET does not open the file;
                            ;; see `consult--with-preview-f' final `state' `return' hook.
                            :state #'ignore))
                       (quit nil))))
      (if selected
          (my/agent-shell--insert-one-agent-path
           (my/agent-shell--normalize-agent-path selected))
        (insert "@")))))
  )

(with-eval-after-load 'embark
  (add-to-list 'embark-multitarget-actions 'my/agent-shell-fuzzy-insert-file))

(defun my/agent-shell-setup-fuzzy-completion()
  "Use consult-completion-in-region for CAPF in agent-shell."
  (setq-local completion-in-region-function #'consult-completion-in-region)
  )

(provide 'my-utils)
;;; my-utils.el ends here

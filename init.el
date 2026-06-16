;;; init.el --- My Emacs configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; This archit's Emacs init config file

;;; Code:

(set-language-environment "UTF-8")
;; (autoload 'my-site-start "~/Documents/my-workspace/my-site-start/my-site-start" nil t)
;; (my-site-start "~/.emacs.d/site-start.d/")

;; (setenv "PATH" (concat "/usr/bin:/usr/sbin:/bin:" (getenv "PATH")))
(setenv "DICTIONARY" "english") ; set dictionary env
(setenv "TZ" "Asia/Kolkata")

;;; (setenv "GOROOT" "/usr/local/go")
;;; (setenv "GOPATH" (concat "~/Development/gocode:"
;;;                          "~/Users/architrastogi/Documents/my-workspace/cleanslate/src/"))

;; (require 'exec-path-from-shell)
;; (when (memq window-system '(mac ns x))
;;   (setq exec-path-from-shell-shell-name "/bin/zsh")
;;   (exec-path-from-shell-initialize))

;;; (toggle-debug-on-error)
(require 'package)
(add-to-list 'package-archives '("gnu" .  "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" .  "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" .  "http://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("nongnu" .  "https://elpa.nongnu.org/nongnu/"))
;; Allow ELPA to upgrade built-in packages (transient, seq, etc.) required
;; by current Magit/Forge snapshots on Emacs 30+.
(setq package-install-upgrade-built-in t)
(package-initialize)

(unless (package-installed-p 'compat)
  (package-refresh-contents)
  (package-install 'compat))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  ;; Following line is not needed if use-packageage.el is in ~/.emacs.d
  (let ((default-directory "~/.emacs.d/elpa/"))
    (normal-top-level-add-subdirs-to-load-path)
    )
  ;;; set paths
  (add-to-list 'load-path (expand-file-name "framemove/" user-emacs-directory))
  ;; (add-to-list 'load-path "~/Documents/my-workspace/ob-ipython")
  )

(require 'use-package)

;;; set global keys
;; use ibuffer and bind to C-x C-b
(global-set-key (kbd "C-x C-b") 'ibuffer)
;; set default font size
(set-face-attribute 'default nil :height 150)

(use-package orgalist-mode
  )

(use-package agent-shell
  :ensure t
  :load-path "~/code/agent-shell/"
  :ensure-system-package
  ;; Add agent installation configs here
  ((cursor-agent-acp . "npm install -g npm install -g @blowmage/cursor-agent-acp")
   )

  :defines (agent-shell-google-authentication
            agent-shell-gitignore-auto-update
            )
  :functions (agent-shell-google-make-authentication)
  :config

  (setq agent-shell-google-authentication
        (agent-shell-google-make-authentication :login t)
        )
  ;; Inhibiting minor modes during file writes
  (setopt agent-shell-write-inhibit-minor-modes '(aggressive-indent-mode)
          )
  (setq agent-shell-mcp-servers '(
                                  ;; (
                                  ;;  ((name . "yugabyte-docs")
                                  ;;   (command . "npx")
                                  ;;   (args . ("-y" "mcp-remote" "https://yugabyte.mcp.kapa.ai"))
                                  ;;   )
                                  ;;  )
                                  )
        )
  (setq agent-shell-prefer-viewport-interaction t)
  (setq agent-shell-gitignore-auto-update nil)

  :defines agent-shell-mode-map

  :bind
  (:map agent-shell-mode-map
        ("RET" . newline)
        ("C-c C-c" . shell-maker-submit)
        ("C-c C-k" . agent-shell-interrupt)
        )
  )

(use-package agent-shell-org-transcript
  :after agent-shell
  )

(use-package alert
  :commands (alert)
  :init
  (setq alert-default-style 'notifier)
  )

;;; use and configure packages
(use-package ansible
  :ensure t
  )
(use-package ansible-doc)
(use-package ansible-vault)
(use-package ansi-color
  :hook
  (compilation-filter lambda () (ansi-color-apply-on-region (point-min) (point-max)))
  :config
  (defun display-ansi-colors ()
    (interactive)
    (ansi-color-apply-on-region (point-min) (point-max)))
  )
(use-package cc-mode
  :hook
  ((java-mode . subword-mode))
  )
(use-package ciao_emacs
  :load-path (
              "/Users/arastogi/code/ciao_emacs"
              "/Users/arastogi/code/ciao_emacs/elisp"
              "/Users/arastogi/code/ciao_emacs/cmds"
              ) ;; Update to your local clone path
  ;; :vc (:url "https://github.com/ciao-lang/ciao_emacs"
  ;;      :rev :newest)
  :init
  ;; Prevent Ciao from automatically hijacking all .pl files globally
  ;; so your SWI-Prolog projects still work.
  (defvar ciao-info-dir)
  (setq ciao-info-dir "/Users/arastogi/code/ciao/build/doc/")
  (defvar ciao-library-path)
  (setq ciao-library-path "/usr/local/ciao/1.25.0") ; Point to your source build

  :commands (ciao-mode)
  ;; :config
  ;; ;; Setup path to the top-level you found earlier
  ;; (defvar ciao-main-executable)
  ;; (setq ciao-main-executable "/usr/local/ciao/1.25.0/core/library/emacs/start-ciao-toplevel")
  )
(use-package cider
  :ensure nil
  :hook ((clojure-mode . #'cider-mode))
)
;; (use-package clingo-mode
;;   )
(use-package clojure-mode
  )
(use-package cmake-mode
  :ensure nil
  )
(use-package company
  :config
  (defun my/python-mode-hook ()
    (add-to-list 'company-backends 'company-jedi))
  (add-hook 'python-mode-hook 'my/python-mode-hook)

  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 2)
  (company-tooltip-align-annotations 't)

  :hook
  (after-init . global-company-mode)
  )
(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  ;; :hook
  ;; (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any)
   )

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  ;; (setq consult-narrow-key "C-+") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)

  ;; Use `consult-completion-in-region' if Vertico is enabled.
  ;; Otherwise use the default `completion--in-region' function.
  ;; (setq completion-in-region-function
  ;;       (lambda (&rest args)
  ;;         (apply (if vertico-mode
  ;;                    #'consult-completion-in-region
  ;;                  #'completion--in-region)
  ;;                args)))
  )
(use-package consult-flycheck
  :after flycheck
  )
(use-package consult-snapfile
  :load-path "~/code/consult-snapfile/emacs"
  :demand t
  :after (consult websocket)
  ;; Optional: bind to your preferred key
  ;; :bind ("C-c s f" . consult-snapfile)

  :config
  (setq consult-snapfile-max-results 10000)
  )

(use-package cperl-mode
  :config
  (fset 'perl-mode 'cperl-mode)

  :custom
  (cperl-invalid-face nil)
  (cperl-indent-level 4)
  (cperl-indent-parens-as-block t)
  (cperl-close-paren-offset (- cperl-indent-level))
  ;; linting
  (flycheck-check-syntax-automatically '(mode-enabled save))
  (flycheck-display-errors-delay 0.3)

  :hook
  (cperl-mode . flycheck-mode)
)
(use-package csv-mode)
(use-package dap-java
  :ensure nil
  )
(use-package dap-mode
  :after lsp-mode
  :config
  (dap-auto-configure-mode)
  )
(use-package dired
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  )
(use-package docker
  :ensure nil
  :bind ("C-c d" . docker))
(use-package elfeed
  :config
  (global-set-key (kbd "C-c w") 'elfeed)

  :custom
  (elfeed-search-filter "@1-year-ago +unread ")
  (elfeed-feeds '(
                  ("https://planet.postgresql.org/rss20.xml" postgresql database)
                  ("http://rhaas.blogspot.com/feeds/posts/default" postgresql database)
                  ("https://www.cybertec-postgresql.com/en/feed/" postgresql database)
                  ("https://aws.amazon.com/blogs/database/category/database/amazon-aurora/postgresql-compatible/feed/" postgresql database)
                  ("https://postgres.ai/blog/rss.xml" postgresql database)
                  ("https://systemcrafters.net/rss/news.xml" pop_os)
                  ("https://sachachua.com/blog/category/emacs-news/feed" emacs)
                  ("https://towardsdatascience.com/feed" vector)
                  ("http://feeds.feedburner.com/kdnuggets-data-mining-analytics" vector)
                  ("https://endlessparentheses.com/atom.xml" emacs)
                  ("https://adam.chlipala.net/cpdt/updates.rss" coq)
                  ("https://serokell.io/blog.rss.xml" haskell)
                  ("https://planet.haskell.org/rss20.xml" haskell)
                  ("https://haskellweekly.news/newsletter.atom" haskell)
                  ("https://sqlancer.github.io/feed.xml" database)
                  )
                )

  ;; :hook
  ;; (elfeed-search-mode . elfeed-ai-mode)
  )
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  (create-lockfiles nil)
  (native-comp-async-report-warnings-errors 'silent)
  (insert-directory-program "/opt/homebrew/bin/gls")

  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode.  Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  (delete-by-moving-to-trash t)
  (debug-ignored-errors
   (cons 'remote-file-error debug-ignored-errors))
  (display-line-numbers-type 'relative)
  (gc-cons-threshold (* 2 100 1000 1000))
  (read-process-output-max (* 64 1024 1024))

  :hook
  (text-mode . flyspell-mode)
  (before-save . delete-trailing-whitespace)

  :config
  (when (memq window-system '(mac ns x))
    (setq mac-command-modifier 'super)
    )
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t)
  (global-display-line-numbers-mode 1)
  (electric-pair-mode 1)
  (put 'narrow-to-region 'disabled nil)
  (setq shell-command-switch "-ic")
  )
(use-package envrc
  :custom
  (envrc-direnv-executable "/opt/homebrew/bin/direnv")

  :hook (after-init . envrc-global-mode)
  )
(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))
               )
  )

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  ;; :hook
  ;; (embark-collect-mode . consult-preview-at-point-mode)
  )

;; (use-package emojify
;;   :hook (after-init . global-emojify-mode)
;;   )
;; (use-package ediprolog
;;   :config
;;   (global-set-key [f10] 'ediprolog-dwim)
;;   )
(use-package eldoc
  :init
  (global-eldoc-mode nil)
  )
(use-package elpy
  :ensure nil
  :diminish elpy-mode
  :after python
  :init
  (elpy-enable)

  :hook
  ((elpy-mode . flycheck-mode))

  :custom
  (elpy-rpc-ignored-buffer-size 512000000)
  (elpy-rpc-large-buffer-size 16384)
  (elpy-rpc-timeout 30)
  (elpy-rpc-virtualenv-path "/Users/arastogi/.pyenv/versions/3.11.4/envs/elpy2")
  (elpy-get-info-from-shell nil)
  )
(use-package epa
  :config
  (setq epg-pinentry-mode 'loopback)
  (setq auto-mode-alist (append '(("\\.gpg\\(~\\|\\.~[0-9]+~\\)?\\'" . epa-decrypt-file)) auto-mode-alist))
  )
(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config
  ;; List the variables you want to import
  (setq exec-path-from-shell-shell-name "/bin/zsh")
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH"))
  ;; Initialize
  (exec-path-from-shell-initialize)
  )

;; (use-package flx-ido
;;   :init
;;   (use-package ido)
;;   (autoload 'imenu "idomenu" nil t)

;;   :custom
;;   (ido-enable-flex-matching t)
;;   (ido-create-new-buffer 'always) ; create new buffers always, other options are prompt, never
;;   ;; disable ido faces to see flx highlights.
;;   (ido-enable-flex-matching t)
;;   (ido-use-faces nil)

;;   :config
;;   (ido-mode 'both)
;;   (ido-everywhere 1)
;;   (flx-ido-mode 1)
;;   )
(use-package flycheck
  :ensure t

  :init
  (global-flycheck-mode)

  :hook
  (
   (python-mode . flycheck-mode)
   )

  :custom
  (flycheck-idle-change-delay 2.0)
  )

(use-package flycheck-golangci-lint
  :ensure nil
  :hook ((go-mode . flycheck-golangci-lint-setup))
)
(use-package flycheck-pycheckers
  :after flycheck
  :config

  ;; (setq flycheck-pycheckers-ignore-codes
  ;;       (append '("import-untyped") flycheck-pycheckers-ignore-codes))

  :custom
  (flycheck-pycheckers-checkers '(mypy3))
  (flycheck-pycheckers-max-line-length 120)
  (flycheck-pycheckers-multi-thread "true")
  ;; (flycheck-python-pylint-executable "pylint")
  ;; (flycheck-pycheckers-pylintrc ".pylintrc")
  (flycheck-pycheckers-args "")

  ;; :hook
  ;; (
  ;;  (flycheck-mode . flycheck-pycheckers-setup))
  )
(use-package flycheck-yamllint)
(use-package flylisp)
(use-package flymake-json
  :hook ((flymake-json-load . json-mode))
  )
(use-package forge
  :ensure t
  :after magit
  )
(use-package gif-screencast
  :bind (("<f9>" . gif-screencast-start-or-stop))

  :ensure nil

  :config
  (setq gif-screencast-convert-program "magick")
  (setq gif-screencast-convert-args '("convert" "-delay" "100" "-loop" "0" "-dither" "None" "-colors" "128" "-fuzz" "40%" "-layers" "OptimizeFrame"))
  (setq gif-screencast-capture-format "region")
  (setq gif-screencast-want-optimized 't)
  (setq gif-screencast-optimize-args '("--batch" "--delay" "70" "-O3" "--colors" "128" "--lossy=80" "--resize" "980x"))
  (setq gif-screencast-program "screencapture")
  (setq gif-screencast-cropping-args '())
  (setq gif-screencast-autoremove-screenshots 't)
  (setq gif-screencast-capture-prefer-internal 't)

  ;; (setq gif-screencast-args (list "-x" "-t" "jpg"))

  ;; Create a function to generate the args dynamically
  (defvar my/gif-screencast-target-id nil
  "Stores the window ID during a recording session.")

  (advice-add 'gif-screencast-start :before
              (lambda (&rest _)
                (setq my/gif-screencast-target-id
                      (string-trim (shell-command-to-string
                                    "osascript -e 'tell application \"Emacs\" to id of window 1'")))
                ;; Inject the ID into the arguments only once
                (setq gif-screencast-args (list "-x" "-t" "png" "-l" my/gif-screencast-target-id)))
              )
  (advice-add 'gif-screencast-stop :after
              (lambda (&rest _)
                (setq my/gif-screencast-target-id nil))
              )
  )
(use-package gnuplot)
(use-package go-autocomplete
  :hook
  (
   (go-mode . (lambda () (auto-complete-mode 1))
            )
   )
  )
(use-package go-mode
  :custom
  (gofmt-command "goimports")

  :hook
  ((before-save . gofmt-before-save))

  :bind
  (:map go-mode-map
   ("M-." . godef-jump)
   ("M-*" . pop-tag-mark)
   )
  )
(use-package graphviz-dot-mode
  )

(use-package ibuffer-projectile
  )
;; (use-package ido
;;   :config
;;   (ido-everywhere 1)
;;   )
(use-package igist
  :bind (("M-o" . igist-dispatch))
  :config
  (setq igist-current-user-name "archit-rastogi")
  (setq igist-auth-marker (auth-source-pick-first-password :host "api.github.com" :user "archit-rastogi"))
  )
(use-package json-mode)
(use-package kubernetes
  :ensure nil
  :commands (kubernetes-overview)
  )
(use-package logview
  :custom
  (datetime-timezone 'Asia/Kolkata)
  :config
  (setq logview-additional-level-mappings
      (append
       '(("Glog"
          (error       "E" "F")
          (warning     "W")
          (information "I")
          (debug       "D")
          (trace       "V")
          (aliases     "glog" "GLOG" "google-log" "glog-stderr")))
       logview-additional-level-mappings)
      )
  ;; 2) Submode: I0423, time, thread id, file:line], then message.
  ;;    LEVEL and IGNORED must be adjacent: use "LEVELIGNORED< ... >" (no space).
  ;;    "NAME" uses an explicit regexp between < and >.
  (setq logview-additional-timestamp-formats
        '(
          ("Ybdb" (java-pattern . "MMdd HH:mm:ss.SSSSSS")
           (aliases "ISO 8601 Day + Month + Time + micros (a.ak MMdd HH:mm:ss.SSSSSS)"))
          )
        )
  (setq logview-additional-submodes
      (cons '("Glog" . ((format . "LEVELTIMESTAMP THREAD")
                         (levels . "Glog")
                         (timestamp . ("Ybdb"))
                         (aliases . ("glog" "GLOG" "google-log" "YDB"))))
            (and (listp logview-additional-submodes)
                 logview-additional-submodes))
      )
)
(use-package lsp-focus
  :hook
  (
   (focus-mode . lsp-focus-mode)
   )
  )
(use-package lsp-java
  :init
  (setq lsp-java-server-install-dir "/Users/arastogi/.emacs.d/.cache/lsp/eclipse.jdt.ls/")

  :custom
  (lsp-java-lens-mode 't)
  (lsp-java-format-settings-url '"/Users/arastogi/intellij-eclipse-code-style.xml")
  (lsp-java-format-settings-profile '"Default")
  (lsp-use-plists 't)
  (lsp-java-save-actions-organize-imports 't)
  (lsp-semgrep-languages (remove "java" lsp-semgrep-languages))

  (lsp-java-java-path
     (expand-file-name "bin/java"
                       (string-trim (shell-command-to-string "/usr/libexec/java_home -v 25"))))
  :config
  (add-hook 'java-mode-hook 'lsp-deferred)
  ;; JDKs used for project compile / analysis (not the LS launcher JVM)
  (setq lsp-java-configuration-runtimes
   `[(:name "JavaSE-17"
            :path ,(string-trim
                   (shell-command-to-string "/usr/libexec/java_home -v 17")
                   )
            )
     (:name "JavaSE-21"
            :path ,(string-trim
                   (shell-command-to-string "/usr/libexec/java_home -v 21")
                   )
            )
     (:name "JavaSE-25"
            :path ,(string-trim
                   (shell-command-to-string "/usr/libexec/java_home -v 25")
                   )
            :default t
            )
     ]
   )
  )
(use-package lsp-mode
  :hook
  (
   (lsp-mode . lsp-enable-which-key-integration)
   ;; (python-mode . lsp-deferred)
   (c-mode   . lsp-deferred)
   (c++-mode . lsp-deferred)
   )

  :custom
  (lsp-idle-delay 0.500)
  (lsp-completion-enable-additional-text-edit t)

  ;; Use clangd with useful flags
  (lsp-clients-clangd-args '("-j=4"
                             "--background-index"
                             "--clang-tidy"
                             "--completion-style=detailed"
                             "--header-insertion=never"
                             "--header-insertion-decorators=0"
                             "--log=error"))
  ;; Point to Homebrew LLVM clangd (Apple Silicon path)
  (lsp-clients-clangd-executable "/opt/homebrew/opt/llvm/bin/clangd")

  :functions (lsp-register-client make-lsp-client lsp-stdio-connection lsp-activate-on)

  :config
  (add-to-list 'lsp-language-id-configuration '(prolog-mode . "prolog"))

  ;; lsp server for prolog major mode
  (lsp-register-client (make-lsp-client
                        :new-connection (lsp-stdio-connection (lambda () (list "/usr/local/bin/swipl"
                                                                                 "-g" "use_module(library(lsp_server))"
                                                                                 "-g" "lsp_server:main"
                                                                                 "-t" "halt"
                                                                                 "--" "stdio")))
                        :activation-fn (lsp-activate-on "prolog")
                        :major-modes '(prolog-mode)
                        :priority 1
                        :multi-root t
                        :server-id 'swi-prolog-lsp
                        ))
  )
;; (use-package lsp-pylsp
;;   :custom
;;   (lsp-pylsp-plugins-rope-autoimport-enabled t)
;;   (lsp-pylsp-plugins-jedi-use-pyenv-environment t)
;;   (lsp-pylsp-plugins-mypy-enabled t)
;;   (lsp-pylsp-plugins-yapf-enabled t)
;;   (lsp-pylsp-plugins-flake8-enabled t)
;;   (lsp-pylsp-plugins-pylint-enabled t)
;;   (lsp-pylsp-plugins-isort-enabled t)
;;   (lsp-pylsp-plugins-autopep8-enabled nil)
;;   )
(use-package lsp-treemacs
  :custom
  (treemacs-follow-mode t)
  )
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable 't)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-sideline-enable 't)
  (lsp-ui-sideline-show-diagnostics 't)
  (lsp-ui-peek-enable 't)

  )
(use-package magit
  :ensure nil
  :custom
  (magit-diff-section-arguments (quote ("--no-ext-diff")))
  (magit-dispatch-arguments nil)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (magit-refresh-status-buffer nil)
  (auto-revert-buffer-list-filter
   'magit-auto-revert-repository-buffer-p)
  )

(use-package marginalia
  :ensure nil
  :after vertico
  :config
  (marginalia-mode)
  )
;; (use-package mcp-server
;;   :load-path "~/code/emacs-mcp-server/"
;;   :functions (mcp-server-start-unix)
;;   :config
;;   (add-hook 'emacs-startup-hook #'mcp-server-start-unix)
;;   (setq mcp-server-security-sensitive-file-patterns
;;       '("~/.authinfo*"    ; glob: matches .authinfo, .authinfo.gpg, .authinfo.enc, ...
;;         "~/.ssh/"         ; prefix: matches everything under ~/.ssh/
;;         "~/.yugabyte/"    ; prefix: matches everything under ~/.yugabyte/
;;         "~/my-secrets/"   ; prefix: matches everything under ~/my-secrets/
;;         ".key")          ; basename: matches any file whose name contains ".key"
;;       )
;;   (setq mcp-server-security-dangerous-functions
;;         '(delete-file shell-command require load)
;;         )
;;   (setq mcp-server-security-sensitive-buffer-patterns
;;         '("*Messages*" "*shell*" "*my-secure-buffer*")
;;         )
;;   )
(use-package mc-extras)
(use-package menu-bar
  ;;; diable menu-bar
  :config
  (menu-bar-mode -1)
  )

(use-package my-utils
  :load-path "my-utils/"
  :demand t
  :ensure nil  ;; Crucial: Tells use-package not to try downloading it from ELPA/MELPA
  :functions (gemini-commit-generate
              my/agent-shell-fuzzy-insert-file
              my/agent-shell-setup-fuzzy-completion
              )
  :defines git-commit-mode-map

  :bind
  ("C-c t u" . my/unix-timestamp-to-org-date)
  ("C-x C-g" . my/consult-magit-status-only)

  :hook
  (
   (agent-shell-mode . my/agent-shell-setup-fuzzy-completion)
   )

  :config
  ;; Magit integration: add to the commit transient
  (with-eval-after-load 'magit
    (transient-append-suffix 'magit-commit "c"
      '("G" "Gemini message" gemini-commit-generate))
    )
  (with-eval-after-load 'git-commit
    ;; Keybinding in git-commit-mode buffers
    (define-key git-commit-mode-map (kbd "C-c C-g") #'gemini-commit-generate)
    )

  (with-eval-after-load 'agent-shell
    (keymap-set agent-shell-mode-map "@" #'my/agent-shell-fuzzy-insert-file)
    (keymap-set agent-shell-viewport-edit-mode-map "@" #'my/agent-shell-fuzzy-insert-file)
  )
  (message "My custom utilities are ready!")
  )

(use-package multiple-cursors
  :bind (
         ;; for active region per line
         ("C-S-c C-S-c" . mc/edit-lines)

         ;; using keywords
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         )
  )
(use-package multishell)
;; (use-package nlinum)
;; (use-package nlinum-relative
;;   :hook ((prog-mode . nlinum-relative-mode))

;;   :custom
;;   (nlinum-relative-redisplay-delay 0.2)      ;; delay
;;   (nlinum-relative-current-symbol "")      ;; or "" for display current line number
;;   (nlinum-relative-offset 0)                 ;; 1 if you want 0, 2, 3...
;;   )

(use-package xml-format
  :demand t
  :after nxml-mode)

(use-package orderless
  :ensure nil
  :custom
  (completion-styles '(substring orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion))))
  )
(use-package org
  :mode ("\\.org'" . org-mode)
  :hook ((org-mode . (lambda ()
                       (org-bullets-mode 1)
                       (set-fill-column 120)
                       (auto-fill-mode 1)
                       (visual-line-mode 1)
                       )
                   )
         )
  :custom
  ;; configuring refile
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)

  (org-directory "~/org-scratch/")
  (org-agenda-files '(
                      "~/org-scratch/inbox/"
                      "~/org-scratch/professional/"
                      "~/org-scratch/personal/"
                      ))
  (org-capture-templates
   '((
      "w" "Work Unstaged"
      entry
      (file "inbox/work_unstaged.org")
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n%a"
      )
     (
      "s" "Stand Up"
      entry
      (file "inbox/work_standup.org")
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n%a"
      )
     (
      "p" "Personal Unstaged"
      entry (file "inbox/personal_unstaged.org")
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n%a"
      )
     )
   )

  :bind
  ("C-c c" . org-capture)
  )

(use-package org-attach-screenshot
  :custom
  (org-attach-screenshot-relative-links t)
  (org-attach-screenshot-auto-refresh 'never)
  (org-attach-screenshot-command-line "/usr/sbin/screencapture -i %f")
  )

(use-package org-bullets)

(use-package org-protocol
  :custom
  (org-protocol-protocol-alist '())
  )

(use-package org-roam
  :ensure t

  :custom
  (org-roam-directory "~/org-scratch/")

  :bind (
         ("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         )
  :config
  (org-roam-db-autosync-mode)
  )

;; (use-package org-gcal)
(use-package ox-hugo
  :ensure t
  :after ox
  )
(use-package package
  :ensure nil

  :hook
  (package-menu-mode . tablist-minor-mode)
  )
(use-package paredit
  ;; :hook (prog-mode . enable-paredit-mode)
 )
(use-package paren
  ;; highlight matching parenthesis
  :init
  (show-paren-mode 1)
  )
(use-package pandoc-mode
  :ensure t
  )
(use-package pdf-tools)
(use-package ripgrep)
(use-package projectile
  :ensure t
  :init (projectile-mode +1)

  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (add-to-list 'projectile-project-root-files-bottom-up "pom.xml")
  (setq projectile-ignored-projects 'nil)
  )
(use-package prolog
  :config
  (autoload 'run-prolog "prolog" "Start a Prolog sub-process." t)
  (autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
  (autoload 'mercury-mode "prolog" "Major mode for editing Mercury programs." t)
  ;; (setq prolog-system 'swi)
  (put 'prolog-system 'safe-local-variable #'symbolp)
  (setq auto-mode-alist (append '(("\\.pl$" . prolog-mode)
                                  ("\\.m$" . mercury-mode))
                                auto-mode-alist))
  :hook
  ((prolog-mode . (lambda ()
                    (when (eq (bound-and-true-p prolog-system) 'ciao)
                      (ciao-mode)
                      )
                    (when (eq (bound-and-true-p prolog-system) 'swi)
                      (lsp-deferred)
                      )
                    )
                )
   )
  )
;; (use-package py-isort
;;   :hook ((before-save . py-isort-before-save))
;;   )
;; (use-package py-autopep8
;;   :hook ((elpy-mode . py-autopep8-mode))
;;   )
(use-package python
  :after flycheck
  :functions (flycheck-add-next-checker)
  :config
  (setq python-shell-completion-native-enable nil)
  (flycheck-add-next-checker 'python-pycompile 'python-ruff)
  ;; (flycheck-add-next-checker 'python-ruff 'python-flake8)
  (flycheck-add-next-checker 'python-ruff '(t . python-pyright))
  ;; (flycheck-add-next-checker 'python-pyright 'python-pylint)
  (flycheck-add-next-checker 'python-pyright '(error . python-mypy))
  )

(use-package python-black
  :demand t
  :after python
  ;; :hook (python-mode . python-black-on-save-mode-enable-dwim)
  )
(use-package pyvenv
  :demand t
  :custom
  (pyvenv-exec-shell "/bin/zsh")

  :config
  (pyvenv-tracking-mode 1)

  :hook
  (python-mode . pyvenv-mode)
  )
(use-package savehist
  :init
  (savehist-mode)
  )
(use-package scala-mode
  )
(use-package scroll-bar
  ;disable scroll bar - horizontal and vertical
  :config
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))
  (when (fboundp 'horizontal-scroll-bar-mode)
    (horizontal-scroll-bar-mode -1))
  )

(use-package sideline
  ;; :hook (flycheck-mode . sideline-mode)
  :init
  (setq sideline-backends-right '(sideline-flycheck))
  )

(use-package sideline-flycheck
  ;; :hook (flycheck-mode . sideline-flycheck-setup)
  )

(use-package slack
  :bind (("C-c S K" . slack-stop)
         ("C-c S c" . slack-select-rooms)
         ("C-c S u" . slack-select-unread-rooms)
         ("C-c S U" . slack-user-select)
         ("C-c S s" . slack-search-from-messages)
         ("C-c S J" . slack-jump-to-browser)
         ("C-c S j" . slack-jump-to-app)
         ("C-c S e" . slack-insert-emoji)
         ("C-c S E" . slack-message-edit)
         ("C-c S r" . slack-message-add-reaction)
         ("C-c S t" . slack-thread-show-or-create)
         ("C-c S g" . slack-message-redisplay)
         ("C-c S G" . slack-conversations-list-update-quick)
         ("C-c S q" . slack-quote-and-reply)
         ("C-c S Q" . slack-quote-and-reply-with-link)
         (:map slack-mode-map
               (("@" . slack-message-embed-mention)
                ("#" . slack-message-embed-channel)))
         (:map slack-thread-message-buffer-mode-map
               (("C-c '" . slack-message-write-another-buffer)
                ("@" . slack-message-embed-mention)
                ("#" . slack-message-embed-channel)))
         (:map slack-message-buffer-mode-map
               (("C-c '" . slack-message-write-another-buffer)))
         (:map slack-message-compose-buffer-mode-map
               (("C-c '" . slack-message-send-from-buffer)))
         )
  :custom
  (slack-extra-subscribed-channels (mapcar 'intern (list "proj-pgvector")))
  (slack-prefer-current-team 't)
  (slack-buffer-create-on-notify nil)

  :hook
  (slack-mode 'emojiy-mode)

  :config
  (slack-register-team
     :name "Yugabyte"
     :token (auth-source-pick-first-password :host "Yugabyte.slack.com" :user "arastogi@yugabyte.com")
     :cookie (funcall (plist-get (car (auth-source-search :host "Yugabyte.slack.com" :user "arastogi@yugabyte.com^cookie")) :secret))
     :full-and-display-names t
     :default t
     :subscribed-channels nil ;; using slack-extra-subscribed-channels because I can change it dynamically
     )
  )

(use-package stem-reading-mode
  ;; :config
  ;; (set-face-attribute 'stem-reading-highlight-face nil :weight 'unspecified)
  ;; (set-face-attribute 'stem-reading-delight-face nil :weight 'light)
  )
;; (use-package sweeprolog
;;   :custom
;;   (sweeprolog-swipl-path "/Applications/SWI-Prolog.app/Contents/MacOS/swipl")
;;   :config
;;   (push "--stack-limit=512m" sweeprolog-init-args)
;;   )
(use-package tzc
  :ensure t
  )
(use-package tool-bar
  ; disable tool bar
  :init
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))
  )
(use-package tracking
  :bind (
         :map tracking-mode-map
         ("<f11" . tracking-next-buffer)
         )
  )
(use-package tramp
  :custom
  (tramp-ssh-controlmaster-options
        (concat
         "-o ControlPath=/tmp/ssh-tramp-%%r@%%h:%%p "
         "-o ControlMaster=auto -o ControlPersist=yes "
         "-o ServerAliveInterval=60"))
  (remote-file-name-inhibit-locks t)
  (vc-handled-backends '(Git))
  (tramp-verbose 0)
  (tramp-chunksize 500)
  )
;; Enable vertico
(use-package vertico
  :ensure t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'

  :init
  ;; (defmacro set-local (var val) `(setq-local ,var ,val))
  (vertico-mode)

  :config
  ;; Option 1: Additional bindings
  (keymap-set vertico-map "?" #'minibuffer-completion-help)
  (keymap-set vertico-map "M-RET" #'minibuffer-force-complete-and-exit)
  (keymap-set vertico-map "M-TAB" #'minibuffer-complete)

  ;; Option 2: Replace `vertico-insert' to enable TAB prefix expansion.
  ;; (keymap-set vertico-map "TAB" #'minibuffer-complete)
  )
(use-package vlf-setup
  :custom
  (vlf-application 'dont-ask)
  )
(use-package websocket
  :ensure t
  )
(use-package which-key
  )
(use-package yaml-mode
  )
(use-package yasnippet
  :config
  (yas-global-mode)
  )
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
  )
(use-package framemove
  :ensure nil
  :init
  (use-package cl-lib)

  :config
  (when (fboundp 'windmove-default-keybindings)
    ;; (windmove-default-keybindings 'meta)
    (custom-set-variables
     '(framemove-hook-into-windmove t)
     )
    ;; set global keybindings
    (global-set-key (kbd "<left>")  'windmove-left)
    (global-set-key (kbd "<right>") 'windmove-right)
    (global-set-key (kbd "<up>")    'windmove-up)
    (global-set-key (kbd "<down>")  'windmove-down)
    )
  )

(setq custom-file "~/.emacs.d/.emacs-custom.el")
(load custom-file)

;;; init.el ends here

;; ; @begin(76524150)@ - Do not edit these lines - added automatically!
;; (if (file-exists-p "/Users/arastogi/code/ciao/ciao_emacs/elisp/ciao-site-file.el")
;;   (load-file "/Users/arastogi/code/ciao/ciao_emacs/elisp/ciao-site-file.el"))
;; ; @end(76524150)@ - End of automatically added lines.

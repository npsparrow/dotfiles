;; -*- lexical binding: t; -*-

;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

(require 'package)
(setq package-check-signature nil)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                            ("org" . "https://orgmode.org/elpa/")
                            ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)

(setq custom-file "~/.config/emacs/custom-file.el")
(load-file custom-file)

(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; (global-hl-line-mode 1)
;; (set-face-background hl-line-face "#242534")

(setq-default
  load-prefer-newer t
  inhibit-startup-message t
  indent-tabs-mode nil
  create-lockfiles nil
  auto-save-default nil
  enable-recursive-minibuffers t
  electric-indent-inhibit t
  read-file-name-completion-ignore-case t)

(setq-default fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

;; backup directory. makes things less messy
(setq backup-directory-alist `(("." . "~/.config/emacs/.emacs.bak")))

;; mouse wheel stuff
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)

(global-auto-revert-mode t) ;; auto update on change in buffer

;; fix y/n
(defalias 'yes-or-no-p 'y-or-n-p)
(setq use-dialog-box nil)

;; save minibuffer hist + register hist
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'register-alist)

;; remember cursor location
(save-place-mode 1)

;; highlighting!
(setq org-src-fontify-natively t)
(setq org-src-preserve-indentation t)

(require 'treesit)
(setq treesit-extra-load-path '("./dist/"))
(setq major-mode-remap-alist
  '((yaml-mode . yaml-ts-mode)
    (bash-mode . bash-ts-mode)
    (js2-mode . js-ts-mode)
    (typescript-mode . typescript-ts-mode)
    (json-mode . json-ts-mode)
    (css-mode . css-ts-mode)
    (c++-mode . c++-ts-mode)
    (c-or-c++-mode . c-or-c++-ts-mode)
    (c-mode . c-ts-mode)
    (cmake-mode . cmake-ts-mode)
    (csharp-mode . csharp-ts-mode)
    (go-mod-mode . go-mod-ts-mode)
    (go-mode . go-ts-mode)
    (java-mode . java-ts-mode)
    (ruby-mode . ruby-ts-mode)
    (rust-mode . rust-ts-mode)
    (tsx-mode . tsx-ts-mode)
    (python-mode . python-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))

(column-number-mode)

(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq display-line-numbers-type 'relative)

  (set-face-attribute 'default nil
                      :family "Lilex Nerd Font"
                      :height 110
                      :weight 'normal
                      :width 'normal)

;; (use-package catppuccin-theme
;;   :config
;;   (load-theme 'catppuccin :no-confirm))
(load-theme 'catppuccin t)

(use-package mood-line
  :config
  (mood-line-mode))

(use-package minions
  :config (minions-mode 1))

(use-package undo-tree
  :diminish
  :config
  (setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))
  (global-undo-tree-mode 1))

(use-package evil
  :after undo-tree
  :init
  (setq
    evil-shift-width 2
    evil-insert-state-cursor 'box
    evil-want-C-u-delete t
    evil-want-C-u-scroll t
    evil-kill-on-visual-paste nil
    evil-undo-system 'undo-tree
    evil-want-keybinding nil
    evil-want-c-i-jump nil)

  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-tex
  :hook (LaTeX-mode . evil-tex-mode))

(use-package vertico
  :init
  (vertico-mode))

(setq vertico-multiform-commands
      '((consult-line (:not posframe))
        (t posframe)))
(vertico-multiform-mode 1)

(use-package vertico-posframe
  :after vertico
  :init
  (vertico-posframe-mode 1))

(use-package emacs
  :init

  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

(use-package flycheck
  :init
  (global-flycheck-mode)
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
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
         ("M-s D" . consult-locate)
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
  :hook (completion-list-mode . consult-preview-at-point-mode)

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
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

(use-package consult-flycheck)

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package corfu
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin
  (corfu-auto-prefix 3)
  (corfu-auto-delay 0.1)

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `global-corfu-modes'.
  :init
  (global-corfu-mode)
  :config
  (define-key prog-mode-map (kbd "M-TAB") #'complete-symbol)
  (define-key corfu-map (kbd "M-TAB") #'corfu-complete)
  (define-key corfu-map (kbd "M-<tab>") #'corfu-complete)
  (define-key corfu-map (kbd "TAB") #'yas-expand)
  (define-key corfu-map (kbd "<tab>") #'yas-expand))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p))

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  ;; (setq tab-always-indent 'complete))

;; Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind (("M-p p" . completion-at-point) ;; capf
         ("M-p t" . complete-tag)        ;; etags
         ("M-p d" . cape-dabbrev)        ;; or dabbrev-completion
         ("M-p h" . cape-history)
         ("M-p f" . cape-file)
         ("M-p k" . cape-keyword)
         ("M-p s" . cape-elisp-symbol)
         ("M-p e" . cape-elisp-block)
         ("M-p a" . cape-abbrev)
         ("M-p l" . cape-line)
         ("M-p w" . cape-dict)
         ("M-p \\" . cape-tex)
         ("M-p _" . cape-tex)
         ("M-p ^" . cape-tex)
         ("M-p &" . cape-sgml)
         ("M-p r" . cape-rfc1345))
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
)

(use-package orderless
  :demand t
  :config

  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
        (format "[%c-%c]*$"
                consult--tofu-char
                (+ consult--tofu-char consult--tofu-range -1))
      "$"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  ;; Define orderless style with initialism by default
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  ;; You may want to combine the `orderless` style with `substring` and/or `basic`.
  ;; There are many details to consider, but the following configurations all work well.
  ;; Personally I (@minad) use option 3 currently. Also note that you may want to configure
  ;; special styles for special completion categories, e.g., partial-completion for files.
  ;;
  ;; 1. (setq completion-styles '(orderless))
  ;; This configuration results in a very coherent completion experience,
  ;; since orderless is used always and exclusively. But it may not work
  ;; in all scenarios. Prefix expansion with TAB is not possible.
  ;;
  ;; 2. (setq completion-styles '(substring orderless))
  ;; By trying substring before orderless, TAB expansion is possible.
  ;; The downside is that you can observe the switch from substring to orderless
  ;; during completion, less coherent.
  ;;
  ;; 3. (setq completion-styles '(orderless basic))
  ;; Certain dynamic completion tables (completion-table-dynamic)
  ;; do not work properly with orderless. One can add basic as a fallback.
  ;; Basic will only be used when orderless fails, which happens only for
  ;; these special tables.
  ;;
  ;; 4. (setq completion-styles '(substring orderless basic))
  ;; Combine substring, orderless and basic.
  ;;
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;;; Enable partial-completion for files.
        ;;; Either give orderless precedence or partial-completion.
        ;;; Note that completion-category-overrides is not really an override,
        ;;; but rather prepended to the default completion-styles.
        ;; completion-category-overrides '((file (styles orderless partial-completion))) ;; orderless is tried first
        completion-category-overrides '((file (styles partial-completion)) ;; partial-completion is tried first
                                        ;; enable initialism by default for symbols
                                        (command (styles +orderless-with-initialism))
                                        (variable (styles +orderless-with-initialism))
                                        (symbol (styles +orderless-with-initialism)))
        orderless-component-separator #'orderless-escapable-split-on-space ;; allow escaping space with backslash!
        orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                          #'orderless-affix-dispatch)))

(use-package yasnippet
  :config (yas-global-mode 1))

(use-package yasnippet-snippets)

(use-package tex
  :ensure auctex
  :config
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (add-to-list 'TeX-command-list
                           '("LaTeXmk"
                             "latexmk -pvc -f -pdf -pdflatex=\"pdflatex -synctex=1 -interaction=nonstopmode --shell-escape\""
                             TeX-run-TeX nil t
                             :help "Run LaTeXmk continuously"))))
  ;; enable synctex support for latex-mode
  (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
  ;; add a new view program
  (add-to-list 'TeX-view-program-list
        '(;; arbitrary name for this view program
          "Zathura"
          (;; zathura command (may need an absolute path)
           "zathura"
           ;; %o expands to the name of the output file
           " %o"
           ;; insert page number if TeX-source-correlate-mode
           ;; is enabled
           (mode-io-correlate " --synctex-forward %n:0:%b"))))
  ;; use the view command named "Zathura" for pdf output
  (setcdr (assq 'output-pdf TeX-view-program-selection) '("Zathura")))

(use-package nix-mode
  :mode "\\.nix\\'")



(use-package toml-mode)
(use-package rust-mode)
(setq rust-format-on-save t)
(add-hook 'rust-mode-hook
          (lambda () (prettify-symbols-mode)))

(use-package cargo-mode
  :hook (rust-ts-mode . cargo-minor-mode))

;; (use-package cargo-mode
;;   :hook (rust-ts-mode . cargo-minor-mode))
;; (setq compilation-scroll-output t)

(use-package rustic
  :init
  (setq rustic-lsp-client 'eglot)
  (add-hook 'eglot--managed-mode-hook (lambda () (flymake-mode -1))))

(use-package flycheck-rust)
(use-package flycheck-inline
  :after flycheck
  :init
  (add-hook 'flycheck-mode-hook #'flycheck-inline-mode))

(use-package haskell-mode)

(use-package eglot
  :hook
  ((go-ts-mode . eglot-ensure)
    (rust-ts-mode . eglot-ensure)
    (haskell-mode . eglot-ensure)))

(use-package calfw)
(use-package calfw-org)

(use-package toc-org
  :config
  (add-hook 'org-mode-hook 'toc-org-mode)
  (add-hook 'markdown-mode-hook 'toc-org-mode)
  (define-key markdown-mode-map (kbd "\C-c\C-o") 'toc-org-markdown-follow-thing-at-point))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "ASSIGNMENT(a)" "|" "COMPLETE(c)")
        (sequence "MAYBE(m)")
        (sequence "SOMEDAY(s)")))

(setq org-agenda-files nil)
(use-package org-super-agenda
  :init (org-super-agenda-mode))
(let ((org-super-agenda-groups
       '(;; Each group has an implicit boolean OR operator between its selectors.
         (:name "Schedule"
                :time-grid t)
         (:name "Today"
                :deadline today
                :scheduled today)
         (:name "Assignments"
                :todo "ASSIGNMENT"
                :tag "class"
                :priority "A")
         ;; Groups supply their own section names when none are given
         (:todo "WAITING" :order 8)  ; Set order of this section
         (:name "Unimportant"
                :todo ("SOMEDAY" "MAYBE")
                :order 9)
         )))
  (org-agenda-list))

(defconst notes-directory "/home/nikhil/stuff/notes/")
(defconst notes-other-directory "src/")

(defun sparrow/check-notes-dir ()
  (interactive)
  "Open in org-mode if file in notes dir"
  (if (when (>= (length buffer-file-name) (length notes-directory))
        (and (string= notes-directory
                      (substring buffer-file-name 0 (length notes-directory)))
             (or (< (length buffer-file-name)
                    (+ (length notes-directory)
                       (length notes-other-directory)))
                 (not (string= notes-other-directory
                               (substring buffer-file-name
                                          (length notes-directory)
                                          (+ (length notes-directory)
                                             (length notes-other-directory))))))))
      (org-mode)))

(add-hook 'find-file-hook #'sparrow/check-notes-dir)

;; now and today come from journal.el
(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%D %-I:%M %p")))

(defun today ()
  "Insert string for today's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%A, %B %e, %Y")))

;; Get the time exactly 24 hours from now.  This produces three integers,
;; like the current-time function.  Each integers is 16 bits.  The first and second
;; together are the count of seconds since Jan 1, 1970.  When the second word
;; increments above 6535, it resets to zero and carries 1 to the high word.
;; The third integer is a count of milliseconds (on machines which can produce
;; this granularity).  The math in the defun below, then, is to accommodate the
;; way the current-time variable is structured.  That is, the number of seconds
;; in a day is 86400.  In effect, we add 65536 (= 1 in the high word) + 20864
;; to the current-time.  However, if 20864 is too big for the low word, if it
;; would create a sum larger than 65535, then we "add" 2 to the high word and
;; subtract 44672 from the low word.

(defun tomorrow-time ()
 "*Provide the date/time 24 hours from the time now in the same format as current-time."
  (setq
   now-time (current-time)              ; get the time now
   hi (car now-time)                    ; save off the high word
   lo (car (cdr now-time))              ; save off the low word
   msecs (nth 2 now-time)               ; save off the milliseconds
   )

  (if (> lo 44671)                      ; If the low word is too big for adding to,
      (setq hi (+ hi 2)  lo (- lo 44672)) ; carry 2 to the high word and subtract from the low,
    (setq hi (+ hi 1) lo (+ lo 20864))  ; else, add 86400 seconds (in two parts)
    )
  (list hi lo msecs)                    ; regurgitate the new values
  )

;(tomorrow-time)

(defun tomorrow ()
  "Insert string for tomorrow's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%A, %B %e, %Y" (tomorrow-time)))
)



;; Get the time exactly 24 hours ago and in current-time format, i.e.,
;; three integers.  Each integers is 16 bits.  The first and second
;; together are the count of seconds since Jan 1, 1970.  When the second word
;; increments above 6535, it resets to zero and carries 1 to the high word.
;; The third integer is a count of milliseconds (on machines which can produce
;; this granularity).  The math in the defun below, then, is to accomodate the
;; way the current-time variable is structured.  That is, the number of seconds
;; in a day is 86400.  In effect, we subtract (65536 [= 1 in the high word] + 20864)
;; from the current-time.  However, if 20864 is too big for the low word, if it
;; would create a sum less than 0, then we subtract 2 from the high word
;; and add 44672 to the low word.

(defun yesterday-time ()
"Provide the date/time 24 hours before the time now in the format of current-time."
  (setq
   now-time (current-time)              ; get the time now
   hi (car now-time)                    ; save off the high word
   lo (car (cdr now-time))              ; save off the low word
   msecs (nth 2 now-time)               ; save off the milliseconds
   )

  (if (< lo 20864)                      ; if the low word is too small for subtracting
      (setq hi (- hi 2)  lo (+ lo 44672)) ; take 2 from the high word and add to the low
    (setq hi (- hi 1) lo (- lo 20864))  ; else, add 86400 seconds (in two parts)
    )
  (list hi lo msecs)                    ; regurgitate the new values
  )                                     ; end of yesterday-time

(defun yesterday ()
  "Insert string for yesterday's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  (insert (format-time-string "%A, %B %e, %Y" (yesterday-time)))
)

(defconst daily-notes-suffix ".daily")

;; filename idea also from journal.el
(defun todays-note ()
  "Gets filename of today's daily note"
  (interactive)
  (concat (format-time-string "%Y-%m-%d-%a") daily-notes-suffix))

(defun yesterdays-note ()
  "Gets filename of today's daily note"
  (interactive)
  (concat (format-time-string "%Y-%m-%d-%a" (yesterday-time)) daily-notes-suffix))

(defun tomorrows-note ()
  "Gets filename of today's daily note"
  (interactive)
  (concat (format-time-string "%Y-%m-%d-%a" (tomorrow-time)) daily-notes-suffix))

(use-package magit)

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

;; (use-package treemacs-projectile
;;   :after (treemacs projectile)
;;   :ensure t)

;; (use-package treemacs-icons-dired
;;   :hook (dired-mode . treemacs-icons-dired-enable-once))

;; (use-package treemacs-magit
;;   :after (treemacs magit)
;;   :ensure t)

;; (use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
;;   :after (treemacs persp-mode) ;;or perspective vs. persp-mode
;;   :ensure t
;;   :config (treemacs-set-scope-type 'Perspectives))

;; (use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
;;   :after (treemacs)
;;   :ensure t
;;   :config (treemacs-set-scope-type 'Tabs))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; (use-package nerd-icons-completion
;;   :after marginalia
;;   :config
;;   (nerd-icons-completion-mode)
;;   (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package treemacs-nerd-icons
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)

  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

(use-package which-key
  :config (which-key-mode))

(use-package sudo-edit)

(use-package vterm)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

 ;; window movement / management
(defhydra hydra-window (:hint nil)
   "
Movement      ^Split^            ^Switch^        ^Resize^
----------------------------------------------------------------
_j_ ←           _v_ertical         _b_uffer        _u_ ←
_k_ ↓           _h_orizontal       _f_ind files    _i_ ↓
_l_ ↑           _1_only this       _P_rojectile    _o_ ↑
_;_ →           _d_elete           _s_wap          _p_ →
_F_ollow        _e_qualize         _[_backward     _8_0 columns
_q_uit          ^        ^         _]_forward
"
  ("j" windmove-left)
  ("k" windmove-down)
  ("l" windmove-up)
  (";" windmove-right)
  ("[" previous-buffer)
  ("]" next-buffer)
  ("u" hydra-move-splitter-left)
  ("i" hydra-move-splitter-down)
  ("o" hydra-move-splitter-up)
  ("p" hydra-move-splitter-right)
  ("b" ivy-switch-buffer)
  ("f" counsel-find-file)
  ("P" counsel-projectile-find-file)
  ("F" follow-mode)
  ("s" switch-window-then-swap-buffer)
  ("8" set-80-columns)
  ("v" split-window-right)
  ("h" split-window-below)
  ("3" split-window-right)
  ("2" split-window-below)
  ("d" delete-window)
  ("1" delete-other-windows)
  ("e" balance-windows)
  ("q" nil))

(defun hydra-move-splitter-left (arg)
  "Move window splitter left."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'right))
      (shrink-window-horizontally arg)
    (enlarge-window-horizontally arg)))

(defun hydra-move-splitter-right (arg)
  "Move window splitter right."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'right))
      (enlarge-window-horizontally arg)
    (shrink-window-horizontally arg)))

(defun hydra-move-splitter-up (arg)
  "Move window splitter up."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'up))
      (enlarge-window arg)
    (shrink-window arg)))

(defun hydra-move-splitter-down (arg)
  "Move window splitter down."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'up))
      (shrink-window arg)
    (enlarge-window arg)))
;; Assign Hydra to hotkey
;; (global-unset-key (kbd "s-w"))
;; (global-set-key (kbd "s-w") 'hydra-window/body)

(defun sparrow/zathura-goto ()
  "Goes to this line in output pdf (synctex)"
  (interactive)
  (shell-command (format "zathura %s --synctex-forward %d:0:%s"
                         (concat (substring (buffer-file-name) 0 -3) "pdf")
                         (line-number-at-pos)
                         (buffer-file-name))))

(defun sparrow/set-register-current-frame (n &optional s)
  "Sets register n to current frame\'s window configuration"
  (interactive)
  (window-configuration-to-register n (read-string "Configuration Name: " s)))

(use-package general
:config
(general-evil-setup t)

(general-create-definer sparrow/leader
  :states '(normal visual motion)
  :keymaps 'override
  :prefix "SPC")

(general-define-key
 :states '(normal visual motion)
 :keymaps 'LaTeX-mode-map
 "gz" '(sparrow/zathura-goto :which-key "Highlight current line in pdf"))

(sparrow/leader "" '(nil :which-key "SPC leader"))
(sparrow/leader "." '(find-file :which-key "find file"))
(sparrow/leader "SPC" '(find-file :which-key "find file"))
(sparrow/leader "r" '(consult-register :which-key "find file"))
(sparrow/leader "/" '(consult-line :which-key "search"))
(sparrow/leader "\`" '(vterm :which-key "vterm"))
(sparrow/leader "," '(consult-buffer :which-key "switch buffers"))
(sparrow/leader "TAB" '(treemacs :which-key "open treemacs"))
(sparrow/leader "a" '(org-agenda-list :which-key "open org-agenda"))
(sparrow/leader "i" '(cfw:open-org-calendar :which-key "open calendar"))

(sparrow/leader "b" '(nil :which-key "buffers"))
(sparrow/leader "bb" '(consult-buffer :which-key "switch buffers"))
(sparrow/leader "bk" '(kill-buffer :which-key "kill buffer"))
(sparrow/leader "bm" '(nil :which-key "kill all other buffers NOT IMPL"))
(sparrow/leader "bs" '(nil :which-key "go to scratch buffer NOT IMPL"))

(sparrow/leader "g" '(nil :which-key "magit"))

(sparrow/leader "gg" '((lambda () (interactive)(magit-status))
                      :which-key "view git status"))
(sparrow/leader "gi" '((lambda () (interactive)(magit-init))
                      :which-key "init new repo"))

(sparrow/leader "f" '(nil :which-key "find common files"))
(sparrow/leader "ft" '((lambda () (interactive)(find-file "~/stuff/notes/todo"))
                                :which-key "todo page"))
(sparrow/leader "fd" '((lambda () (interactive)(find-file (concat notes-directory (todays-note))))
                                :which-key "today\'s daily note"))
(sparrow/leader "fe" '((lambda () (interactive)(find-file "~/.config/emacs/settings.org"))
                                :which-key "emacs config"))
(sparrow/leader "fi" '((lambda () (interactive)(find-file "~/stuff/notes/index"))
                                :which-key "notes index"))
(sparrow/leader "fh" '((lambda () (interactive)(find-file "~/.config/hypr/hyprland.conf"))
                                :which-key "hyprland config"))

(sparrow/leader "c" '(nil :which-key "misc"))
(sparrow/leader "cz" '(hydra-text-scale/body :which-key "zoom hydra"))
(sparrow/leader "cw" '(hydra-window/body :which-key "manage windows"))


(sparrow/leader "t" '(org-todo :which-key "set TODO heading")))

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000))))

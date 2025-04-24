;; -*- lexical binding: t; -*-

;; minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; initialize packages
(package-initialize)

;; load custom file
(setq custom-file "~/.config/emacs/custom-file.el")
(load-file custom-file)

;; backup directory. makes things less messy
(setq backup-directory-alist `(("." . "~/.config/emacs/.emacs.bak")))

;; save minibuffer hist + register hist
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'register-alist)

;; disable unnecessary UI elements
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; sane defaults
(setq-default
  load-prefer-newer t
  inhibit-startup-message t
  indent-tabs-mode nil
  create-lockfiles nil
  auto-save-default nil
  enable-recursive-minibuffers t
  electric-indent-inhibit t
  read-file-name-completion-ignore-case t)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq use-dialog-box nil)

;; now it flashes pink :)
(setq ring-bell-function
      (lambda ()
        (let ((orig-fg (face-foreground 'mode-line)))
          (set-face-foreground 'mode-line "#f797dc")
          (run-with-idle-timer 0.1 nil
                               (lambda (fg) (set-face-foreground 'mode-line fg))
                               orig-fg))))

;; set fill column and enable in prog mode
(setq-default fill-column 80)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)

;; mouse wheel stuff
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)

;; auto update on change in buffer
(global-auto-revert-mode t)

;; highlighting!
(setq org-src-fontify-natively t)
(setq org-src-preserve-indentation t)

(column-number-mode)

(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq display-line-numbers-type 'relative)

(set-face-attribute 'default nil
                    :family "Maple Mono NF"
                    :height 110
                    :weight 'normal
                    :width 'normal)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe))

(use-package which-key
  :config (which-key-mode))

(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

(use-package magit)

(use-package smartparens
  :config
  (setq sp-highlight-pair-overlay nil)
  (smartparens-global-mode 1))


(sp-local-pair 'LaTeX-mode '"\\[" "\\]")
(sp-local-pair 'LaTeX-mode "`" nil :actions nil)
(sp-local-pair 'prog-mode "{" nil :post-handlers '(("||\n[i]" "RET")))
(sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)           ;; no '' pair in emacs-lisp-mode


(defun sparrow/newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent. "
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))


(use-package undo-tree
  :diminish
  :config
  (setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))
  (global-undo-tree-mode 1))

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

(use-package vterm-toggle
  :config
  (setq vterm-toggle-cd-auto-create-buffer nil)
  (add-to-list 'vterm-keymap-exceptions "<f2>")
  (global-set-key [f2] 'vterm-toggle)
  (global-set-key [M-f2] 'vterm-toggle-cd)
  (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)
  (define-key vterm-mode-map [M-f2]   #'vterm-toggle-cd)
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
              '((lambda (buffer-or-name _)
                    (let ((buffer (get-buffer buffer-or-name)))
                      (with-current-buffer buffer
                        (or (equal major-mode 'vterm-mode)
                            (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3))))


(use-package p4)

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'org-mode '("www" "**/" "*>" "*/" "\\\\"
                                      "\\\\\\" "{-" "::" ":::" ":=" "!="
                                      "!==" "-}" "----" "-->" "->" "->>" "-<"
                                      "-<<" "-~" "#{" "#[" "##" "###" "####"
                                      "#(" "#?" "#_" "#_(" ".-" ".=" ".." "..<"
                                      "..." "?=" "??" ";;" "/*" "/**" "/=" "/=="
                                      "</" "/>" "//" "///" "&&" "||" "||=" "|=" "|>"
                                      "^=" "$>" "++" "+++" "+>" "=:=" "==" "==="
                                      "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-"
                                      ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
                                      "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-"
                                      "<--" "<->" "<+" "<+>" "<=" "<==" "<=>"
                                      "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~"
                                      "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>"
                                      "%%"))
  (ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\"
                                       "\\\\\\" "{-" "::" ":::" ":=" "!!" "!="
                                       "!==" "-}" "----" "-->" "->" "->>" "-<"
                                       "-<<" "-~" "#{" "#[" "##" "###" "####"
                                       "#(" "#?" "#_" "#_(" ".-" ".=" ".." "..<"
                                       "..." "?=" "??" ";;" "/*" "/**" "/=="
                                       "/>" "//" "///" "&&" "||" "||=" "|=" "|>"
                                       "^=" "$>" "++" "+++" "+>" "=:=" "==" "==="
                                       "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-"
                                       ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
                                       "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-"
                                       "<--" "<->" "<+" "<+>" "<=" "<==" "<=>"
                                       "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~"
                                       "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>"
                                       "%%" "todo))"))
  (global-ligature-mode t))

(use-package catppuccin-theme
  ;; :hook (server-after-make-frame-hook . catppuccin-reload)
  :config
  (load-theme 'catppuccin :no-confirm))

(use-package solaire-mode
  :config (solaire-global-mode +1))

(require 'treesit)
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (c "https://github.com/tree-sitter/tree-sitter-c")
     (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")
     (nix "https://github.com/nix-community/tree-sitter-nix")))
(dolist (lang treesit-language-source-alist)
  (unless (treesit-language-available-p (car lang))
    (treesit-install-language-grammar (car lang))))
(setq treesit-load-name-override-list
   '((c++ "libtree-sitter-cpp")))
(add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-or-c++-mode . c-or-c++-ts-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-ts-mode))
(setq-default treesit-font-lock-level 4)

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :after nerd-icons
  :init (doom-modeline-mode 1))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family "Maple Mono NF"))

;; adapted from https://github.com/emacs-dashboard/emacs-dashboard/issues/459#issuecomment-1845461825
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  ;; :diminish
  ;; (dashboard-mode page-break-lines-mode)
  :custom
  (dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items))
  (dashboard-center-content t)
  (dashboard-startup-banner 2)
  (dashboard-items '((recents  . 10)
                     (projects .  5)
                     (agenda   .  5)))
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-footer nil)
  :hook
  (after-init . dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
(setq dashboard-banner-logo-title
      (nth (random 7) '("Breathe. You got this."
                        "Hey you, you're finally awake."
                        "Hesitation is defeat."
                        "Sometimes, things have to fall apart to make way for better things."
                        "Have faith in yourself. You've come so far already."
                        "The code binds you. How will you interpret it?"
                        "The trees are whispering. Are you listening?"
                        "The cake is a lie."
                        "Be safe, friend. Don't you dare go hollow."
                        "The trees are whispering. Are you listening?"
                        "If only I could be so grossly incandescent!")))

(defun sparrow/insert-em-dash ()
  "Replace three consecutive hyphens with an em dash."
  (interactive)
  (let ((prev-chars (buffer-substring-no-properties (- (point) 2) (point))))
    (if (string= prev-chars "--")
        (progn
          (backward-delete-char 2)
          (insert "—"))
      (insert "-"))))

;; (global-set-key (kbd "M--") 'insert-em-dash)

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
  (evil-mode)
  (evil-set-initial-state 'justl-mode 'emacs))

;; (evil-define-key 'normal justl-mode-map (kbd "?") 'justl-help-popup)
;; (evil-define-key 'normal justl-mode-map (kbd "r") 'justl--refresh-buffer)
;; (evil-define-key 'normal justl-mode-map (kbd "RET") 'justl-exec-recipe)
;; (evil-define-key 'normal justl-mode-map (kbd "<S-return>") 'justl-exec-eshell)
;; (evil-define-key 'normal justl-mode-map (kbd "e") 'justl-go-to-recipe)
;; (evil-define-key 'normal justl-mode-map (kbd "w") 'justl--exec-recipe-with-args)
;; (evil-define-key 'normal justl-mode-map (kbd "W") 'justl-no-exec-eshell)

(evil-define-key 'normal Info-mode-map (kbd "gJ") 'Info-next-preorder)
(evil-define-key 'normal Info-mode-map (kbd "gK") 'Info-last-preorder)

(evil-define-key 'insert 'global (kbd "M--") 'sparrow/insert-em-dash)

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-tex
  :hook
  (LaTeX-mode . evil-tex-mode))

(use-package avy
  :config
  (global-set-key (kbd "M-/") 'avy-goto-char-2))

(use-package vimish-fold
  :after evil
  :config
  ;; (evil-define-key 'normal 'global (kbd "zf") 'vimish-fold)
  ;; (evil-define-key 'normal vimish-fold-folded-keymap (kbd "zd") 'vimish-fold-delete)
  ;; (evil-define-key 'normal vimish-fold-unfolded-keymap (kbd "zd") 'vimish-fold-delete)
  ;; (evil-define-key 'normal vimish-fold-folded-keymap (kbd "zo") 'vimish-fold-unfold)
  ;; (evil-define-key 'normal vimish-fold-unfolded-keymap (kbd "zc") 'vimish-fold-refold)
  ;; (evil-define-key 'normal vimish-fold-folded-keymap (kbd "<TAB>") 'vimish-fold-toggle)
  ;; (evil-define-key 'normal vimish-fold-unfolded-keymap (kbd "<TAB>") 'vimish-fold-toggle)
  (vimish-fold-global-mode 1))

(use-package evil-vimish-fold
  :after vimish-fold
  :init
  (setq evil-vimish-fold-target-modes '(prog-mode conf-mode))
  :config
  (global-evil-vimish-fold-mode))

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
_h_ ←           _v_ertical         _b_uffer        _u_ ←
_j_ ↓           _s_orizontal       _f_ind files    _i_ ↓
_k_ ↑           _1_only this       _P_rojectile    _o_ ↑
_l_ →           _d_elete           _S_wap          _p_ →
_F_ollow        _e_qualize         _[_backward     _8_0 columns
_q_uit          ^        ^         _]_forward
"
  ("h" windmove-left)
  ("j" windmove-down)
  ("k" windmove-up)
  ("l" windmove-right)
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
  ("S" switch-window-then-swap-buffer)
  ("8" set-80-columns)
  ("v" split-window-right)
  ("s" split-window-below)
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

;; (defun sparrow/zathura-goto ()
;;   "Goes to this line in output pdf (synctex)"
;;   (interactive)
;;   (shell-command (format "zathura %s --synctex-forward %d:0:%s"
;;                          (concat (substring (buffer-file-name) 0 -3) "pdf")
;;                          (line-number-at-pos)
;;                          (buffer-file-name))))


(defun sparrow/align-comments (beginning end)
  "Align comments within marked region."
  (interactive "*r")
  (let (indent-tabs-mode align-to-tab-stop)
    (align-regexp beginning end (concat "\\(\\s-*\\)"
                                        (regexp-quote comment-start)))))

(setq org-startup-folded t)
(setq org-src-window-setup 'current-window)

(defconst notes-directory "/home/nikhil/stuff/notes/")
(defconst notes-other-directory "src/")

(defun ordinal (n)
  "Special day of month format."
  (format
   (concat
    "%d"
    (if (memq n '(11 12 13)) "th"
      (let ((last-digit (% n 10)))
        (cl-case last-digit
          (1 "st")
          (2 "nd")
          (3 "rd")
          (otherwise "th"))))) n))

(defadvice format-time-string (before ordinal activate)
  "Add ordinal to %d."
  (let ((day (nth 3 (decode-time (or time (current-time))))))
    (setq format-string
      (replace-regexp-in-string "%o"
                    (ordinal day)
                    format-string))))


(defconst day-string "%A, %B %o, %Y")

;; now and today come from journal.el
(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)                 ; permit invocation in minibuffer
  (format-time-string "%D %-I:%M %p"))

(defun today ()
  "Insert string for today's date nicely formatted in American style,
e.g. Sunday, September 17, 2000."
  (interactive)                 ; permit invocation in minibuffer
  (format-time-string day-string))

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
  (format-time-string "%A, %-d %B %Y" (tomorrow-time))
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
  (format-time-string "%A, %-d %B %Y" (yesterday-time))
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

(use-package calfw
  :config
  (setq cfw:display-calendar-holidays nil)
  (setq cfw:org-agenda-schedule-args '(:timestamp)))
(use-package calfw-org)

;; from https://github.com/kiwanami/emacs-calfw
(defun my-open-calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "Light Blue")  ; orgmode source
    ;; (cfw:howm-create-source "Blue")  ; howm source
    ;; (cfw:cal-create-source "Orange") ; diary source
    ;; (cfw:ical-create-source "Moon" "~/moon.ics" "Gray")  ; ICS source1
    ;; (cfw:ical-create-source "gcal" "https://..../basic.ics" "IndianRed") ; google calendar ICS
   )))

(setq org-agenda-files (list "~/stuff/notes/todo"))

(defun sample-data2 (b e)
  (list
    (make-cfw:event :title "Item1"
          :start-date (cfw:date 9 15 2024)
          :start-time   (cfw:time 10 30)
          :end-time   (cfw:time 13 30))))

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
(sparrow/leader ">" '(project-find-file :which-key "find file in project"))
(sparrow/leader "r" '(consult-register :which-key "find file"))
(sparrow/leader "/" '(consult-line :which-key "search"))
(sparrow/leader "\`" '(vterm :which-key "vterm"))
(sparrow/leader "," '(consult-buffer :which-key "switch buffers"))
(sparrow/leader "<" '(consult-project-buffer :which-key "open buffer in project"))
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

(sparrow/leader "j" '(nil :which-key "justl"))
(sparrow/leader "jj" '(justl :which-key "justl buffer"))
(sparrow/leader "jd" '(justl-exec-default-recipe :which-key "run default recipe"))
(sparrow/leader "je" '(justl-exec-recipe-in-dir :which-key "exec recipe"))
(sparrow/leader "jr" '(justl-recompile :which-key "rerun last recipe"))

(sparrow/leader "f" '(nil :which-key "find common files"))
(sparrow/leader "ft" '((lambda () (interactive)(find-file "~/stuff/notes/todo"))
                                :which-key "todo page"))
(sparrow/leader "fd" '((lambda () (interactive)(find-file (concat notes-directory (todays-note))))
                                :which-key "today\'s daily note"))
(sparrow/leader "fe" '((lambda () (interactive)
                         (find-file "~/nixos-config/home/emacs/config/settings.org"))
                                :which-key "emacs config"))
(sparrow/leader "fn" '((lambda () (interactive)(find-file "~/nixos-config/flake.nix"))
                                :which-key "notes index"))
(sparrow/leader "fi" '((lambda () (interactive)(find-file "~/stuff/notes/index"))
                                :which-key "notes index"))

(sparrow/leader "p" '(nil :which-key "projects"))
(sparrow/leader "pp" '(project-switch-project :which-key "open project"))
(sparrow/leader "p," '(consult-project-buffer :which-key "open buffer in project"))
(sparrow/leader "p." '(project-find-file :which-key "find file in project"))
(sparrow/leader "pg" '(project-find-regexp :which-key "regexp in project"))
(sparrow/leader "pk" '(project-kill-buffers :which-key "kill project buffers"))
;; (sparrow/leader "pp" '(justl :which-key "open file in current project"))


(sparrow/leader "C" '(calc :which-key "calc"))

(sparrow/leader "c" '(nil :which-key "misc"))
(sparrow/leader "cz" '(hydra-text-scale/body :which-key "zoom hydra"))
(sparrow/leader "cw" '(hydra-window/body :which-key "manage windows"))
(sparrow/leader "ca" '(nil :which-key "alignment"))
(sparrow/leader "caa" '(align-regexp :which-key "align regexp"))
(sparrow/leader "ca/" '(sparrow/align-comments :which-key "align comments"))


(sparrow/leader "d" '(dired :which-key "dired"))

(sparrow/leader "a" '(nil :which-key "agenda cmds"))
(sparrow/leader "aa" '(org-agenda :which-key "org-agenda"))
(sparrow/leader "ac" '(peregrine/open-calendar :which-key "calendar"))

(sparrow/leader "t" '(org-todo :which-key "set TODO heading")))

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
         ("M-p :" . cape-emoji)
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
  ;; (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;; (add-to-list 'completion-at-point-functions #'cape-history)
  ;; (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;; (add-to-list 'completion-at-point-functions #'cape-tex)
  ;; (add-to-list 'completion-at-point-functions #'cape-sgml)
  ;; (add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;; (add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;; (add-to-list 'completion-at-point-functions #'cape-dict)
  ;; (add-to-list 'completion-at-point-functions #'cape-line)
)

(use-package yasnippet
  :init (setq yas-snippet-dirs '("~/nixos-config/home/emacs/snippets"))
  :config (yas-global-mode 1))

;; (defun my-yas-try-expanding-auto-snippets ()
;;   (when yas-minor-mode
;;     (let ((yas-buffer-local-condition ''(require-snippet-condition . auto)))
;;       (yas-expand))))
;; (add-hook 'post-command-hook #'my-yas-try-expanding-auto-snippets)

(use-package vterm)

(use-package eglot
  :config (setq-default eglot-inlay-hints-mode nil)
  :hook
    ((c-ts-mode . eglot-ensure)
     (c++-ts-mode . eglot-ensure)
     (python-ts-mode . eglot-ensure)))
(add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))

(cl-defmethod project-root ((project (head marker-file)))
  (cdr project))

(defun project-try-marker (dir)
  "Find DIR's project root by searching for a `.project.el' file.

If this file exists, it marks the project root.  For convenient
compatibility with Projectile, `.projectile' is also considered
a project root marker."
  (let ((root (or (locate-dominating-file dir ".project.el")
                  (locate-dominating-file dir ".projectile"))))
    (when root (cons 'marker-file root))))

(add-hook 'project-find-functions #'project-try-marker)

(use-package meson-mode)

(use-package glsl-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.vert\\'" . glsl-mode))
  (add-to-list 'auto-mode-alist '("\\.frag\\'" . glsl-mode)))

(use-package just-mode)
(use-package justl)

(use-package envrc
  :hook (after-init . envrc-global-mode))

;; (use-package direnv
;;   :config
;;   (direnv-mode))

(use-package haskell-mode
  :config
  (add-to-list 'eglot-server-programs
              '(haskell-mode . ("haskell-language-server-wrapper" "--lsp"))))

(use-package nix-mode)
;; (use-package nix-ts-mode
;;   :mode "\\.nix\\'")

(use-package reformatter)
(use-package zig-mode
  :after reformatter
  :hook (zig-mode . (lambda ()
                      (setq-local evil-shift-width 4))))

(use-package erlang)
(use-package prolog)

(use-package rustic
  :config
  (setq rustic-format-on-save nil)
  :custom
  (rustic-cargo-use-last-stored-arguments t))

(use-package svelte-mode
  :config
  (customize-set-variable 'svelte-basic-offset 2))

(defun sparrow/setup-latex ()
  (setq-local fill-paragraph-function nil))

(use-package auctex
  :hook ((LaTeX-mode . visual-line-mode)
         (LaTeX-mode . flyspell-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . sparrow/setup-latex))
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq-default TeX-command-extra-options "--shell-escape")
  (setq TeX-view-program-selection '(((output-dvi has-no-display-manager)
                                      "dvi2tty")
                                     ((output-dvi style-pstricks)
                                      "dvips and gv")
                                     (output-dvi "xdvi")
                                     (output-pdf "zathura")
                                     (output-html "xdg-open")))
  (add-to-list 'TeX-view-program-list
               '("zathura" "zathura %o")))

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000))))

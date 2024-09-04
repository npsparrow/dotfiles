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

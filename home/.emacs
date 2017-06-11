;; Tabs info from http://www.pement.org/emacs_tabs.htm
(setq-default indent-tabs-mode nil)
(setq default-tab-width 4)

;; https://www.emacswiki.org/emacs/CPerlMode
(add-to-list 'auto-mode-alist '("\\.\\([pP][Llm]\\|al\\)\\'" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("perl5" . cperl-mode))
(add-to-list 'interpreter-mode-alist '("miniperl" . cperl-mode))

(setq cperl-electric-parens nil)

;; https://www.emacswiki.org/emacs/IndentingPerl
(setq cperl-indent-level 4
      cperl-close-paren-offset -4
      cperl-continued-statement-offset 4
      cperl-indent-parens-as-block t
      cperl-tab-always-indent t
      cperl-indent-subs-specially nil
      cperl-merge-trailing-else nil
      )


(custom-set-faces
 '(cperl-array-face ((t (:foreground "red"))))
 '(cperl-hash-face ((t (:foreground "blue"))))
 '(cperl-nonoverridable-face ((t (:foreground "blue" :weight bold))))
 '(font-lock-builtin-face ((t (:foreground "red"))))
 '(font-lock-comment-delimiter-face ((t (:foreground "green" :weight bold))))
 '(font-lock-comment-face ((t (:foreground "green"))))
 '(font-lock-constant-face ((t (:weight bold))))
 '(font-lock-doc-face ((t (:background "yellow")))) ;; Dunno
 '(font-lock-function-name-face ((t (:weight bold))))
 '(font-lock-keyword-face ((t (:foreground "blue" :weight bold))))
 '(font-lock-negation-char-face ((t (:weight bold))))
 '(font-lock-preprocessor-face ((t (:background "yellow")))) ;; Dunno
 '(font-lock-regexp-grouping-backslash ((t (:foreground "red"))))
 '(font-lock-regexp-grouping-construct ((t (:foreground "red"))))
 '(font-lock-string-face ((t (:foreground "cyan"))))
 '(font-lock-type-face ((t (:foreground "blue" :weight bold))))
 '(font-lock-variable-name-face ((t (:foreground "magenta"))))
 '(font-lock-warning-face ((t (:background "red"))))
 )

(custom-set-variables
 '(cperl-invalid-face (quote trailing-whitespace)))

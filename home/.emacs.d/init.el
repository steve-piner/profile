;;;; init.el --- Steve's .emacs config.
;;; Commentary:

;; Install missing packages, then set up preferences.

;; Some of this is based on https://dev.to/nicholasbhubbard/how-i-use-emacs-to-write-perl-40e6

;;; Code:

;; Flycheck complains unless these are defined.
(defvar my-packages)
(defvar default-tab-width)
(defvar cperl-electric-parens)
(defvar cperl-indent-level)
(defvar cperl-close-paren-offset)
(defvar cperl-continued-statement-offset)
(defvar cperl-indent-parens-as-block)
(defvar cperl-tab-always-indent)
(defvar cperl-indent-subs-specially)
(defvar cperl-merge-trailing-else)

;; Automatically install packages
;; https://stackoverflow.com/a/55058934

;; first, declare repositories
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; Init the package facility
(require 'package)
(package-initialize)
;; (package-refresh-contents) ;; this line is commented
;; since refreshing packages is time-consuming and should be done on demand

;; Declare packages
(setq my-packages
      '(flycheck
        markdown-mode
        yaml-mode
        json-mode
        dumb-jump
        flx-ido
        ivy
        counsel
        swiper))

;; Iterate on packages and install missing ones
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; ---

; https://github.com/lewang/flx
;(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)

;; Ivy completions
;; https://github.com/abo-abo/swiper

(ivy-mode)

(setq ivy-re-builders-alist
      '((t . ivy--regex-fuzzy)))

(counsel-mode)
(global-set-key "\C-s" 'swiper)


;; ---

;; Line highlight mode.
(global-hl-line-mode)

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

;; Enable syntax checking.
;; https://www.flycheck.org/
(global-flycheck-mode)

;; Enable dumb-jump (M-.)
;; https://github.com/jacktasia/dumb-jump
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;; ---
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-array-face ((t (:foreground "darkred"))))
 '(cperl-hash-face ((t (:foreground "darkblue"))))
 '(cperl-nonoverridable-face ((t (:foreground "darkblue" :weight bold))))
 '(font-lock-builtin-face ((t (:foreground "darkred"))))
 '(font-lock-comment-delimiter-face ((t (:foreground "darkgreen" :weight bold))))
 '(font-lock-comment-face ((t (:foreground "darkgreen"))))
 '(font-lock-constant-face ((t (:weight bold))))
 '(font-lock-doc-face ((t (:background "yellow"))))
 '(font-lock-function-name-face ((t (:weight bold))))
 '(font-lock-keyword-face ((t (:foreground "darkblue" :weight bold))))
 '(font-lock-negation-char-face ((t (:weight bold))))
 '(font-lock-preprocessor-face ((t (:background "yellow"))))
 '(font-lock-regexp-grouping-backslash ((t (:foreground "darkred"))))
 '(font-lock-regexp-grouping-construct ((t (:foreground "darkred"))))
 '(font-lock-string-face ((t (:foreground "darkcyan"))))
 '(font-lock-type-face ((t (:foreground "darkblue" :weight bold))))
 '(font-lock-variable-name-face ((t (:foreground "darkmagenta"))))
 '(font-lock-warning-face ((t (:background "darkred")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-invalid-face 'trailing-whitespace)
 '(package-selected-packages '(shx dumb-jump flycheck)))

;;; init.el ends here

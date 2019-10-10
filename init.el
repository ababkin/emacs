
;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User Site Local
; (load (expand-file-name "local-preinit.el" user-emacs-directory) 'no-error)
(unless (boundp 'package--initialized)
  ;; don't set gnu/org/melpa if the site-local or local-preinit have
  ;; done so (e.g. firewalled corporate environments)
  (require 'package)
  (setq
   package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                      ;;("org" . "http://orgmode.org/elpa/")
                      ("melpa-stable" . "http://stable.melpa.org/packages/")
                      ("melpa" . "http://melpa.org/packages/"))
   package-archive-priorities '(("melpa-stable" . 1))))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; QUELPA
(if (require 'quelpa nil t)
;;  (quelpa-self-upgrade) - This slows the startup down
  (with-temp-buffer
    (url-insert-file-contents "https://framagit.org/steckerhalter/quelpa/raw/master/bootstrap.el")
    (eval-buffer)))

(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://framagit.org/steckerhalter/quelpa-use-package.git"))
(require 'quelpa-use-package)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section is for global settings for built-in emacs parameters
(setq
 inhibit-startup-screen t
 initial-scratch-message nil
 enable-local-variables t
 create-lockfiles nil
 make-backup-files nil
 load-prefer-newer t
 custom-file (expand-file-name "custom.el" user-emacs-directory)
 column-number-mode t
 scroll-error-top-bottom t
 scroll-margin 15
 gc-cons-threshold 20000000
 large-file-warning-threshold 100000000
 truncate-lines nil
 user-full-name "Alexey Babkin")

;; buffer local variables
(setq-default
 fill-column 80
 indent-tabs-mode nil
 default-tab-width 4)

(put 'compilation-skip-threshold 'safe-local-variable #'integerp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section is for global settings for built-in packages that autoload
(setq
 save-abbrevs 'silent
 help-window-select t
 show-paren-delay 0.5
 dabbrev-case-fold-search nil
 tags-case-fold-search nil
 tags-revert-without-query t
 tags-add-tables nil
 compilation-scroll-output 'first-error
 compilation-ask-about-save nil
 source-directory (getenv "EMACS_SOURCE")
 org-confirm-babel-evaluate nil
 nxml-slash-auto-complete-flag t
 sentence-end-double-space nil
 browse-url-browser-function 'browse-url-generic
 ediff-window-setup-function 'ediff-setup-windows-plain)

(setq-default
 c-basic-offset 2)

(add-hook 'prog-mode-hook
          (lambda () (setq show-trailing-whitespace t)))

;; protects against accidental mouse movements
;; http://stackoverflow.com/a/3024055/1041691
(add-hook 'mouse-leave-buffer-hook
          (lambda () (when (and (>= (recursion-depth) 1)
                           (active-minibuffer-window))
                  (abort-recursive-edit))))

;; *scratch* is immortal
(add-hook 'kill-buffer-query-functions
          (lambda () (not (member (buffer-name) '("*scratch*" "scratch.el")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section is for setup functions that are built-in to emacs
(defalias 'yes-or-no-p 'y-or-n-p)
(menu-bar-mode -1)
(when window-system
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(global-auto-revert-mode 1)

(electric-indent-mode 0)
(remove-hook 'post-self-insert-hook
             'electric-indent-post-self-insert-function)
(remove-hook 'find-file-hooks 'vc-find-file-hook)

(global-auto-composition-mode 0)
(auto-encryption-mode 0)
(tooltip-mode 0)
(save-place-mode 1)

(make-variable-buffer-local 'tags-file-name)
(make-variable-buffer-local 'show-paren-mode)

(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-tail-mode))
(defun add-to-load-path (path)
  "Add PATH to LOAD-PATH if PATH exists."
  (when (file-exists-p path)
    (add-to-list 'load-path path)))
(add-to-load-path (expand-file-name "lisp" user-emacs-directory))

(add-to-list 'auto-mode-alist '("\\.xml\\'" . nxml-mode))
;; WORKAROUND http://debbugs.gnu.org/cgi/bugreport.cgi?bug=16449
(add-hook 'nxml-mode-hook (lambda () (flyspell-mode -1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section is for global modes that should be loaded in order to
;; make them immediately available.

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode)
  :bind ("s-/" . undo-tree-visualize))


(use-package flx-ido
  :demand
  :init
  (setq
   ido-enable-flex-matching t
   ido-use-faces nil ;; ugly
   ido-case-fold nil ;; https://github.com/lewang/flx#uppercase-letters
   ido-ignore-buffers '("\\` " midnight-clean-or-ido-whitelisted)
   ido-show-dot-for-dired nil ;; remember C-d
   ido-enable-dot-prefix t)
  :config
  (ido-mode 1)
  (ido-everywhere t)
  (flx-ido-mode 1))




(add-to-list 'load-path "~/.emacs.d/libs")
(require 'ui)


;; Vim mode
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

(use-package expand-region
  :commands 'er/expand-region
  :bind ("C-=" . er/expand-region))

;; Git
(use-package git-gutter
  :diminish git-gutter-mode
  :commands git-gutter-mode
  :init
  ;; always a column reserved, but no flickering
  (setq git-gutter:unchanged-sign ""))

(use-package rainbow-mode
  :diminish rainbow-mode
  :commands rainbow-mode)

(use-package rainbow-delimiters
  :diminish rainbow-delimiters-mode
  :commands rainbow-delimiters-mode)


;; TODO show compile buffer output as flycheck squiggles
(use-package flycheck
  :diminish flycheck-mode
  :commands flycheck-mode
  :init
  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  :config
  ;; disables the timed popup, use C-h .
  (defun flycheck-display-error-at-point-soon ()))

(use-package flyspell
  :commands flyspell-mode
  :diminish flyspell-mode
  :init (setq
         ispell-dictionary "american"
         flyspell-prog-text-faces '(font-lock-doc-face))
  :config
  (bind-key "C-." nil flyspell-mode-map)
  ;; the correct way to set flyspell-generic-check-word-predicate
  (put #'text-mode #'flyspell-mode-predicate #'text-flyspell-predicate))

(defun text-flyspell-predicate ()
  "Ignore acronyms and anything starting with 'http' or 'https'."
  (save-excursion
    (let ((case-fold-search nil))
      (forward-whitespace -1)
      (when
          (or
           (equal (point) (line-beginning-position))
           (looking-at " "))
        (forward-char))
      (not
       (looking-at "\\([[:upper:]]+\\|https?\\)\\b")))))




;; Helm
(use-package helm
  :ensure t
  :init
  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)
  (setq helm-candidate-number-list 50))

;; Which Key
(use-package which-key
  :ensure t
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode))

;; Custom keybinding
(use-package general
  :ensure t
  :config (general-define-key
  :states '(normal visual insert emacs)
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  ;; "/"   '(counsel-rg :which-key "ripgrep") ; You'll need counsel package for this
  "TAB" '(switch-to-prev-buffer :which-key "previous buffer")
  "SPC" '(helm-M-x :which-key "M-x")
  "pf"  '(helm-find-file :which-key "find files")
  ;; Buffers
  "bb"  '(helm-buffers-list :which-key "buffers list")
  ;; Window
  "wl"  '(windmove-right :which-key "move right")
  "wh"  '(windmove-left :which-key "move left")
  "wk"  '(windmove-up :which-key "move up")
  "wj"  '(windmove-down :which-key "move bottom")
  "w/"  '(split-window-right :which-key "split right")
  "w-"  '(split-window-below :which-key "split bottom")
  "wx"  '(delete-window :which-key "delete window")
  ;; Others
  "at"  '(ansi-term :which-key "open terminal")
))

;; Fancy titlebar for MacOS
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(setq ns-use-proxy-icon  nil)
(setq frame-title-format nil)


;; wrap lines
(setq-default truncate-lines nil)

;; cycle through frames
(global-set-key (kbd "s-$") 'other-frame)

(global-set-key (kbd "C-s-h") 'sp-beginning-of-sexp)
(global-set-key (kbd "C-s-l") 'sp-end-of-sexp)
(global-set-key (kbd "C-s-j") 'sp-down-sexp)
(global-set-key (kbd "C-s-k") 'sp-up-sexp)
(global-set-key (kbd "C-s-J") 'sp-backward-down-sexp)
(global-set-key (kbd "C-s-K") 'sp-backward-up-sexp)

;; Projectile
(use-package projectile
  :ensure t
  :demand
  ;; nice to have it on the modeline
  :init
  (put 'ag-ignore-list 'safe-local-variable #'listp)
  (setq
   projectile-tags-backend 'xref
   projectile-use-git-grep t
   projectile-globally-ignored-directories '(".git")
   projectile-globally-ignored-files '("TAGS" "*.min.js"))
  :config
  (projectile-register-project-type 'hpack '("package.yaml")
                    :compile "si ."
                    :test "st ."
  )
  (add-hook 'projectile-grep-finished-hook
            ;; not going to the first hit?
            (lambda () (pop-to-buffer next-error-last-buffer)))
  (make-variable-buffer-local 'projectile-tags-command)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (setq-default projectile-tags-command "fast-tags -Re --exclude=dist-newstyle --exclude=.stack-work .")
  (projectile-mode 1)
  :bind
  (("s-f" . projectile-find-file)
   ("s-F" . projectile-ag)
   ("M-." . projectile-find-tag)))


;; YASnippet
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :bind ("s-<tab>" . yas-expand)
  :config
  (yas-reload-all nil t))

(use-package yatemplate
  :defer 2 ;; WORKAROUND https://github.com/mineo/yatemplate/issues/3
  :init
  (setq auto-insert-alist nil)
  (setq-default aytemplate-license "http://www.gnu.org/licenses/lgpl-3.0.en.html")
  :config
  (auto-insert-mode 1)
  (yatemplate-fill-alist))

;; Evil commentary
(use-package evil-commentary
  :ensure t
)
(evil-commentary-mode)

(use-package evil-replace-with-register
  :quelpa (evil-replace-with-register :fetcher github :repo "emacsmirror/evil-replace-with-register")
)
;; change default key bindings (if you want) HERE
(setq evil-replace-with-register-key (kbd "t"))
(evil-replace-with-register-install)

;; Smartparens
(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-mode
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)
  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
  (sp-pair "[" "]" :wrap "s-[") ;; C-[ sends ESC
  (sp-pair "{" "}" :wrap "C-{")

  ;; nice whitespace / indentation when creating statements
  (sp-local-pair '(c-mode java-mode) "(" nil :post-handlers '(("||\n[i]" "RET")))
  (sp-local-pair '(c-mode java-mode) "{" nil :post-handlers '(("||\n[i]" "RET")))

  ;; WORKAROUND https://github.com/Fuco1/smartparens/issues/543
  (bind-key "C-<left>" nil smartparens-mode-map)
  (bind-key "C-<right>" nil smartparens-mode-map)

  (bind-key "s-{" 'sp-rewrap-sexp smartparens-mode-map)

  (bind-key "s-<delete>" 'sp-kill-sexp smartparens-mode-map)
  (bind-key "s-<backspace>" 'sp-backward-kill-sexp smartparens-mode-map)
  (bind-key "s-<home>" 'sp-beginning-of-sexp smartparens-mode-map)
  (bind-key "s-<end>" 'sp-end-of-sexp smartparens-mode-map)
  (bind-key "s-<left>" 'sp-beginning-of-previous-sexp smartparens-mode-map)
  (bind-key "s-<right>" 'sp-next-sexp smartparens-mode-map)
  (bind-key "s-<up>" 'sp-backward-up-sexp smartparens-mode-map)
  (bind-key "s-<down>" 'sp-down-sexp smartparens-mode-map)
)

;; TNG
(use-package haskell-tng-mode
  ;; these 3 lines are only needed for local checkouts
  :ensure nil
  :load-path "~/work/haskell-tng.el"
  :mode ("\\.hs\\'" . haskell-tng-mode)
  
  :config
  (require 'haskell-tng-extra)
  (require 'haskell-tng-extra-projectile)
  ;; (require 'haskell-tng-extra-smartparens)
  (require 'haskell-tng-extra-yasnippet)
  (require 'haskell-tng-hsinspect)
  (setq haskell-tng--compile-history
        '("stack test sym-check -j4 --fast --no-run-tests --ghc-options='-Wwarn'"
          "stack test sym-check -j4 --fast --ghc-options='-Wwarn'"))
  (setq-default haskell-tng--compile-alt "stack clean")
  :bind
  (:map
   haskell-tng-mode-map
   (;("C-c C" . haskell-tng-stack2cabal)
    ("C-c C-r f" . haskell-tng-stylish-haskell)))
  (:map
   haskell-tng-compilation-mode-map
   (("C-c c" . haskell-tng-compile)
    ("C-c e" . next-error)))
  (:map
   haskell-tng-mode-map
   ("RET" . haskell-tng-newline)
   ("C-c c" . haskell-tng-compile)
   ("C-c e" . next-error)
   ("C-c C-n i" . haskell-tng-goto-imports)
   ("C-c C-n m" . haskell-tng-current-module)
   ("C-c C" . haskell-tng-stack2cabal)

   ("C-c C-i s" . haskell-tng-fqn-at-point)

   ("C-c C-r s" . haskell-tng-stylish-haskell)
   ("C-c C-r f" . haskell-tng-ormolu)
  )
 )

(add-hook
 'haskell-tng-mode-hook
 (lambda ()
   (whitespace-mode-with-local-variables)
   (show-paren-mode 1)
   (company-mode 1)
   (git-gutter-mode 1)
 )
)

(defun ormulu-hook ()
  (when (eq major-mode 'haskell-tng-mode)
    (haskell-tng-ormolu)))
(add-hook 'after-save-hook 'ormulu-hook)

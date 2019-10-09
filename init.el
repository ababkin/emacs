;; Package configs
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)


(add-to-list 'load-path "~/.emacs.d/libs")
(require 'ui)
; (load-library "ui")

;; Vim mode
(use-package evil
  :ensure t
  :config
  (evil-mode 1))

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


;; Smartparens
(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-mode
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)
  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
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
   ("C-c e" . next-error)))
(add-hook 'haskell-tng-mode-hook
          (lambda ()
            (company-mode 1)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (yasnippet which-key use-package projectile helm general evil doom-themes))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

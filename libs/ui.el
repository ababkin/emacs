;; Minimal UI
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

;; Theme
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-snazzy t))

;; Fancy titlebar for MacOS
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(setq ns-use-proxy-icon  nil)
(setq frame-title-format nil)

;; wrap lines
(setq-default truncate-lines nil)


;; No, we do not need the splash screen
(setq inhibit-default-init t)


;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled



;; Fonts
(setq doom-font (font-spec :family "Fira Mono" :size 16))
(setq doom-big-font (font-spec :family "Fira Mono" :size 22))




(provide 'ui)
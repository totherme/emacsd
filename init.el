;; Save any interactively-made changes to a file that's not
;; version-controlled.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Clean up the GUI
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

;; I like having line numbers everywhere. Makes pairing easier.
(global-display-line-numbers-mode t)

;; Make dired usually do the right thing
(setq
 dired-dwim-target t
 wdired-allow-to-change-permissions t)

;; Make windows easier to switch between, at the expense of
;; shift-highlighting text
(windmove-default-keybindings)
;; ...and make it also work in Org mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; Make window-configurations a thing I can undo/redo
(winner-mode t)

;; Enable narrowing
(put 'narrow-to-region 'disabled nil)

;; Enable snippits in org-mode
(require 'org-tempo nil t)

;; Export to more formats in org mode
(setq org-export-backends (list 'ascii 'html 'icalendar 'latex 'md 'beamer 'odt))

;; Allow compilation buffers to display colours
(require 'ansi-color)
(defun colourize-compilation-buffer ()
  (read-only-mode nil)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (read-only-mode t))
(add-hook 'compilation-filter-hook 'colourize-compilation-buffer)

(define-derived-mode markdown-mode outline-mode "MD"
  "A tiny tiny markdown mode.

Basically just use outline mode, but recognise markdown headings. This
won't get us bold, italics, code, quotes, etc. We'll just have to use
our imaginations. Like we did on usenet."
  (setq-local outline-regexp "^#+"))

;; ...and use it for editing markdown files
(add-to-list 'auto-mode-alist
	     '("\\.md\\'" . markdown-mode))

;; Use perl-mode for editing terraform files
(add-to-list 'auto-mode-alist
	     '("\\.tf\\'" . perl-mode))

;; Also for nix files
(add-to-list 'auto-mode-alist
	     '("\\.nix\\'" . perl-mode))

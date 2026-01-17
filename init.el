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
 dired-listing-switches "-alh"
 wdired-allow-to-change-permissions t)

;; Keep files up-to-date with what's happening on disk
(global-auto-revert-mode)
(setq auto-revert-check-vc-info t)

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

(define-derived-mode hashcomment-mode prog-mode "HM"
  "A tiny tiny programming mode with hash comments.

Basically just programming mode, with every line that starts '#' as a
comment."
  (setq-local comment-start "#"
	      comment-start-skip "#+ *"
	      font-lock-defaults '('(("#.*\n" . font-lock-comment-face)
				     ("\"[^\"]*\"" . font-lock-string-face))
				   t)))

;; ...and use it for editing terraform files
(add-to-list 'auto-mode-alist
	     '("\\.tf\\'" . hashcomment-mode))

;; ...and for nix files
(add-to-list 'auto-mode-alist
	     '("\\.nix\\'" . hashcomment-mode))

(defvar gds-builtin-light-color-themes
  [ adwaita
    dichromacy
    leuven
    modus-operandi
    modus-operandi-deuteranopia
    modus-operandi-tinted
    modus-operandi-tritanopia
    modus-vivendi
    tango
    tsdh-light
    whiteboard ]
  "A manually-curated array of light-mode color themes. You can cycle
through them with `gds-try-next-light-theme'.

See also `gds-next-light-theme-index' and `gds-try-next-dark-theme'.")

(defvar gds-next-light-theme-index 0
  "The index of the next light-mode color theme to try if you call
`gds-try-next-light-theme'.

See also `gds-builtin-light-color-themes' and `gds-try-next-dark-theme'.")

(defvar gds-builtin-dark-color-themes
  [ deeper-blue
    leuven-dark
    manoj-dark
    misterioso
    modus-vivendi-deuteranopia
    modus-vivendi-tinted
    modus-vivendi-tritanopia
    tango-dark
    tsdh-dark
    wheatgrass
    wombat]
  "A manually-curated array of dark-mode color themes. You can cycle
through them with `gds-try-next-dark-theme'.

See also `gds-next-dark-theme-index' and `gds-try-next-light-theme'.")

(defvar gds-next-dark-theme-index 0
    "The index of the next light-mode color theme to try if you call
`gds-try-next-dark-theme'.

See also `gds-builtin-dark-color-themes' and `gds-try-next-light-theme'.")

(defun gds-try-next-light-theme ()
  "Try the next available light theme.

If we're currently using one or more themes, disable them first.

See also `gds-try-next-dark-theme' and `gds-check-for-new-themes'."
  (interactive)
  (seq-do 'disable-theme custom-enabled-themes)
  (load-theme (aref gds-builtin-light-color-themes gds-next-light-theme-index))
  (setq gds-next-light-theme-index
	(gds-get-rotated-index-of gds-next-light-theme-index
				  gds-builtin-light-color-themes)))

(defun gds-try-next-dark-theme ()
  "Try the next available dark theme.

If we're currently using one or more themes, disable them first.

See also `gds-try-next-light-theme' and `gds-check-for-new-themes'."
  (interactive)
  (seq-do 'disable-theme custom-enabled-themes)
  (load-theme (aref gds-builtin-dark-color-themes gds-next-dark-theme-index))
  (setq gds-next-dark-theme-index
	(gds-get-rotated-index-of gds-next-dark-theme-index
				  gds-builtin-dark-color-themes)))

(defun gds-get-rotated-index-of (idx arr)
  "Rotate the index IDX into array ARR.

ARR must be an array. IDX must be an int that indexes into that
array. We return the index of the next element of the array."
  (% (+ 1 idx) (length arr)))

(defun gds-check-for-new-themes ()
  "Check for uncategorised themes.

Print and return a list of themes that are available to use with
`load-theme', but which are not yet categorised in either of
`gds-builtin-light-color-themes' or `gds-builtin-dark-color-themes'."
  (interactive)
  (let ((new-themes (seq-filter 'gds-is-uncategorised-theme-p
			    (custom-available-themes))))
    (if new-themes
	(message "Detected new themes: %S" new-themes)
      (message "There are no new themes."))
    new-themes))

(defun gds-is-uncategorised-theme-p (theme)
  "Check if we've yet to categorise THEME.

Return t if we don't recognise THEME.

Return nil if THEME is in our list of light or dark themes. Those are our
main categories that we can rotate through with
`gds-try-next-light-theme' and `gds-try-next-dark-theme'

Return nil if THEME is `light-blue'. Because that one's apparently
obsolete since Emacs 29.1, according to the warnings it prints."
  (not (or (eq theme 'light-blue)
	   (seq-contains-p gds-builtin-light-color-themes theme)
	   (seq-contains-p gds-builtin-dark-color-themes theme))))

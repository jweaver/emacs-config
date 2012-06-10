
(defun construct-path (&rest path-elements)
  (defun inner (elements)
    (print (car elements))
    (if (eq (cdr elements) nil)
        (expand-file-name (car elements))
      (expand-file-name (car elements) (inner (cdr elements)))))
  (inner (reverse path-elements)))

(defun search (regexp)
  "Search all buffers for a regexp."
  (interactive "sRegexp to search for: ")
  (multi-occur-in-matching-buffers ".*" regexp))

(require 'org)
      
(defun org-presentation-start ()
  "Start a presentation from the first headline of the file"
  (interactive)
  (beginning-of-buffer)
  (outline-next-visible-heading 1)
  (org-narrow-to-subtree)
  (org-show-subtree))

(defun org-presentation-adjacent (arg)
  "An arg of 1 moves to the next heading, an arg of negative 1
moves to the previous heading."
  (interactive)
  (beginning-of-buffer)
  (widen)
  (outline-next-visible-heading arg)
  (org-narrow-to-subtree)
  (org-show-subtree))

(define-key org-mode-map (kbd "C-c s") '(lambda () (interactive) (org-presentation-start)))
(define-key org-mode-map (kbd "C-c n") '(lambda () (interactive) (org-presentation-adjacent 1)))
(define-key org-mode-map (kbd "C-c p") '(lambda () (interactive) (org-presentation-adjacent -1)))

(defvar blink-cursor-colors (list  "#92c48f" "#6785c5" "#be369c" "#d9ca65")
  "On each blink the cursor will cycle to the next color in this list.")

(setq blink-cursor-count 0)
(defun blink-cursor-timer-function ()
  "Cyberpunk variant of timer `blink-cursor-timer'. OVERWRITES original version in `frame.el'.

This one changes the cursor color on each blink. Define colors in `blink-cursor-colors'."
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not (internal-show-cursor-p)))
  )

(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name))))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "org-mode" "lisp"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "org-mode" "contrib" "lisp"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "todotxt.el"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "sunrise-commander"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "magit"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "ace-jump-mode"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "Mew"))
(add-to-list 'load-path (construct-path (file-name-directory (or (buffer-file-name) load-file-name)) "emacs-jabber"))

(setq backup-directory-alist `(("." . ,(construct-path "~" "emacsbackup"))))

(transient-mark-mode 0)

(setq-default x-select-enable-clipboard t)

(if (eq system-type 'darwin)
    (setq ns-command-modifier (quote meta)))

(global-font-lock-mode t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(ido-mode t)

(display-time-mode t)
(column-number-mode t)
(display-battery-mode t)

(setq scroll-conservatively 10)
(setq scroll-margin 7)
(setq inhibit-startup-screen 1)

(show-paren-mode t)

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

(global-visual-line-mode 1)

(server-start)

(require 'sunrise-commander)

(require 'magit)

(require 'todotxt)

(require 'mew)

;; Both these functions are completely optional  
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))

(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))

(setq mew-name "Jack Weaver")
(setq mew-user "weaver.jack@gmail.com")
(setq mew-mail-domain "gmail.com")
(setq mew-smtp-server "smtp.gmail.com")
(setq mew-smtp-ssl 't)
(setq mew-smtp-ssl-port 465)
(setq mew-smtp-user "weaver.jack@gmail.com")
(setq mew-smtp-auth-list '("LOGIN" "CRAM-MD5" "PLAIN")) ;; GMail uses LOGIN
(setq mew-proto "%")
(setq mew-imap-user "weaver.jack@gmail.com")
(setq mew-imap-server "imap.gmail.com")
(setq mew-imap-ssl 't)
(setq mew-imap-ssl-port 993)
(setq mew-imap-delete nil)
(setq mew-use-master-passwd 't) ;; Requires gnupg
(setq mew-ssl-verify-level 0) ;; Required because I don't want to mess with CAs
(setq mew-use-biff 't)
(setq mew-search-method 'est) ;; Hyper Estraier

;; Required because I don't install mew globally
(setq mew-dir "/home/jw/development/weaverworx/github/emacs-config/Mew")
(setq mew-prog-mewl (concat mew-dir "/bin/mewl"))
(setq mew-prog-mime-encode (concat mew-dir "/bin/mewencode"))
(setq mew-prog-mime-decode (concat mew-dir "/bin/mewdecode"))
(setq mew-prog-est-update (concat mew-dir "/bin/mewest"))

(recentf-mode t)
(setq recentf-auto-cleanup 'never)

(org-remember-insinuate)
(setq org-directory (construct-path (file-name-as-directory "~") "Dropbox" "memex"))
(setq org-default-notes-file (construct-path  org-directory "incoming.org"))

(setq org-capture-templates
      '(("i" "Incoming" entry (file+headline org-default-notes-file "Uncategorized")
         "** %t: %?\n  %i\n")
        ("u" "Upcoming" entry (file+headline (construct-path org-directory "index.org") "Upcoming")
         "** %t: %?\n  %i\n")))

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

(windmove-default-keybindings)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (scheme . t)
   ))

(global-set-key "\C-x\C-m" 'execute-extended-command)

(global-set-key "\C-xi" 'ibuffer)
(global-set-key "\C-xg" 'magit-status)
(global-set-key "\C-xm" 'mew)
(global-set-key "\C-xf" 'recentf-open-files)
(global-set-key "\C-xc" 'calendar)
(global-set-key "\C-xs" 'sunrise)
(global-set-key (kbd "C-x t") 'todotxt)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)

(global-set-key "\C-xj" 'org-presentation-start)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq require-final-newline t)

(setq next-line-add-newlines nil)

(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)
(put 'set-goal-column 'disabled nil)

(require 'color-theme)
(color-theme-initialize)
(color-theme-charcoal-black)

(setq browse-url-browser-function (quote browse-url-generic))
(setq browse-url-generic-program "/usr/bin/chromium-browser")

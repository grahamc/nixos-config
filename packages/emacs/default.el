(global-set-key (kbd "<end>") 'end-of-line)
(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<ESC> <ESC>") 'dabbrev-expand)
(column-number-mode)


(setq user-mail-address "graham@grahamc.com"
      user-full-name "Graham Christensen"
      message-directory "\"[Gmail]/.Drafts\""
      notmuch-fcc-dirs "\"[Gmail]/.Sent Mail\""
      notmuch-crypto-process-mime t
      message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "@msmtp@/bin/msmtp")

(setq-default sentence-end-double-space nil
              indent-tabs-mode nil)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment 'utf-8)

(require 'ido)
(ido-mode t)
(ido-mode 1)
(setq-default ido-enable-flex-mode t
              ido-everywhere t)

(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq backup-directory-alist (list (cons ".*" backup-dir))
      auto-save-list-file-prefix autosave-dir
      auto-save-file-name-transforms `((".*" ,autosave-dir t)))


(defun loader-after-plugins ()
       (define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode 1)))
       (global-fci-mode 1)
       (editorconfig-mode 1)
       (auto-fill-mode 1)
       (require 'notmuch)
       (global-set-key (kbd "C-c m") `notmuch)
       (eval-after-load 'rng-loc
         '(add-to-list 'rng-schema-locating-files "@schemas@"))
)
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'after-init-hook #'loader-after-plugins)

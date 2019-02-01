(global-set-key (kbd "<end>") 'end-of-line)
(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<ESC> <ESC>") 'dabbrev-expand)
(column-number-mode)

(setq user-mail-address "graham@grahamc.com"
      graphviz-dot-dot-program "@graphviz@/bin/dot"
      graphviz-dot-view-command "@graphviz@/bin/dotty"
      graphviz-dot-preview-extension "svg"
      graphviz-dot-auto-preview-on-save t
      user-full-name "Graham Christensen"
      message-directory "\"[Gmail]/Drafts\""
      notmuch-fcc-dirs "\"[Gmail]/Sent Mail\""
      notmuch-crypto-process-mime t
      message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "@msmtp@/bin/msmtp"
      nix-indent-function 'nix-indent-line
      )

(setq-default sentence-end-double-space nil
              indent-tabs-mode nil
              ispell-program-name "@spelling@/bin/hunspell"
              )

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment 'utf-8)

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
       (require 'direnv)
       (direnv-mode)

       (require 'notmuch)
       (global-set-key (kbd "C-c m") `notmuch)

       (require 'yasnippet)
       (yas-global-mode 1)

       (ivy-mode 1)
       (counsel-mode 1)

       (eval-after-load 'rng-loc
         '(add-to-list 'rng-schema-locating-files "@schemas@"))


       (global-set-key (kbd "C-s") 'swiper)
       (global-set-key (kbd "M-x") 'counsel-M-x)
       (global-set-key (kbd "C-x C-f") 'counsel-find-file) ;; 'counsel-projectile-find-file)
       (global-set-key (kbd "<f1> f") 'counsel-describe-function)
       (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
       (global-set-key (kbd "<f1> l") 'counsel-find-library)
       (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
       (global-set-key (kbd "<f2> u") 'counsel-unicode-char)

       (setq ivy-use-virtual-buffers t
             ivy-use-selectable-prompt t)
       (add-hook 'text-mode-hook 'artbollocks-mode)

       (require 'lsp-ui)
       )

(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'after-init-hook #'loader-after-plugins)

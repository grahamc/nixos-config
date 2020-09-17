(setq max-lisp-eval-depth 4000)
(setq max-specpdl-size 5000)

;; Added because pgtk branch gets this wrong
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/DEL-Does-Not-Delete.html
(normal-erase-is-backspace-mode 1)
(add-hook 'tty-setup-hook 'graham-in-tty)
(defun graham-in-tty ()
  (normal-erase-is-backspace-mode 0)
  )



(global-set-key (kbd "<end>") 'end-of-line)
(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<ESC> <ESC>") 'dabbrev-expand)
(column-number-mode)


(setq-default sentence-end-double-space nil)

(set-face-background 'region "LightBlue")

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


;; after this is less minimal


(setq user-mail-address "graham@grahamc.com"
      graphviz-dot-dot-program "@graphviz@/bin/dot"
      graphviz-dot-view-command "@graphviz@/bin/dotty"
      graphviz-dot-preview-extension "svg"
      graphviz-dot-auto-preview-on-save t
      user-full-name "Graham Christensen"
      nix-indent-function 'nix-indent-line
      )

(setq-default indent-tabs-mode nil
              ispell-program-name "@spelling@/bin/hunspell"
              )

(defun grahams-loader-after-plugins ()
       (define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode 1)))
       (global-fci-mode 1)
       (editorconfig-mode 1)
       (auto-fill-mode 1)
       (require 'direnv)
       (direnv-mode)
       (global-flycheck-mode)

       (require 'yasnippet)
       (yas-global-mode 1)

       ;; this stuff was good, but broke after switching to pgtk in 2020-02-18
       ;; and I didn't care enough to fix it. Something about the hooks
       ;; caused infinite lisp evaluation errors. blah blah blah.
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
       (require 'lsp-mode)
       (add-hook 'lsp-mode-hook #'lsp-ui-mode)
       ;; (add-hook 'rust-mode-hook #'lsp)
       )

(add-hook 'after-init-hook #'grahams-loader-after-plugins)

;;; $DOOMDIR/+dashboard.el -*- lexical-binding: t; -*-
;;
;; A custom Doom dashboard: gradient banner, greeting, quote of the moment,
;; single-key quick actions and a numbered list of recent projects.
;; Loaded from config.el via (load! "+dashboard").

;;; Banner

(defconst my/dashboard-banner
  '("██████╗  ██████╗  ██████╗ ███╗   ███╗"
    "██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║"
    "██║  ██║██║   ██║██║   ██║██╔████╔██║"
    "██║  ██║██║   ██║██║   ██║██║╚██╔╝██║"
    "██████╔╝╚██████╔╝╚██████╔╝██║ ╚═╝ ██║"
    "╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝"
    ""
    "      ·  E  ·  M  ·  A  ·  C  ·  S  ·"))

(defun my/dashboard-color (name fallback-face)
  "Theme colour NAME from doom-themes, or FALLBACK-FACE's foreground."
  (or (and (fboundp 'doom-color) (doom-color name))
      (face-foreground fallback-face nil t)))

(defun my/dashboard-banner-fn ()
  "Draw the banner with a top-to-bottom gradient taken from the current theme."
  (let ((colors (list (my/dashboard-color 'magenta 'font-lock-keyword-face)
                      (my/dashboard-color 'violet  'font-lock-keyword-face)
                      (my/dashboard-color 'blue    'font-lock-function-name-face)
                      (my/dashboard-color 'dark-cyan 'font-lock-type-face)
                      (my/dashboard-color 'cyan    'font-lock-type-face)
                      (my/dashboard-color 'teal    'font-lock-string-face)
                      nil
                      (my/dashboard-color 'base5   'font-lock-comment-face)))
        (i -1))
    (string-join
     (mapcar (lambda (line)
               (let ((color (nth (cl-incf i) colors)))
                 (if color
                     (propertize line 'face `(:foreground ,color :weight bold))
                   line)))
             my/dashboard-banner)
     "\n")))

;; Use the text banner in the GUI too, rather than Doom's PNG.
(setq fancy-splash-image nil
      +dashboard-ascii-banner-fn #'my/dashboard-banner-fn
      +dashboard-banner-vertical-padding '(0 . 1))

;;; Greeting + quote

(defconst my/dashboard-quotes
  '("Emacs is a great operating system, lacking only a decent editor."
    "Simplicity is prerequisite for reliability. — Dijkstra"
    "Make it work, make it right, make it fast. — Kent Beck"
    "Programs must be written for people to read. — Abelson & Sussman"
    "The best code is no code at all."
    "Premature optimization is the root of all evil. — Knuth"
    "Talk is cheap. Show me the code. — Torvalds"
    "First, solve the problem. Then, write the code."
    "Weeks of coding can save you hours of planning."
    "There are only two hard things: cache invalidation and naming things."
    "Any sufficiently advanced bug is indistinguishable from a feature."
    "Fearless concurrency. Mostly fearless refactoring."))

(defvar my/dashboard-quote nil
  "Quote shown this session, so redraws don't reshuffle it.")

(defun my/dashboard-widget-greeting ()
  (let* ((hour (string-to-number (format-time-string "%H")))
         (part (cond ((< hour 5)  "Burning the midnight oil")
                     ((< hour 12) "Good morning")
                     ((< hour 18) "Good afternoon")
                     (t           "Good evening")))
         (name (car (split-string (or (user-full-name) user-login-name)))))
    (setq my/dashboard-quote
          (or my/dashboard-quote (seq-random-elt my/dashboard-quotes)))
    (+dashboard-insert
     (concat (propertize (format "%s, %s" part name)
                         'face `(:foreground ,(my/dashboard-color 'yellow 'font-lock-constant-face)
                                 :weight bold))
             (propertize (format-time-string "  ·  %A %-d %B")
                         'face 'font-lock-comment-face)))
    (+dashboard-insert
     (propertize (concat "“" my/dashboard-quote "”")
                 'face '(:inherit font-lock-comment-face :slant italic)))))

;;; Quick actions

(defun my/dashboard-icon (fn name)
  `(,fn ,name :face '+dashboard-menu-title))

(setq +dashboard-menu-sections
      `(("Recent files"       :icon ,(my/dashboard-icon 'nerd-icons-faicon "nf-fa-file_text")
         :action recentf-open-files)
        ("Find in project"    :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-search")
         :action projectile-find-file)
        ("Switch project"     :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-briefcase")
         :action projectile-switch-project)
        ("Reload last session" :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-history")
         :when (cond ((modulep! :ui workspaces)
                      (file-exists-p (expand-file-name persp-auto-save-fname persp-save-dir)))
                     ((require 'desktop nil t)
                      (file-exists-p (desktop-full-file-name))))
         :action doom/quickload-session)
        ("Org agenda"         :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-calendar")
         :action org-agenda)
        ("Capture"            :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-pencil")
         :action org-capture)
        ("Magit"              :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-git_branch")
         :action magit-status)
        ("Claude Code"        :icon ,(my/dashboard-icon 'nerd-icons-mdicon "nf-md-robot_outline")
         :action claude-code-ide-menu)
        ("Edit config"        :icon ,(my/dashboard-icon 'nerd-icons-octicon "nf-oct-tools")
         :action doom/open-private-config)))

;;; Recent projects

(defvar my/dashboard-project-count 5)

(defun my/dashboard-projects ()
  (when (require 'projectile nil t)
    (unless projectile-known-projects
      (projectile-load-known-projects))
    (seq-take (seq-filter #'file-directory-p projectile-known-projects)
              my/dashboard-project-count)))

(defun my/dashboard-open-project (n)
  "Switch to the Nth (1-based) project listed on the dashboard."
  (when-let* ((dir (nth (1- n) (my/dashboard-projects))))
    (projectile-switch-project-by-name dir)))

(defun my/dashboard-widget-projects ()
  (when-let* ((projects (my/dashboard-projects)))
    (insert "\n")
    (+dashboard-insert
     (propertize (format " %s\t%-38s%10s "
                         (nerd-icons-octicon "nf-oct-repo" :face 'font-lock-comment-face)
                         "Recent projects" "")
                 'face '(:inherit font-lock-comment-face :weight bold)))
    (let ((n 0))
      (dolist (dir projects)
        (let* ((n (cl-incf n))
               (name (file-name-nondirectory (directory-file-name dir)))
               (path (abbreviate-file-name (directory-file-name dir)))
               (label (with-temp-buffer
                        (insert-text-button
                         name
                         'action (lambda (_) (projectile-switch-project-by-name dir))
                         'face '+dashboard-menu-title
                         'follow-link t
                         'help-echo dir)
                        (insert (propertize (concat "  " (truncate-string-to-width
                                                          path (max 0 (- 36 (length name))) nil nil "…"))
                                            'face 'font-lock-comment-face))
                        (buffer-string))))
          (+dashboard-insert
           (format " %s\t%-38s%10s "
                   (nerd-icons-octicon "nf-oct-file_directory" :face '+dashboard-menu-title)
                   label
                   (propertize (format "%d" n) 'face '+dashboard-menu-desc))))))))

;;; Footer

(defun my/dashboard-widget-footer ()
  (insert "\n")
  (+dashboard-insert
   (propertize (format "%s Emacs %s  ·  Doom %s"
                       (nerd-icons-sucicon "nf-custom-emacs" :face '+dashboard-footer-icon)
                       emacs-version (doom-version))
               'face 'font-lock-comment-face)))

(setq +dashboard-functions
      '(+dashboard-widget-banner
        my/dashboard-widget-greeting
        +dashboard-widget-shortmenu
        my/dashboard-widget-projects
        my/dashboard-widget-footer
        +dashboard-widget-loaded))

;;; Keys (the menu shows these automatically)

(map! :map +dashboard-mode-map
      :n "f" #'recentf-open-files
      :n "/" #'projectile-find-file
      :n "p" #'projectile-switch-project
      :n "s" #'doom/quickload-session
      :n "a" #'org-agenda
      :n "c" #'org-capture
      :n "m" #'magit-status
      :n "C" #'claude-code-ide-menu
      :n "e" #'doom/open-private-config
      :n "1" (cmd! (my/dashboard-open-project 1))
      :n "2" (cmd! (my/dashboard-open-project 2))
      :n "3" (cmd! (my/dashboard-open-project 3))
      :n "4" (cmd! (my/dashboard-open-project 4))
      :n "5" (cmd! (my/dashboard-open-project 5)))

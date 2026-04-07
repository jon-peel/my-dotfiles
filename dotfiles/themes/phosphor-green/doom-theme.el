;;; ~/.config/crt-themes/light/doom-theme.el — Phosphor Overexposed
;;; Loaded by ~/.doom-theme.el stub. Do not edit directly.

;; ── Font ──────────────────────────────────────────────────────────────────────
(setq doom-font     (font-spec :family "BlexMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "BlexMono Nerd Font" :size 18))

;; ── Structural base ───────────────────────────────────────────────────────────
(setq doom-theme 'doom-one-light)

;; ── Phosphor Green palette face overrides ────────────────────────────────────
(custom-set-faces!
  ;; Core
  `(default                          :background "#D8EDD8" :foreground "#1A3520")
  `(hl-line                          :background "#C8DCC8" :extend t)
  `(region                           :background "#007700" :foreground "#D8EDD8" :extend t)
  `(cursor                           :background "#009900")
  `(fringe                           :background "#D8EDD8" :foreground "#557755")
  `(vertical-border                  :foreground "#557755")
  `(window-divider                   :foreground "#557755")
  `(minibuffer-prompt                :foreground "#007700" :weight bold)
  `(link                             :foreground "#005500" :underline t)
  `(highlight                        :background "#C8DCC8")
  `(shadow                           :foreground "#557755")

  ;; Line numbers
  `(line-number                      :foreground "#AADDAA" :background "#D8EDD8")
  `(line-number-current-line         :foreground "#007700" :background "#C8DCC8" :weight bold)

  ;; Mode line
  `(mode-line                        :background "#B8D0B8" :foreground "#1A3520"
                                      :box (:line-width 1 :color "#557755"))
  `(mode-line-inactive               :background "#D8EDD8" :foreground "#557755"
                                      :box (:line-width 1 :color "#AADDAA"))
  `(mode-line-buffer-id              :foreground "#005500" :weight bold)

  ;; Doom modeline
  `(doom-modeline-bar                :background "#007700")
  `(doom-modeline-bar-inactive       :background "#AADDAA")
  `(doom-modeline-buffer-file        :foreground "#005500" :weight bold)
  `(doom-modeline-buffer-modified    :foreground "#AA2200")
  `(doom-modeline-info               :foreground "#009900")
  `(doom-modeline-warning            :foreground "#886600")
  `(doom-modeline-urgent             :foreground "#AA2200")

  ;; Syntax — font-lock
  `(font-lock-keyword-face           :foreground "#005500" :weight bold)
  `(font-lock-function-name-face     :foreground "#007700")
  `(font-lock-variable-name-face     :foreground "#1A3520")
  `(font-lock-string-face            :foreground "#009900")
  `(font-lock-comment-face           :foreground "#557755" :slant italic)
  `(font-lock-comment-delimiter-face :foreground "#AADDAA" :slant italic)
  `(font-lock-doc-face               :foreground "#3D6040" :slant italic)
  `(font-lock-type-face              :foreground "#336633")
  `(font-lock-constant-face          :foreground "#005500")
  `(font-lock-builtin-face           :foreground "#007700")
  `(font-lock-preprocessor-face      :foreground "#336633")
  `(font-lock-warning-face           :foreground "#AA2200" :weight bold)
  `(font-lock-negation-char-face     :foreground "#AA2200" :weight bold)

  ;; Search
  `(isearch                          :background "#007700" :foreground "#D8EDD8" :weight bold)
  `(isearch-fail                     :background "#AA2200" :foreground "#D8EDD8")
  `(lazy-highlight                   :background "#C8DCC8" :foreground "#1A3520")
  `(match                            :background "#AADDAA" :foreground "#005500")

  ;; Completion — vertico / corfu
  `(vertico-current                  :background "#B8D0B8" :foreground "#005500")
  `(corfu-current                    :background "#B8D0B8" :foreground "#005500")
  `(corfu-default                    :background "#D8EDD8" :foreground "#1A3520")
  `(corfu-border                     :background "#557755")

  ;; Company
  `(company-tooltip                  :background "#C8DCC8" :foreground "#1A3520")
  `(company-tooltip-selection        :background "#007700" :foreground "#D8EDD8")
  `(company-tooltip-common           :foreground "#005500")
  `(company-tooltip-annotation       :foreground "#557755")
  `(company-scrollbar-bg             :background "#D8EDD8")
  `(company-scrollbar-fg             :background "#AADDAA")

  ;; Org mode
  `(org-level-1                      :foreground "#005500" :weight bold)
  `(org-level-2                      :foreground "#007700")
  `(org-level-3                      :foreground "#009900")
  `(org-level-4                      :foreground "#336633")
  `(org-level-5                      :foreground "#3D6040")
  `(org-block                        :background "#C8DCC8" :extend t)
  `(org-block-begin-line             :foreground "#557755" :background "#B8D0B8" :extend t)
  `(org-block-end-line               :foreground "#557755" :background "#B8D0B8" :extend t)
  `(org-link                         :foreground "#005500" :underline t)
  `(org-date                         :foreground "#336633")
  `(org-tag                          :foreground "#557755")
  `(org-todo                         :foreground "#AA2200" :weight bold)
  `(org-done                         :foreground "#007700" :weight bold)
  `(org-headline-done                :foreground "#557755")
  `(org-table                        :foreground "#336633")
  `(org-formula                      :foreground "#005500")

  ;; Dired
  `(dired-directory                  :foreground "#007700" :weight bold)
  `(dired-flagged                    :foreground "#AA2200")
  `(dired-marked                     :foreground "#009900")
  `(dired-symlink                    :foreground "#005500")

  ;; Magit / diff
  `(magit-section-heading            :foreground "#007700" :weight bold)
  `(magit-section-highlight          :background "#C8DCC8")
  `(magit-branch-local               :foreground "#009900")
  `(magit-branch-remote              :foreground "#007700")
  `(magit-hash                       :foreground "#557755")
  `(diff-added                       :background "#C8ECC8" :foreground "#005500" :extend t)
  `(diff-removed                     :background "#ECC8C8" :foreground "#AA2200" :extend t)
  `(diff-header                      :background "#C8DCC8")
  `(diff-hunk-header                 :foreground "#007700" :background "#C8DCC8")
)

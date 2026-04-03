;;; ~/.doom-theme.el — Burning Amber CRT
;;; Written by my-theme-burning-amber.nix. Delete this file (or disable the
;;; module) to revert Doom to its default theme.

;; ── Font ──────────────────────────────────────────────────────────────────────
(setq doom-font     (font-spec :family "BlexMono Nerd Font" :size 13)
      doom-big-font (font-spec :family "BlexMono Nerd Font" :size 18))

;; ── Structural base ───────────────────────────────────────────────────────────
(setq doom-theme 'doom-one)

;; ── Amber palette face overrides ──────────────────────────────────────────────
(custom-set-faces!
  ;; Core
  `(default                          :background "#0D0800" :foreground "#FFB000")
  `(hl-line                          :background "#1A0F00" :extend t)
  `(region                           :background "#FF8800" :foreground "#0D0800" :extend t)
  `(cursor                           :background "#FF6600")
  `(fringe                           :background "#0D0800" :foreground "#3D2400")
  `(vertical-border                  :foreground "#3D2400")
  `(window-divider                   :foreground "#3D2400")
  `(minibuffer-prompt                :foreground "#FF8800" :weight bold)
  `(link                             :foreground "#FF7700" :underline t)
  `(highlight                        :background "#1A0F00")
  `(shadow                           :foreground "#5A3A00")

  ;; Line numbers
  `(line-number                      :foreground "#3D2400" :background "#0D0800")
  `(line-number-current-line         :foreground "#FF8800" :background "#1A0F00" :weight bold)

  ;; Mode line
  `(mode-line                        :background "#1A1000" :foreground "#FFB000"
                                      :box (:line-width 1 :color "#3D2400"))
  `(mode-line-inactive               :background "#0D0800" :foreground "#7A5500"
                                      :box (:line-width 1 :color "#1A0F00"))
  `(mode-line-buffer-id              :foreground "#FFC940" :weight bold)

  ;; Doom modeline
  `(doom-modeline-bar                :background "#FF8800")
  `(doom-modeline-bar-inactive       :background "#3D2400")
  `(doom-modeline-buffer-file        :foreground "#FFC940" :weight bold)
  `(doom-modeline-buffer-modified    :foreground "#FF4400")
  `(doom-modeline-info               :foreground "#CCAA00")
  `(doom-modeline-warning            :foreground "#FF6600")
  `(doom-modeline-urgent             :foreground "#CC2200")

  ;; Syntax — font-lock
  `(font-lock-keyword-face           :foreground "#FF5500" :weight bold)
  `(font-lock-function-name-face     :foreground "#FF8800")
  `(font-lock-variable-name-face     :foreground "#FFB000")
  `(font-lock-string-face            :foreground "#CCAA00")
  `(font-lock-comment-face           :foreground "#5A3A00" :slant italic)
  `(font-lock-comment-delimiter-face :foreground "#4A2E00" :slant italic)
  `(font-lock-doc-face               :foreground "#886600" :slant italic)
  `(font-lock-type-face              :foreground "#FF7700")
  `(font-lock-constant-face          :foreground "#CC5500")
  `(font-lock-builtin-face           :foreground "#FF9900")
  `(font-lock-preprocessor-face      :foreground "#CC4400")
  `(font-lock-warning-face           :foreground "#CC2200" :weight bold)
  `(font-lock-negation-char-face     :foreground "#FF3300" :weight bold)

  ;; Search
  `(isearch                          :background "#FF8800" :foreground "#0D0800" :weight bold)
  `(isearch-fail                     :background "#CC2200" :foreground "#FFB000")
  `(lazy-highlight                   :background "#3D2400" :foreground "#FFB000")
  `(match                            :background "#3D2400" :foreground "#FFC940")

  ;; Completion — vertico / corfu
  `(vertico-current                  :background "#1A1000" :foreground "#FFC940")
  `(corfu-current                    :background "#1A1000" :foreground "#FFC940")
  `(corfu-default                    :background "#0D0800" :foreground "#FFB000")
  `(corfu-border                     :background "#3D2400")

  ;; Company
  `(company-tooltip                  :background "#1A1000" :foreground "#FFB000")
  `(company-tooltip-selection        :background "#FF8800" :foreground "#0D0800")
  `(company-tooltip-common           :foreground "#FF6600")
  `(company-tooltip-annotation       :foreground "#7A5500")
  `(company-scrollbar-bg             :background "#0D0800")
  `(company-scrollbar-fg             :background "#3D2400")

  ;; Org mode
  `(org-level-1                      :foreground "#FFC940" :weight bold)
  `(org-level-2                      :foreground "#FF8800")
  `(org-level-3                      :foreground "#FF6600")
  `(org-level-4                      :foreground "#CC8800")
  `(org-level-5                      :foreground "#CCAA00")
  `(org-block                        :background "#100800" :extend t)
  `(org-block-begin-line             :foreground "#5A3A00" :background "#0F0700" :extend t)
  `(org-block-end-line               :foreground "#5A3A00" :background "#0F0700" :extend t)
  `(org-link                         :foreground "#FF7700" :underline t)
  `(org-date                         :foreground "#CC8800")
  `(org-tag                          :foreground "#7A5500")
  `(org-todo                         :foreground "#FF4400" :weight bold)
  `(org-done                         :foreground "#886600" :weight bold)
  `(org-headline-done                :foreground "#5A3A00")
  `(org-table                        :foreground "#CC8800")
  `(org-formula                      :foreground "#FF7700")

  ;; Dired
  `(dired-directory                  :foreground "#FF7700" :weight bold)
  `(dired-flagged                    :foreground "#CC2200")
  `(dired-marked                     :foreground "#FF8800")
  `(dired-symlink                    :foreground "#FF5500")

  ;; Magit / diff
  `(magit-section-heading            :foreground "#FF8800" :weight bold)
  `(magit-section-highlight          :background "#1A0F00")
  `(magit-branch-local               :foreground "#CCAA00")
  `(magit-branch-remote              :foreground "#FF7700")
  `(magit-hash                       :foreground "#5A3A00")
  `(diff-added                       :background "#091200" :foreground "#886600" :extend t)
  `(diff-removed                     :background "#130300" :foreground "#CC2200" :extend t)
  `(diff-header                      :background "#1A0F00")
  `(diff-hunk-header                 :foreground "#FF8800" :background "#1A0F00")
)

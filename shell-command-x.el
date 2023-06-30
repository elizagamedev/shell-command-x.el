;;; shell-command-x.el --- Extensions for shell commands -*- lexical-binding: t -*-

;; Copyright (C) 2023  Eliza Velasquez

;; Author: Eliza Velasquez
;; Version: 0.1.1
;; Created: 2023-06-29
;; Package-Requires: ((emacs "28.1"))
;; Keywords: convenience processes unix
;; URL: https://github.com/elizagamedev/shell-command-x.el
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `shell-command-x-mode' provides an assortment of extensions for the
;; interactive Emacs shell commands \\[shell-command] and
;; \\[async-shell-command].  Its primary features are:
;;
;; - The names of process buffers can be customized on a per-command basis; for
;;   example, the buffer name for the command `ls -la' can be automatically set
;;   to `*shell:ls*', `*shell:ls -la*', or any other number of desired values.
;;
;; - When a command completes, its output buffer can emulate `special-mode';
;;   this is useful for quickly dismissing (with \\[quit-window]) or quickly
;;   re-running the command (with \\[revert-buffer]).
;;
;; - When a command completes, the point can be moved to the beginning of the
;;   output buffer if the command wasn't interactive; this is useful for paging
;;   through the output of commands like `grep --help'.
;;
;; Refer to the included README.md for a more detailed overview, examples, and
;; tips.

;;; Code:

(require 'cl-lib)
(require 'comint)
(require 'shell)
(require 'simple)

(defgroup shell-command-x nil
  "Extensions for shell commands."
  :group 'shell)

(defcustom shell-command-x-buffer-name-function
  'shell-command-x-format-buffer-name
  "Function that generates names for shell command buffers.

This function must accept two arguments, COMMAND and ASYNC-P.
COMMAND is a string containing the full command-line passed to
the `shell-command' function call.  ASYNC-P is non-nil if the
buffer name is being generated for an async shell command buffer."
  :type 'function
  :group 'shell-command-x)

(defcustom shell-command-x-buffer-name-format "*shell:%n*"
  "Format string for names of new shell buffers.

See the documentation for `shell-command-x-format-buffer-name'
for more details.

A value of \"*Shell Command Output*\" will emulate Emacs' default
behavior."
  :type 'string
  :group 'shell-command-x)

(defcustom shell-command-x-buffer-name-async-format "*shell:%n*"
  "Format string for names of new async shell buffers.

See the documentation for `shell-command-x-format-buffer-name'
for more details.

A value of \"*Async Shell Command*\" will emulate Emacs' default
behavior."
  :type 'string
  :group 'shell-command-x)

(defcustom shell-command-x-exit-hook
  '(shell-command-x-bob-smart-exit-hook
    shell-command-x-emulate-special-mode-exit-hook)
  "Hook run when a shell command completes.

`shell-command-x' provides several built-in functions that you
can use as hooks here:

- `shell-command-x-bob-exit-hook' to adjust point to beginning of
  buffer after the command completes.

- `shell-command-bob-smart-exit-hook' to adjust point to the
  beginning of buffer after the command completes, but only if no
  user input was sent to the process and if the process buffer is
  not focused.

- `shell-command-emulate-special-mode-exit-hook' to emulate
  `special-mode' when a shell command completes.

`current-buffer' will be set to the shell command's process
buffer when executing hooks."
  :type 'hook
  :group 'shell-command-x)

(defvar-local shell-command-x--abort-bob-smart-exit-hook-p nil
  "If t, abort adjusting point on shell command exit.")

(defun shell-command-x-format-buffer-name (command async-p)
  "Create a shell command buffer name based on a format string.

This function can be used as a value for
`shell-command-x-buffer-name-function' to generate buffer names
based on the simple format string variables
`shell-command-x-buffer-name-format' and
`shell-command-x-buffer-name-async-format'.

- \"%n\": The 0th argument, i.e. the command name.

- \"%f\": The entire first command.  E.g., if the command \"echo
  hello; echo world\" is executed, \"%f\" becomes \"echo hello\".

- \"%a\": The entire command line.

See `shell-command-x-buffer-name-function' for information about
the COMMAND and ASYNC-P arguments."
  (let* ((first-command (if (string-match shell-command-regexp command)
                            (match-string-no-properties 0 command)
                          command))
         (command-name (car (split-string-shell-command first-command))))
    (format-spec (if async-p
                     shell-command-x-buffer-name-format
                   shell-command-x-buffer-name-async-format)
                 `((?n . ,command-name)
                   (?f . ,first-command)
                   (?a . ,command)))))

(defun shell-command-x-bob-exit-hook ()
  "Hook for `shell-command-x-exit-hook' to place point at beginning.

This function does nothing if `shell-command-dont-erase-buffer'
is not nil.

Removing this function from `shell-command-x-exit-hook' will
preserve Emacs' default behavior."
  (unless shell-command-dont-erase-buffer
    (let ((win (car (get-buffer-window-list)))
          (pmin (point-min)))
      (if win
          (set-window-point win pmin)
        (goto-char pmin)
        (save-window-excursion
          (let ((win (display-buffer
                      (current-buffer)
                      '(nil (inhibit-switch-frame . t)))))
            (set-window-point win pmin)))))))

(defun shell-command-x-bob-smart-exit-hook ()
  "Hook for `shell-command-x-exit-hook' to place point at beginning.

If `smart', this will only adjust the point if no user input was
sent to the process and if the process buffer is not focused.

This function does nothing if `shell-command-dont-erase-buffer'
is not nil.

Removing this function from `shell-command-x-exit-hook' will
preserve Emacs' default behavior."
  (unless (or shell-command-x--abort-bob-smart-exit-hook-p
              (eq (window-buffer (selected-window)) (current-buffer)))
    (shell-command-x-bob-exit-hook)))

(defun shell-command-x-emulate-special-mode-exit-hook ()
  "Hook for `shell-command-x-exit-hook' to emulate `special-mode'.

When this function is a member of `shell-command-x-exit-hook',
When a shell command completes execution, its output buffer will
become read-only, its local keymap will be set to
`special-mode-map', and `special-mode' hooks will be run.  In
essence, this emulates the behavior of `special-mode' without
actually activating it, preserving the process information.

Removing this function from `shell-command-x-exit-hook' will
preserve Emacs' default behavior."
  (setq buffer-read-only t)
  (use-local-map special-mode-map)
  (run-hooks 'special-mode-hook))

(defun shell-command-x--shell-command-advice
    (orig-fun command &optional output-buffer &rest args)
  "Advice around `shell-command' to rename output buffers.

Refer to `shell-command-x-buffer-name-function' for information
on this function's purpose.

ORIG-FUN is `shell-command'.  Refer to `shell-command' for
documentation on COMMAND, OUTPUT-BUFFER, and ARGS."

  ;; HACK: If `async-shell-command-display-buffer' is nil, the later call to
  ;; `display-buffer' doesn't respect `display-buffer-alist'.  Instead,
  ;; replicate the vanilla behavior with the correct options.
  (cl-letf* ((orig-display-buffer (symbol-function 'display-buffer))
             ((symbol-function 'display-buffer)
              (if async-shell-command-display-buffer
                  ;; No change.
                  orig-display-buffer
                (lambda (buffer-or-name &rest _)
                  ;; Instead of displaying the buffer, advise the process filter
                  ;; to display the buffer later.
                  (let ((proc (get-buffer-process buffer-or-name))
                        (name (make-symbol "once")))
                    (add-function
                     :before (process-filter proc)
                     (lambda (proc _string)
                       (let ((buf (process-buffer proc)))
                         (when (buffer-live-p buf)
                           (remove-function (process-filter proc)
                                            name)
                           (funcall orig-display-buffer
                                    buf '(nil (allow-no-window . t))))))
                     `((name . ,name))))))))
    (let ((async-shell-command-display-buffer t))
      (if (and (not (string-equal "" command))
               (not output-buffer))
          (let ((shell-command-buffer-name
                 (funcall shell-command-x-buffer-name-function command nil))
                (shell-command-buffer-name-async
                 (funcall shell-command-x-buffer-name-function command t)))
            (apply orig-fun command output-buffer args))
        (funcall orig-fun command output-buffer args)))))

(defun shell-command-x--shell-command-sentinel-advice (process _)
  "Advice after `shell-command-sentinel' to watch for completion.

Refer to `shell-command-x-exit-hook' for information on this
function's purpose.

Refer to `set-process-sentinel' for information on PROCESS."
  (when (memq (process-status process) '(exit signal))
    (with-current-buffer (process-buffer process)
      (run-hooks 'shell-command-x-exit-hook))))

(defun shell-command-x--comint-send-advice (&rest _)
  "Advice before `comint-send-input' and `comint-send-invisible'.

Refer to `shell-command-x-beginning-of-buffer-on-completion' for
information on this function's purpose."
  (setq shell-command-x--abort-bob-smart-exit-hook-p t))

;;;###autoload
(define-minor-mode shell-command-x-mode
  "Extensions for shell commands."
  :global t
  :group 'shell-command-x
  (if shell-command-x-mode
      (progn
        (advice-add #'shell-command :around
                    #'shell-command-x--shell-command-advice)
        (advice-add #'shell-command-sentinel :after
                    #'shell-command-x--shell-command-sentinel-advice)
        (advice-add #'comint-send-input :before
                    #'shell-command-x--comint-send-advice)
        (advice-add #'comint-send-invisible :before
                    #'shell-command-x--comint-send-advice))
    (advice-remove #'shell-command
                   #'shell-command-x--shell-command-advice)
    (advice-remove #'shell-command-sentinel
                   #'shell-command-x--shell-command-sentinel-advice)
    (advice-remove #'comint-send-input
                   #'shell-command-x--comint-send-advice)
    (advice-remove #'comint-send-invisible
                   #'shell-command-x--comint-send-advice)))

(provide 'shell-command-x)

;;; shell-command-x.el ends here

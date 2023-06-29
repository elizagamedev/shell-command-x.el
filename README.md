# shell-command-x.el

Extensions for Emacs' shell commands.

## Overview

`shell-command-x-mode` provides an assortment of extensions for the interactive
Emacs shell commands `shell-command` and `async-shell-command`. Its primary
features are:

- The names of process buffers can be customized on a per-command basis; for
  example, the buffer name for the command `ls -la` can be automatically set to
  `*shell:ls*`, `*shell:ls -la*`, or any other number of desired values.

- When a command completes, its output buffer can emulate `special-mode`; this
  is useful for quickly dismissing (with `quit-window`) or quickly re-running
  the command (with `revert-buffer`).

- When a command completes, the point can be moved to the beginning of the
  output buffer if the command wasn't interactive; this is useful for paging
  through the output of commands like `grep --help`.

## Installation

This package is not yet available on M?ELPA. In the meantime, you can use
something like [straight.el](https://github.com/radian-software/straight.el) or
[elpaca.el](https://github.com/progfolio/elpaca). Here is an example with
[use-package.el](https://github.com/jwiegley/use-package):

```elisp
(use-package shell-command-x
  :elpaca (:host github :repo "elizagamedev/shell-command-x.el")
  :init
  (shell-command-x-mode 1))
```

## Configuration

`shell-command-x` is highly configurable. Refer to its customization group for a
full list of options and detailed documentation.

`M-x customize-group RET shell-command-x RET`.

Additionally, there are some other built-in shell-related configuration options
that pair well `shell-command-x-mode`. In particular, by setting
`async-shell-command-display-buffer` to `nil` and configuring
`display-buffer-alist`, you can configure Emacs to be very particular about only
displaying command buffers that have useful output.

```elisp
;; If a shell command never outputs anything, don't show it.
(customize-set-variable 'async-shell-command-display-buffer nil)

(customize-set-variable
 'display-buffer-alist
 `(;; Never show mpv and xdg-open buffers...
   ("\\*shell:\\(mpv\\|xdg-open\\)\\*.*"
    (display-buffer-no-window))
   ;; ...but show all other command outputs in a dedicated side window.
   ("\\*shell:.*?\\*.*"
    (display-buffer-in-side-window)
    (side . right)
    (window-width . 80)
    (dedicated . t))
   ;; etc...
   ))
```

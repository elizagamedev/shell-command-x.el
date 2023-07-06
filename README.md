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

This package is available on [MELPA](https://melpa.org/#/shell-command-x).
Simply activate `shell-command-x-mode` in your configuration after installing.

```elisp
(shell-command-x-mode 1)
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

## Similar Packages

- [shelldon.el](https://github.com/Overdr0ne/shelldon). Like `shell-command-x`,
  `shelldon` gives buffers more meaningful names. `shelldon` also provides a
  numbered history of each command run out of the box. However,
  `shell-command-x` has a more configurable naming scheme and provides more
  features. The two packages are theoretically compatible with one another.
- [dwim-shell-command.el](https://github.com/xenodium/dwim-shell-command). This
  package primarily adds extra templated arguments to shell commands, in
  particular, when used with `dired`. It also provides its own take on whether
  or not to display shell command buffers, using a combination of heuristics and
  explicit user input. While the extra templating is a fantastic feature, its
  focusing behavior conflicts with an ordinary `display-buffer-alist`-based
  workflow. The two packages are theoretically compatible with one another.
- [async-shell.el](https://github.com/sgpthomas/async-shell). In addition to the
  special-mode like features, provides some additional features via a
  transient-based interface. It operates separately from the built-in
  `shell-command`, but all in all, it's very similar to shell-command-x.el.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2023-06-30

### Fixed

- Fixed reversed behavior of `shell-command-x-buffer-name-async-format` and
  `shell-command-x-buffer-name-format`.

## [0.1.1] - 2023-06-29

### Fixed

- `async-shell-command-display-buffer` now behaves correctly according to the
  README. Vanilla Emacs does not respect `display-buffer-no-window` in
  `display-buffer-alist` when this variable is set to `nil`; this behavior has
  been patched.

## [0.1.0] - 2023-06-29

### Added

- Initial release.

[unreleased]: https://github.com/elizagamedev/shell-command-x.el/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/elizagamedev/shell-command-x.el/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/elizagamedev/shell-command-x.el/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/elizagamedev/shell-command-x.el/releases/tag/v0.1.0

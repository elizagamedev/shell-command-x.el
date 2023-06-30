# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2023-06-29

### Fixed

- `async-shell-command-display-buffer` now behaves correctly according to the
  README. Vanilla Emacs does not respect `display-buffer-no-window` in
  `display-buffer-alist` when this variable is set to `nil`; this behavior has
  been patched.

## [0.1.0] - 2023-06-29

### Added

- Initial release.

[unreleased]: https://github.com/elizagamedev/shell-command-x.el/compare/v1.1.1...HEAD
[0.1.1]: https://github.com/elizagamedev/shell-command-x.el/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/elizagamedev/shell-command-x.el/releases/tag/v0.1.0

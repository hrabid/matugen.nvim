# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### ⚠ BREAKING CHANGES

- **Removed all JSONC support.** The `lua/matugen/jsonc.lua` module has been
  deleted. Palette files **must** now be plain `.json` — comments are no longer
  stripped. Update any `.jsonc` palette files by removing comments before use.

### Added

- **Palette validator (`lua/matugen/validator.lua`).**
  Colors are now validated before loading the theme. If the palette file
  contains invalid hex values or is missing required keys, the plugin falls
  back gracefully to `fallback_palette` instead of crashing.
- **Support for `#RGBA` (4-hex-digit) color format** in the validator and
  `hex()` normalizer.
- **Test suite.** Initial specs for setup and palette-missing error handling
  via `PlenaryBustedDirectory` (`tests/matugen_spec.lua`,
  `tests/minimal_init.lua`).
- **`.github/Makefile`** with a `test` target for local headless test execution.
- **GitHub Actions CI** (`.github/workflows/tests.yml`) running tests on
  pushes/PRs to `main`.

### Fixed

- **JSONC line comments at byte 0 of a file are now correctly stripped.**
  The pattern `^%s*//[^\n]*` was missing, causing files starting with `//` to
  fail parsing.
- **Broken regex in `is_valid_hex` replaced** with explicit length checks
  (`#hex == 3, 4, 6, or 8`), making validation reliable.
- **Non-hex color values in the palette no longer cause false validation
  failures.** Only values starting with `#` are validated as hex; other
  strings pass through.
- **Deduplicated invalid-palette warning on cache replay.** The warning is
  now shown only once per session instead of on every signal reload.
- **Renamed loop variable in template loader** to `ftype` to avoid shadowing
  Lua's global `type()` function.
- **Removed spurious warning** when `load_theme` is explicitly set to `false`
  in user config.
- **Removed unrelated `winblend` autocmd** from `plugin/matugen.lua` that was
  setting `winblend = 0` for non-matugen floating windows.
- **Always re-apply all template highlights on reload** instead of the
  incremental `hlID` guard that could miss groups removed by other plugins.

### Changed

- Extracted the JSONC comment stripper into `lua/matugen/jsonc.lua` — shared
  by `init.lua` and `health.lua` instead of maintaining two copies.
- Hoisted the `hex()` color normalizer from inside `_apply_highlights` to
  module level to avoid re-creating the closure on every highlight pass.
- Added `---@param` / `---@return` type annotations to the public API for
  better LuaLS diagnostics.
- Moved hex validation from `palette.lua` to `lua/matugen/validator.lua`.
- Moved required-keys list from `palette.lua` to `lua/matugen/validator.lua`.
- Moved fallback logic from `palette.lua` to `init.lua`.
- Consolidated all validation into a single `is_valid()` function in
  `lua/matugen/validator.lua`.
- `palette.lua` is now bypassed entirely when the validator rejects raw
  palette values.
- **Template loading switched from `vim.fn.glob` to `vim.fs.dir`** for
  better performance.
- **Removed per-file `vim.fn.resolve` calls** by resolving the template
  directory once, eliminating redundant symlink-escape checks on every file.
- **Deduplicated `fallback_palette` merge** into a single post-resolution
  step, removing duplicate merges in both palette branches.
- **Removed unused `vim.g` writes** (`matugen_last_reload`,
  `matugen_template_count`) that triggered unnecessary global `OptionSet`
  autocmd events.
- **Moved validator from `tests/` to `lua/matugen/`**, replacing the
  `dofile`-based loading with a standard `require`.

### ⚠ BREAKING CHANGES

- **`jsonc_path` has been renamed to `palette_path`.**
  You must update your plugin configuration to use the new option name.

  ```diff
  require("matugen").setup({
  -  jsonc_path = "~/.config/matugen/themes/nvim-colors.jsonc",
  +  palette_path = "~/.config/matugen/themes/nvim-colors.json",
  })
  ```

- **`nvim-colors.jsonc` has been converted to `nvim-colors.json`.**
  The bundled template file is now plain JSON (comments replaced with blank
  line separators). Update your matugen `config.toml` paths accordingly.

### Changed

- Renamed the `jsonc_path` option to `palette_path` for better UX — the old
  name incorrectly implied that only `.jsonc` files were supported.
- Converted `nvim-colors.jsonc` to `nvim-colors.json` — comments removed,
  blank lines used as section separators instead.
- The JSONC comment stripper is now automatically bypassed for plain `.json`
  files (detected by file extension). `.jsonc` files continue to have comments
  stripped as before.
- Updated all user-facing messages, health checks, docs, and README to reflect
  the new `palette_path` name and `.json` template.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed

- **`:MatugenReload` no longer re-reads static template files from disk.**
  Templates are cached at startup; the command now only re-reads the palette
  JSON and re-applies highlights. Added `:MatugenReloadTemplates` for the rare
  case of manually editing template files.
- **JSONC line comments at byte 0 of a file are now correctly stripped.**
  The pattern `^%s*//[^\n]*` was missing, causing files starting with `//` to
  fail parsing.

### Changed

- Extracted the JSONC comment stripper into `lua/matugen/jsonc.lua` — shared
  by `init.lua` and `health.lua` instead of maintaining two copies.
- Hoisted the `hex()` color normalizer from inside `_apply_highlights` to
  module level to avoid re-creating the closure on every highlight pass.
- Added `---@param` / `---@return` type annotations to the public API for
  better LuaLS diagnostics.
- Enhanced `.luarc.json` with `LuaJIT` runtime, schema reference, and
  third-party check config. Removed `.luarc.json` and `cspell.json` from
  `.gitignore` so project config is tracked.

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

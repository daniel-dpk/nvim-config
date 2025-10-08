# Repository Guidelines

## Important note for coding agents
**Always** use relative paths for all tool calls.

## Purpose
Modern Neovim config in Lua using lazy.nvim for IDE-like experience.

## Structure
- `init.lua` loads `config.lazy`, `config.options`, `config.keymaps`
- the `./lua/` directory is added to the Lua search path by Neovim, so that, e.g., `require('config.lazy')` loads `./lua/config/lazy.lua`
- `lazy.nvim` plugin specs reside in `lua/config/plugins/*.lua`
- ftplugins, syntax, etc., in `after/` extend the default settings
- local plugins (not cloned from external sources) loaded by `lazy.nvim` reside in `local/` (example: `code-nav` loaded in `lua/config/plugins/code-nav.lua`)
- local helpers used in, e.g., keymaps but not managed by `lazy.nvim` reside in `lua/utils/` (these could in principle be turned into `lazy.nvim`-managed plugins)

## Style
- 2-space indent
- single-quote strings
- prefer Lua over vimscript, also in mappings
- `vim.o`/`vim.opt` for options
- `vim.g` for globals
- modules return a table (`return { ... }`)
- require modules with dot notation

## Naming
- files & dirs snake_case
- variables & functions lower_snake_case
- globals `vim.g.<name>`

## Keymaps
- `vim.keymap.set(mode, lhs, rhs, { desc = '...' })`
- description is important for `which-key`, it should be concise since it is shown in `which-key` popup tables
- as noted above, implement `rhs` via Lua if it makes sense (exceptions to this rule are OK, such as many mappings in `lua/keymaps.lua`)

## Formatting
- blank line between sections
- trailing commas in tables
- <=80 chars per line

# Repository Guidelines

## Important note for coding agents
**Always** use relative paths for all tool calls.

## Purpose
Modern Neovim config in Lua using lazy.nvim for IDE‑like experience.

## Structure
- `init.lua` loads `config.lazy`, `options`, `keymaps`
- the `./lua/` directory is added to the Lua search path by Neovim, so that, e.g., `require('config.lazy')` loads `./lua/config/lazy.lua`
- plugins reside in `lua/config/plugins/*.lua` and are configured to be loaded by `lazy.lua`
- ftplugins, syntax, etc., in `after/` extend the default settings

## Style
- 2‑space indent
- single‑quote strings
- prefer Lua over vimscript, also in mappings
- `vim.o`/`vim.opt` for options
- `vim.g` for globals
- modules return a table (`return { … }`)
- require modules with dot notation

## Naming
- files & dirs snake_case
- variables & functions lower_snake_case
- globals `vim.g.<name>`

## Keymaps
- `vim.keymap.set(mode, lhs, rhs, { desc = '…' })`
- description is important for `which-key`, it should be concise since it is shown in `which-key` popup tables
- as noted above, implement `rhs` via Lua if it makes sense (exceptions to this rule are OK, such as many mappings in `lua/keymaps.lua`)

## Formatting
- blank line between sections
- trailing commas in tables
- ≤80 chars per line

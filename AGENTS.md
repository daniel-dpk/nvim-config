# AGENTS.md

**Purpose**: Modern Neovim config in Lua using lazy.nvim for IDE‑like experience.

**Structure**: init.lua loads `config.lazy`, `options`, `keymaps`; plugins reside in `lua/config/plugins/*.lua`; ftplugins in `after/`.

**Style**: 2‑space indent, single‑quote strings, `vim.o`/`vim.opt` for options, `vim.g` for globals. Modules return a table (`return { … }`). Require modules with dot notation.

**Naming**: Files & dirs snake_case; variables & functions lower_snake_case; globals `vim.g.<name>`.

**Keymaps**: `vim.keymap.set(mode, lhs, rhs, { desc = '…' })`.

**Plugin specs**: `{ 'author/plugin', event = 'VimEnter', opts = { … }, keys = { … } }`.

**Formatting**: Blank line between sections, trailing commas in tables, ≤80 chars per line.

**Best practices**: Keep plugins under `lua/config/plugins/`; disable lazy change detection (`change_detection.enabled = false`); bootstrap lazy via git clone in `config.lazy`.
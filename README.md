# Neovim Configuration

> [!NOTE]
> A Neovim configuration highly depends on individual preferences. This
> configuration will most likely *not* suit anyone but me. However, ideally it
> serves as starting point and/or inspiration for your own configuration.

> [!TIP]
> An better more general starting point for most people, from which this
> configuration is heavily inspired, is
> [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
> or the modular variant
> [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim).

> [!NOTE]
> This configuration is tested and used on Linux and macOS in Ghostty.

> [!NOTE]
> This config targets Neovim `0.12+`. The rewritten `nvim-treesitter` setup
> may not be compatible with Neovim `0.11`.


## Installing dependencies

On Linux (examples for Ubuntu):

* [neovim](https://neovim.io/) can be installed via [Homebrew](https://brew.sh/)
  for macOS and Linux. For Ubuntu, you can also do:
  ```
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  ```
  Then, add Neovim's binary directory to `PATH` (`~/.bashrc`, `~/.zshrc`, ...):
  ```
  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
  ```
* `sudo apt install make gcc unzip git xclip`
* [ripgrep](https://github.com/BurntSushi/ripgrep#installation):
  The snap is not recommended. You may download the `.deb` file from
  [https://github.com/BurntSushi/ripgrep/releases]
  and run `sudo dpkg -i ripgrep_*_amd64.deb`.
* [fd-find](https://github.com/sharkdp/fd#installation)
* Some dependencies (e.g., `pyright`) run via `Node.js`. If this is not yet
  available, you can install it via these steps:
  * install [nvm](https://github.com/nvm-sh/nvm) (then restart the shell)
  * `nvm install --lts`
  * `nvm use --lts`
* JSON/JSONC LSP (`jsonls`) requires `vscode-json-language-server`:
  `npm install -g vscode-langservers-extracted`
* Some language parsers for `tree-sitter` need to be built from language
  definitions via the `tree-sitter-cli`. See
  [https://tree-sitter.github.io/tree-sitter/creating-parsers#installation]
  for how to install it. Install it via your package manager, for example:
  ```
  brew install tree-sitter-cli
  ```
  The current `nvim-treesitter` setup expects a recent CLI and upstream no
  longer recommends installing it via `npm`. If you previously installed it
  via `npm`, uninstall it via:
  ```
  npm uninstall -g tree-sitter-cli
  ```
* To use the AI coding agent [OpenCode](https://github.com/sst/opencode)
  with Neovim via the
  [opencode.nvim](https://github.com/NickvanDyke/opencode.nvim)
  plugin, you may install `OpenCode` itself via [Homebrew](https://brew.sh/)
  (`brew install sst/tap/opencode`) or
  ```
  npm install -g opencode-ai
  ```
  Update OpenCode via `npm update -g opencode-ai`
  (or `brew upgrade sst/tap/opencode`).
* To install the Lua LSP, see [lua_ls](https://luals.github.io/#neovim-install)
* Requirements for the Python LSP setup:
  ```
  npm install -g pyright
  sudo apt install python3-venv # dependency of pipx
  python3 -m pip install --user pipx
  pipx ensurepath
  pipx install ruff
  pipx install basedpyright # alternative of `pyright`
  ```
  In contrast to `pip`, `pipx` will install lightweight virtual environments
  for command line tools and make them available in `~/.local/bin`. This makes
  those tools independent of any local Python setup and globally available.


## Install this config

```
cd ~/.config/
git clone git@github.com:daniel-dpk/nvim-config.git nvim
```

Now, start Neovim (`nvim`) and let it download/install/build everything it
needs. Exit Neovim and start it again, done.


## Updating an existing setup

If you already use this config on another machine and update it to a newer
revision, the safest order is:

1. Upgrade Neovim to `0.12+` first.
2. Ensure `tree-sitter-cli` comes from your package manager, for example:
   `brew install tree-sitter-cli`
   It should be at least version `0.26.1`.
3. If you previously installed `tree-sitter-cli` via `npm`, remove that old
   global install so it does not shadow the package-manager version:
   `npm uninstall -g tree-sitter-cli`
4. Start Neovim and run `:Lazy sync`
5. Restart Neovim once the plugin update finishes so parser installation can
   complete cleanly.
6. Run `:checkhealth nvim-treesitter` if Treesitter-related features look odd.

If a machine must stay on Neovim `0.11`, it should stay on an older revision
of this repo or keep `nvim-treesitter` on its legacy `master` branch instead of
using the current setup.


## Running tests

```
nvim --headless -u NONE -i NONE -n -l tests/run.lua
```


## Troubleshooting

### Some things don't work inside tmux

You may have to add the following to your `~/.tmux.conf`:
```
set -g default-terminal "tmux-256color"
set-option -sg escape-time 10
set-option -g xterm-keys on
set -g extended-keys off

# To make copy/paste work inside Neovim
set-option -s set-clipboard on

# To make Neovim notice external changes when inside tmux
set-option -g focus-events on

# With extended-keys turned off, we need to forward some of them by hand
bind-key -T root C-, send-keys Escape "[44;5u"
bind-key -T root C-S-a send-keys Escape "[97;6u"
bind-key -T root C-S-h send-keys Escape "[104;6u"
bind-key -T root C-S-j send-keys Escape "[106;6u"
bind-key -T root C-S-k send-keys Escape "[107;6u"
bind-key -T root C-S-l send-keys Escape "[108;6u"
bind-key -T root C-S-s send-keys Escape "[115;6u"
bind-key -T root C-S-u send-keys Escape "[117;6u"
bind-key -T root C-S-d send-keys Escape "[100;6u"
```


### Issues in Ghostty

In `~/Library/Application Support/com.mitchellh.ghostty/config` (macOS) or
`~/.config/ghostty/config` (Linux), consider adding:

```
keybind = alt+left=unbind
keybind = alt+right=unbind

keybind = ctrl+shift+left=unbind
keybind = ctrl+shift+right=unbind

keybind = alt+shift+h=esc:H
keybind = alt+shift+j=esc:J
keybind = alt+shift+k=esc:K
keybind = alt+shift+l=esc:L

keybind = alt+shift+i=esc:I

keybind = alt+k=esc:k
keybind = alt+j=esc:j

shell-integration-features = no-cursor,no-title
```

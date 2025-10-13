# Neovim Configuration

> [!NOTE]
> A Neovim configuration highly depends on individual preferences. This
> configuration will most likely *not* suit anyone but me. However, ideally it
> serves as starting point and/or inspiration for your own configuration.

> [!TIP]
> An alternative starting point that is more general is
> [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
> or the modular variant
> [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim).

> [!NOTE]
> This configuration is tested and used on Linux. Some effort is done to make
> it work on macOS.


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
* Some language parsers for `tree-sitter` need to be built from language
  definitions via the `tree-sitter-cli`. See
  [https://tree-sitter.github.io/tree-sitter/creating-parsers#installation]
  for how to install it. If you installed `npm` above, you can use this:
  ```
  npm install -g tree-sitter-cli
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

# nvim

Personal Neovim config. Plugins managed by [lazy.nvim](https://github.com/folke/lazy.nvim)
and pinned in `lazy-lock.json` for reproducible installs.

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim --headless "+Lazy! restore" +qa   # installs exact pinned plugin commits
```

`lazy.nvim` bootstraps itself on first launch. `Lazy! restore` installs the
commits recorded in `lazy-lock.json` (use `:Lazy sync` to update and re-pin).

## Requirements

* Neovim >= 0.11 (uses `vim.lsp.config`)
* `git`
* A C compiler (`gcc`/`clang`) — nvim-treesitter compiles parsers
* A Nerd Font

### Language servers (installed via `:Mason`)

`clangd`, `rust-analyzer`, `zls`, `pyright`, `lua_ls`

Mason installs binaries to `~/.local/share/nvim/mason/bin`. The LSP configs in
`after/plugin/lsp.lua` call them by bare name, so that directory must be on your
`PATH`. Add to your shell rc (`.bashrc`/`.zshrc`):

```sh
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
```

> Mason has no lockfile — server versions are not pinned and track latest on
> install. Plugin commits are pinned (`lazy-lock.json`); server binaries are not.

### Formatters (conform.nvim)

`stylua` (lua), `rustfmt` (rust), `ruff` (or `isort` + `black`, python)

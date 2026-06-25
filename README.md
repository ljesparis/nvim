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

### Language servers (installed via `:Mason`, must be on PATH)

`clangd`, `rust-analyzer`, `zls`, `pyright`, `lua_ls`

### Formatters (conform.nvim)

`stylua`, `rustfmt`, `ruff` (or `isort` + `black`), `codespell`

> `codespell` runs on save for every filetype — install it or remove the
> `["*"]` entry in `after/plugin/conform.lua`.

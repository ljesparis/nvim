# nvim

Personal Neovim config. Plugins managed by [lazy.nvim](https://github.com/folke/lazy.nvim)
and pinned in `lazy-lock.json` for reproducible installs.

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim --headless "+Lazy! restore" "+TSUpdateSync" +qa   # pinned plugins + treesitter parsers
```

`lazy.nvim` bootstraps itself on first launch. `Lazy! restore` installs the
commits recorded in `lazy-lock.json` (use `:Lazy sync` to update and re-pin).

`+TSUpdateSync` compiles the treesitter parsers synchronously. Without it,
parsers build asynchronously on your first interactive launch instead (you'll
see "Compiling..." once) — both work, but the synchronous form finishes the
whole install in one headless command. Needs a C compiler present.

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

## Debugging (Python in Docker)

Remote-attach via [nvim-dap](https://github.com/mfussenegger/nvim-dap). The
debugger runs inside the container; Neovim attaches over a published port.

In the target project's `docker-compose.yml`, launch the app under debugpy and
publish the port:

```yaml
services:
  app:
    command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m yourapp
    ports:
      - "5678:5678"
```

`debugpy` must be installed in the image. `--wait-for-client` blocks the
process until Neovim attaches, so no early breakpoints are missed.

Then in Neovim, from the repo whose source is mounted in the container:

1. Set breakpoints with `<leader>db`.
2. `<leader>dc` → pick "Python: Attach to Docker (debugpy)".
3. Enter the port (default `5678`) and the container path the source is mounted
   at (`remoteRoot`, default `/app`). `localRoot` is the current working
   directory — it must hold the same source as `remoteRoot` or breakpoints
   won't bind.

Keymaps: `<leader>db` breakpoint, `<leader>dc` continue/attach, `<leader>di`/`do`/`dO` step into/over/out, `<leader>du` toggle UI, `<leader>dt` terminate.

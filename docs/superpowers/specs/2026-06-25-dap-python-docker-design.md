# DAP debugging for Python in Docker — design

Date: 2026-06-25
Status: approved

## Goal

Add interactive debugging (breakpoints, step, variable inspection) to this
Neovim config, scoped to **Python running inside Docker Compose containers**.
The architecture must leave room to add native-language debugging (Rust, C,
Zig via `codelldb`) later without rework.

## Background

The Python application runs inside a Docker Compose service the user controls
and can edit. Therefore the debugger connects with the **remote-attach**
pattern: `debugpy` runs inside the container and listens on a TCP port;
Neovim's DAP client attaches to that port from the host. No debugpy is needed
on the host — it lives in the container image.

## Non-goals

- Local (non-Docker) Python debugging, test debugging, or `nvim-dap-python`.
- Rust / C / Zig adapters. Designed-for-later, not built now.
- A launch-type configuration. Only attach is in scope.
- Per-project config files (`.nvim/dap.lua`). Possible future extension.

## Approach

Plain `nvim-dap` with a hand-written attach configuration. Minimal, fully
controlled, deterministic. Rejected alternatives: `nvim-dap-python` (adds a
host debugpy dependency and targets local/test debugging, wrong fit) and
per-project config files (more moving parts than needed now).

## Plugins

Added to the lazy spec in `lua/ljesparis/plugins.lua`, commit-pinned in
`lazy-lock.json`:

- `mfussenegger/nvim-dap` — DAP core
- `rcarriga/nvim-dap-ui` — variables / scopes / breakpoints / watches UI
- `nvim-neotest/nvim-nio` — required dependency of nvim-dap-ui

No Mason packages and no host-side debugpy: the adapter lives in the container.

## Configuration — `after/plugin/dap.lua`

A new file, following the existing `after/plugin/*.lua` convention (each file
requires its plugin and configures it; no config in the lazy spec).

Responsibilities:

1. **Adapter** — register a `python` adapter of type `server` that connects to
   `host = "127.0.0.1"`, `port = <chosen at attach time>`.
2. **Configuration** — one entry named **"Python: Attach to Docker (debugpy)"**:
   - `type = "python"`, `request = "attach"`
   - port: prompted, default `5678`
   - `pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = <prompted, default "/app"> } }`
   - `justMyCode = false` so stepping into dependencies works
3. **dap-ui** — `require("dapui").setup()`; auto-open on
   `event_initialized`, auto-close on `event_terminated` / `event_exited`
   via `dap.listeners`.
4. **Signs** — breakpoint / stopped-line signs (simple text markers consistent
   with the gitsigns style already in the config).

### Path mapping

`localRoot` is the Neovim working directory (the cloned repo on the host).
`remoteRoot` is where that same source is mounted inside the container
(commonly `/app`). These must point at the same source tree or breakpoints
won't bind. The default is `/app`, overridable at attach time via the prompt.

## Keymaps

Space leader, matching existing style (set in `after/plugin/dap.lua`):

| Key          | Action                         |
|--------------|--------------------------------|
| `<leader>db` | toggle breakpoint              |
| `<leader>dc` | continue / start attach        |
| `<leader>di` | step into                      |
| `<leader>do` | step over                      |
| `<leader>dO` | step out                       |
| `<leader>du` | toggle dap-ui                  |
| `<leader>dt` | terminate session              |

## Container side (documentation only)

Not part of the Neovim config. Documented in `README.md`. The Compose service
must launch debugpy and publish its port, and the image must contain debugpy:

```yaml
# docker-compose.yml (the target project, not this repo)
services:
  app:
    command: python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m yourapp
    ports:
      - "5678:5678"
```

`--wait-for-client` makes the process block until Neovim attaches, so no
breakpoints are missed at startup. `debugpy` must be installed in the image
(e.g. added to the project's requirements / Dockerfile).

## Determinism impact

- New plugins are commit-pinned in `lazy-lock.json` like the rest.
- No new host binaries, no Mason additions, no compiler requirements.
- Fresh-PC install path is unchanged: `Lazy! restore` pulls the pinned DAP
  plugins along with everything else.

## Verification

- Isolated `NVIM_APPNAME` clean-env test: `Lazy! restore` installs the three
  new plugins at their locked commits, config loads with no errors.
- Functional smoke test: `:lua require("dap")` and `:lua require("dapui")`
  load; the "Python: Attach to Docker (debugpy)" configuration appears in
  `:lua require("dap").configurations.python`.
- End-to-end (manual, user side): run a compose service with the debugpy
  command above, set a breakpoint, `<leader>dc`, confirm the session stops.

## Future extensions

- Rust / C / Zig via `codelldb` (Mason-installable), added as more adapters in
  the same `dap.lua`.
- Per-project `.nvim/dap.lua` for repos whose `remoteRoot` differs, to avoid
  the prompt.

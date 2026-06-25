# DAP Python-in-Docker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add nvim-dap remote-attach debugging for Python running in Docker Compose containers.

**Architecture:** Three commit-pinned plugins (nvim-dap, nvim-dap-ui, nvim-nio) added to the lazy spec. A new `after/plugin/dap.lua` registers a `python` server adapter, one attach configuration with prompted port and path mapping, dap-ui auto open/close, breakpoint signs, and space-leader keymaps. Container-side debugpy setup is documented in the README only.

**Tech Stack:** Neovim 0.11+, lazy.nvim, Lua, nvim-dap, nvim-dap-ui, nvim-nio.

## Global Constraints

- Plugins MUST be committed to `lazy-lock.json` (deterministic installs). Copy verbatim: pinned commits only, no floating.
- Plugin setup lives in `after/plugin/*.lua`, NOT in the lazy spec (`opts`/`config` omitted) — existing convention.
- No new host binaries, no Mason packages, no compiler deps — debugpy runs inside the container.
- Leader is space (`vim.g.mapleader = " "`). Keymaps use `<leader>d*`.
- "Verification" = headless nvim commands; there is no unit-test runner.

---

### Task 1: Add and pin the DAP plugins

**Files:**
- Modify: `lua/ljesparis/plugins.lua` (the `spec` table)
- Modify: `lazy-lock.json` (generated)

**Interfaces:**
- Produces: installed plugins `nvim-dap`, `nvim-dap-ui`, `nvim-nio` available via `require("dap")` and `require("dapui")`.

- [ ] **Step 1: Write the failing check**

Run this now — it must FAIL because the plugin isn't installed yet:

```bash
cd ~/.config/nvim && nvim --headless "+lua local ok=pcall(require,'dap'); io.stderr:write('dap loadable: '..tostring(ok)..'\n')" +qa 2>&1 | grep "dap loadable"
```
Expected: `dap loadable: false`

- [ ] **Step 2: Add the plugins to the lazy spec**

In `lua/ljesparis/plugins.lua`, inside the `spec = { ... }` table, add after the blink.cmp block (before the colorschemes):

```lua
		-- debugging (DAP)
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		},
```

(Listing dap-ui with its dependencies pulls in nvim-dap and nvim-nio; all three install.)

- [ ] **Step 3: Install and lock**

Run:
```bash
cd ~/.config/nvim && nvim --headless "+Lazy! sync" +qa 2>&1 | tail -2
```
Expected: completes; no error lines.

- [ ] **Step 4: Verify the check now passes and plugins are pinned**

Run:
```bash
cd ~/.config/nvim && nvim --headless "+lua local a=pcall(require,'dap'); local b=pcall(require,'dapui'); io.stderr:write('dap='..tostring(a)..' dapui='..tostring(b)..'\n')" +qa 2>&1 | grep "dap="
grep -E "nvim-dap|nvim-dap-ui|nvim-nio" ~/.config/nvim/lazy-lock.json
```
Expected: `dap=true dapui=true`, and three lock entries each with a `"commit"`.

- [ ] **Step 5: Commit**

```bash
cd ~/.config/nvim && git add lua/ljesparis/plugins.lua lazy-lock.json && git commit -m "feat: add nvim-dap, nvim-dap-ui, nvim-nio (pinned)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: DAP config, adapter, attach configuration, UI, keymaps

**Files:**
- Create: `after/plugin/dap.lua`

**Interfaces:**
- Consumes: `require("dap")`, `require("dapui")` from Task 1.
- Produces: `require("dap").adapters.python` (server adapter); `require("dap").configurations.python` containing one entry named `"Python: Attach to Docker (debugpy)"`.

- [ ] **Step 1: Write the failing check**

Run now — FAILS because the file doesn't exist yet:

```bash
cd ~/.config/nvim && nvim --headless "+lua local d=require('dap'); local c=d.configurations.python; io.stderr:write('py configs: '..tostring(c and #c or 0)..'\n')" +qa 2>&1 | grep "py configs"
```
Expected: `py configs: 0` (or nil → 0).

- [ ] **Step 2: Create `after/plugin/dap.lua`**

Write this exact content:

```lua
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Breakpoint / stopped-line signs (text style consistent with the config)
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

-- Auto open/close the UI with the debug session
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Python adapter: connect to a debugpy server (running in the container)
dap.adapters.python = function(callback, config)
	callback({
		type = "server",
		host = "127.0.0.1",
		port = config.port or 5678,
	})
end

-- One configuration: attach to debugpy over a published port
dap.configurations.python = {
	{
		type = "python",
		request = "attach",
		name = "Python: Attach to Docker (debugpy)",
		port = function()
			return tonumber(vim.fn.input("debugpy port: ", "5678"))
		end,
		justMyCode = false,
		pathMappings = {
			{
				localRoot = function()
					return vim.fn.getcwd()
				end,
				remoteRoot = function()
					return vim.fn.input("container remoteRoot: ", "/app")
				end,
			},
		},
	},
}

-- Keymaps (space leader)
local map = vim.keymap.set
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "DAP: continue / attach" })
map("n", "<leader>di", dap.step_into, { desc = "DAP: step into" })
map("n", "<leader>do", dap.step_over, { desc = "DAP: step over" })
map("n", "<leader>dO", dap.step_out, { desc = "DAP: step out" })
map("n", "<leader>du", dapui.toggle, { desc = "DAP: toggle UI" })
map("n", "<leader>dt", dap.terminate, { desc = "DAP: terminate" })
```

- [ ] **Step 3: Verify the check now passes**

Run:
```bash
cd ~/.config/nvim && nvim --headless "+lua local d=require('dap'); local c=d.configurations.python; io.stderr:write('py configs: '..tostring(#c)..' name='..c[1].name..'\n')" +qa 2>&1 | grep "py configs"
```
Expected: `py configs: 1 name=Python: Attach to Docker (debugpy)`

- [ ] **Step 4: Verify no startup errors**

Run:
```bash
cd ~/.config/nvim && nvim --headless "+messages" +qa 2>&1 | grep -iE "error|nil value|E5" || echo "clean startup"
```
Expected: `clean startup`

- [ ] **Step 5: Commit**

```bash
cd ~/.config/nvim && git add after/plugin/dap.lua && git commit -m "feat: python-in-docker debug attach config + keymaps

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Document the container side in the README

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: nothing. Pure documentation.

- [ ] **Step 1: Add a Debugging section to `README.md`**

Append this section to the end of `README.md`:

```markdown
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
```

- [ ] **Step 2: Verify it renders / committed cleanly**

Run:
```bash
cd ~/.config/nvim && grep -c "Python: Attach to Docker" README.md
```
Expected: `1`

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim && git add README.md && git commit -m "docs: document Python-in-Docker debug setup

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: Clean-env verification

**Files:** none (verification only).

**Interfaces:**
- Consumes: committed state of Tasks 1–3.

- [ ] **Step 1: Restore into an isolated NVIM_APPNAME and verify DAP plugins install + load**

Run:
```bash
rm -rf ~/.config/nvim-test ~/.local/share/nvim-test ~/.local/state/nvim-test ~/.cache/nvim-test
git clone -q ~/.config/nvim ~/.config/nvim-test
NVIM_APPNAME=nvim-test nvim --headless "+Lazy! restore" +qa 2>&1 | tail -2
NVIM_APPNAME=nvim-test nvim --headless "+lua local a=pcall(require,'dap'); local b=pcall(require,'dapui'); local n=#require('dap').configurations.python; io.stderr:write('dap='..tostring(a)..' dapui='..tostring(b)..' pycfg='..n..'\n')" +qa 2>&1 | grep "dap="
```
Expected: `Lazy! restore` completes clean; final line `dap=true dapui=true pycfg=1`.

- [ ] **Step 2: Confirm the three plugins match the lockfile in the isolated env**

Run:
```bash
for p in nvim-dap nvim-dap-ui nvim-nio; do
  d=~/.local/share/nvim-test/lazy/$p
  c=$(grep "\"$p\"" ~/.config/nvim-test/lazy-lock.json | grep -oE '"commit": "[a-f0-9]+"' | grep -oE '[a-f0-9]{40}')
  h=$(git -C "$d" rev-parse HEAD 2>/dev/null)
  [ "$c" = "$h" ] && echo "OK $p" || echo "DIFF $p lock=$c have=$h"
done
```
Expected: `OK nvim-dap`, `OK nvim-dap-ui`, `OK nvim-nio`.

- [ ] **Step 3: Tear down the test env**

Run:
```bash
rm -rf ~/.config/nvim-test ~/.local/share/nvim-test ~/.local/state/nvim-test ~/.cache/nvim-test
echo "removed"
```
Expected: `removed`. No commit (verification only).

---

## Self-Review

**Spec coverage:**
- Plugins (nvim-dap, nvim-dap-ui, nvim-nio), pinned → Task 1 ✓
- `after/plugin/dap.lua` adapter + attach config + path mapping + dap-ui + signs → Task 2 ✓
- Keymaps table → Task 2 ✓
- Container-side README docs → Task 3 ✓
- Determinism / clean-env verification → Task 4 ✓
- Non-goals (no codelldb, no nvim-dap-python, no Mason, attach-only) → respected; nothing added ✓

**Placeholder scan:** No TBD/TODO; all code and commands are concrete.

**Type consistency:** `dap.adapters.python` and `dap.configurations.python` referenced consistently across Tasks 2 and 4; configuration name string identical in Task 2, Task 3, Task 4.

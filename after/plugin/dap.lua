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

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "stylua", "pyright", "zls", "rust_analyzer", "lua_ls" },
	automatic_installation = true,
	automatic_enable = true,
})

local capabilities = require("blink.cmp").get_lsp_capabilities()

--
-- Lua
--
vim.lsp.config("lua_ls", {
	capabilities = vim.tbl_deep_extend("force", {}, capabilities, {}),
})

--
-- RUST
--
vim.lsp.config("rust_analyzer", {
	on_attach = on_attach,
	capabilities = vim.tbl_deep_extend("force", {}, capabilities, {}),
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	single_file_support = true,
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = false,
			},
		},
	},
	before_init = function(init_params, config)
		-- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
		if config.settings and config.settings["rust-analyzer"] then
			init_params.initializationOptions = config.settings["rust-analyzer"]
		end
	end,
})

--
-- ZIG
--
vim.lsp.config("zls", {
	capabilities = vim.tbl_deep_extend("force", {}, capabilities, {}),
	cmd = { "zls" },
	filetypes = { "zig", "zir" },
	root_markers = { "build.zig", ".git" },
	settings = {
		zls = {
			semantic_tokens = "partial",
			warn_style = true,
		},
	},
})

--
-- PYTHON
--
local function get_python_path(workspace)
	if vim.env.VIRTUAL_ENV then
		return vim.env.VIRTUAL_ENV .. "/bin/python"
	end

	local paths = { "venv", ".venv", "env", ".env" }
	for _, v in ipairs(paths) do
		local python_path = workspace .. "/" .. v .. "/bin/python"
		if vim.fn.filereadable(python_path) == 1 then
			return python_path
		end
	end

	local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info -p 2>/dev/null"))
	if vim.v.shell_error == 0 and poetry_venv ~= "" then
		return poetry_venv .. "/bin/python"
	end
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end
vim.lsp.config("pyright", {
	capabilities = vim.tbl_deep_extend("force", {}, capabilities, {}),
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		python = {
			pythonPath = get_python_path(vim.fn.getcwd()),
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
				typeCheckingMode = "off",
			},
		},
		pyright = {
			disableOrganizeImports = false,
		},
	},
})

--
-- lspAttach - start
--
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- go to lib declaration
		map("gd", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- run action
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

		-- rename declaration
		map("rn", vim.lsp.buf.rename, "[R]e[n]ame")

		-- open popup with lib doc
		--		map("K", vim.lsp.buf.hover, "Hover")

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
		end
	end,
})

local utils = require("ljesparis.utils")

utils.require("conform").setup({
	-- Map of filetype to formatters
	formatters_by_ft = {
		lua = { "stylua" },

		-- format rust
		rust = { "rustfmt", lsp_format = "fallback" },

		-- use default formatting for zig
		zig = { lsp_format = "fallback" },

		-- format python
		python = function(bufnr)
			if require("conform").get_formatter_info("ruff_format", bufnr).available then
				return { "ruff_format" }
			else
				return { "isort", "black" }
			end
		end,
		-- Use the "*" filetype to run formatters on all filetypes.
		["*"] = { "codespell" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 200,
	},
	format_after_save = {
		lsp_format = "fallback",
	},
	log_level = vim.log.levels.ERROR,
	notify_on_error = true,
	notify_no_formatters = true,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		utils.require("conform").format({ bufnr = args.buf })
	end,
})

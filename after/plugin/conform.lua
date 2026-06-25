local conform = require("conform")
conform.setup({
	-- Map of filetype to formatters
	formatters_by_ft = {
		lua = { "stylua" },

		-- format rust
		rust = { "rustfmt", lsp_format = "fallback" },

		-- use default formatting for zig
		zig = { lsp_format = "fallback" },

		-- format python with whatever the project provides (venv-local).
		-- Skip silently when none are installed instead of erroring on save.
		python = function(bufnr)
			if conform.get_formatter_info("ruff_format", bufnr).available then
				return { "ruff_format" }
			elseif
				conform.get_formatter_info("isort", bufnr).available
				and conform.get_formatter_info("black", bufnr).available
			then
				return { "isort", "black" }
			end
			return {}
		end,
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 200,
	},
	log_level = vim.log.levels.ERROR,
	notify_on_error = true,
	notify_no_formatters = false,
})


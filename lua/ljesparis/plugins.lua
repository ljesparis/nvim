-- Bootstrap lazy.nvim (clones itself on a fresh machine)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup lives in after/plugin/*.lua, so specs stay config-free here.
require("lazy").setup({
	spec = {
		-- statusline
		{ "nvim-mini/mini.statusline", branch = "stable" },

		-- Detect tabstop and shiftwidth automatically
		{ "NMAC427/guess-indent.nvim" },

		-- treesitter (pin master: the default `main` branch is the rewrite
		-- that removes nvim-treesitter.configs, which treesitter.lua uses)
		{ "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate" },

		-- git
		{ "lewis6991/gitsigns.nvim" },

		-- finder
		{ "ibhagwan/fzf-lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

		-- formatting
		{ "stevearc/conform.nvim" },

		-- lsp managers
		{ "mason-org/mason.nvim" },
		{ "mason-org/mason-lspconfig.nvim" },

		-- autocomplete (prebuilt rust binary auto-downloaded for the pinned tag)
		{
			"saghen/blink.cmp",
			tag = "v1.10.2",
			dependencies = { "rafamadriz/friendly-snippets" },
		},

		-- colorschemes
		{ "tahayvr/matteblack.nvim", priority = 1000 },
		{ "folke/tokyonight.nvim", priority = 1000 },
	},
	-- Commit lazy-lock.json (default: stdpath config) for reproducible installs.
	install = { missing = true },
	-- No background update checks: pins stay put until you run :Lazy sync.
	checker = { enabled = false },
	change_detection = { notify = false },
})

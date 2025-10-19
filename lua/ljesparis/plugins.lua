require("packer").startup(function(use)
	-- Package manager
	use("wbthomason/packer.nvim")

	-- statusline
	use({
		"nvim-mini/mini.statusline",
		branch = "stable",
	})

	-- Detect tabstop and shiftwidth automatically
	use("NMAC427/guess-indent.nvim")

	--use 'nvim-tree/nvim-web-devicons'
	use("nvim-treesitter/nvim-treesitter")

	-- git
	use("lewis6991/gitsigns.nvim")

	-- finder
	use({
		"ibhagwan/fzf-lua",
		requires = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	})

	-- formatting
	use("stevearc/conform.nvim")

	-- lsp managers
	use("mason-org/mason.nvim")
	use("mason-org/mason-lspconfig.nvim")

	-- autocomplete
	use({
		"saghen/blink.cmp",
		requires = {
			{ "rafamadriz/friendly-snippets" },
		},
		--tag = "v1.7.0",
		run = "cargo +nightly build --release",
	})

	if vim.loop.os_uname().sysname == "Linux" then
		--colorscheme (only in linux until i found out this theme for macos)
		use({
			"tahayvr/matteblack.nvim",
			priority = 1000,
		})

		use({
			"folke/tokyonight.nvim",
			priority = 1000,
		})
	else
		vim.cmd.colorscheme("unokai")
	end
end)

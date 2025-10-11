require("packer").startup(function(use)
	-- Package manager
	use("wbthomason/packer.nvim")

	-- Detect tabstop and shiftwidth automatically
	use("NMAC427/guess-indent.nvim")

	--use 'nvim-tree/nvim-web-devicons'
	use("nvim-treesitter/nvim-treesitter")

	-- git
	use("lewis6991/gitsigns.nvim")

	-- finder
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				run = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
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
end)

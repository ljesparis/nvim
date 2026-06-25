require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"zig",
		"bash",
		"markdown",
		"markdown_inline",
		"lua",
		"python",
		"typescript",
		"rust",
	},

	auto_install = true,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = { "python" },
	},
	indent = { enable = true, disable = { "python" } },
})

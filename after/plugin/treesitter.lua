require("nvim-treesitter.configs").setup({
	build = ":TSUpdate",
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
		assitional_vim_regex_hightlighting = { "python" },
	},
	indent = { enable = true, disable = { "python" } },
})

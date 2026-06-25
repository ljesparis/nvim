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

	-- Deterministic: only the parsers listed above (built at install via
	-- :TSUpdate). No silent on-the-fly installs that need a compiler present.
	auto_install = false,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = { "python" },
	},
	indent = { enable = true, disable = { "python" } },
})

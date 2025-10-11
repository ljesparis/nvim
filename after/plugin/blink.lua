require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	keymap = { preset = "default" },
	signature = { enabled = true },
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = {
			auto_show = false,
		},
		trigger = {
			show_on_keyboard = true,
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})

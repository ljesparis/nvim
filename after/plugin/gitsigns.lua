require("gitsigns").setup({
	current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
	current_line_blame = true,
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},

	on_attach = function(bfnr)
		local gitsigns = require("gitsigns")
		vim.keymap.set("n", "gb", function()
			gitsigns.blame_line({ full = true })
		end, { buffer = bfnr })
	end,
})

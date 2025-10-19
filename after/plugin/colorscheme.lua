local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
local colorscheme_to_load = nil

if vim.fn.filereadable(theme_file) == 1 then
	local ok, theme_plugins = pcall(dofile, theme_file)
	if ok and type(theme_plugins) == "table" then
		for _, plugin in ipairs(theme_plugins) do
			if
				type(plugin) == "table"
				and plugin[1] == "LazyVim/LazyVim"
				and plugin.opts
				and plugin.opts.colorscheme
			then
				colorscheme_to_load = plugin.opts.colorscheme
				break
			end
		end
	end
end

if colorscheme_to_load then
	vim.cmd.colorscheme(colorscheme_to_load)
else
	vim.cmd.colorscheme("unokai")
end

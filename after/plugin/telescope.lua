local R = require("ljesparis.utils")

local tls_builtin = R.require('telescope.builtin');
local tls = R.require('telescope');

local T = {};
T.find_dotfiles = function()
    tls_builtin.find_files({
        cwd = "~/.config/nvim/",
    })
end

T.find_files = function()
    tls_builtin.find_files({
        file_ignore_patterns = {
            "target/*",
            "node%_modules/*",
            "build/*",
            "dist/*",
        }
    })
end

tls.setup({})
vim.keymap.set('n', '<leader>fdt', T.find_dotfiles, {}) -- List dotfiles
vim.keymap.set('n', '<leader>ff', T.find_files, {}) -- List project files
vim.keymap.set('n', '<leader>fb', tls_builtin.buffers, {}) -- List current opened
vim.keymap.set('n', '<leader>fh', tls_builtin.help_tags, {}) -- List nvim help pages
vim.keymap.set('n', '<leader>fvm', tls_builtin.vim_options, {}) -- List nvim options
vim.keymap.set('n', '<leader>fmm', tls_builtin.man_pages, {}) -- It's kinda obvious.
vim.keymap.set('n', '<leader>gp', function() --
    tls_builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

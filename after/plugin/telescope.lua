local importer = require("ljesparis.utils")
local tls_builtin = importer.require('telescope.builtin');
local tls = importer.require('telescope');

local T = {};

--
T.find_dotfiles = function()
    tls_builtin.find_files({
        cwd = "~/.config/nvim/",
    })
end

-- This function will search for files within the project
-- except those files found inside the listed directories.
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

--
T.find_files_with_regexp_pattern = function()
    tls_builtin.grep_string({ search = vim.fn.input("Grep > ") });
end


tls.setup({
    defaults = {
        layout_strategy = "flex",
        layout_config = {
            horizontal = { preview_cutoff = 0 }
        }
    },
    pickers = {
        colorscheme = { enable_preview = true }
    }
})

vim.keymap.set('n', '<leader>ff', T.find_files, {}) -- List project files
vim.keymap.set('n', '<leader>fg', tls_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', tls_builtin.buffers, {}) -- List current opened
vim.keymap.set('n', '<leader>fh', tls_builtin.help_tags, {}) -- List nvim help pages

vim.keymap.set('n', '<leader>ft', T.find_dotfiles, {}) -- List dotfiles
vim.keymap.set('n', '<leader>fm', tls_builtin.man_pages, {}) -- It's kinda obvious.

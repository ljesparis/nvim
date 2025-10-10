vim.g.fzf_vim = {}
vim.g.fzf_layout = { window = { width = 0.9, height =  0.9 } }

vim.keymap.set('n', '<leader>f', ':Files<CR>')
vim.keymap.set('n', '<leader>fg', ':Ag<CR>')
vim.keymap.set('n', '<leader>fb', ':Buffers<CR>')
vim.keymap.set('n', '<leader>fc', ':Commits<CR>')


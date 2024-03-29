vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":w!<CR>")

-- Move block of code down and up respectively
vim.keymap.set("v", "X", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "Z", ":m '<-2<CR>gv=gv")

-- Move between buffers 
vim.keymap.set("n", "<C-n>", ":bN<CR>")

-- close the buffer even if it has something in it
vim.keymap.set("n", "<leader>c", ":bp | bd#<CR>")

-- format code 
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "Q", ":noh<CR>")

-- exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

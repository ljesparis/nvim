vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":w!<CR>")

-- Move block of code down and up respectively
vim.keymap.set("v", "B", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "T", ":m '<-2<CR>gv=gv")

-- Move between buffers 
vim.keymap.set("n", "<A-n>", ":bN<CR>")

-- close the buffer even if it has something in it
vim.keymap.set("n", "<leader>c", ":bp | bd#<CR>")

-- format code 
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

--
vim.keymap.set("n", "Q", ":noh<CR>")


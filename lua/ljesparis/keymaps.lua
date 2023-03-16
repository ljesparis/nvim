vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":w!<CR>")

-- Move code down and up respectively
vim.keymap.set("v", "T", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "B", ":m '<-2<CR>gv=gv")

-- Move between opened buffers and close them if i want
vim.keymap.set("n", "<A-n>", ":bN<CR>")

-- close the buffer even if it has somiething in it
vim.keymap.set("n", "<leader>c", ":bp | bd#<CR>")

-- format code 
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

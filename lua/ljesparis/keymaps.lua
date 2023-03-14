vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", ":w!<CR>")

-- Move code down and up respectively
vim.keymap.set("v", "T", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "B", ":m '<-2<CR>gv=gv")

-- split vertically and split horizontally
-- navigate and close.
vim.keymap.set("n", "spv", "<C-w>v<CR>")
vim.keymap.set("n", "sph", "<C-w>s<CR>")
vim.keymap.set("n", "mtl", "<C-w>h<CR>")
vim.keymap.set("n", "mtr", "<C-w>l<CR>")
vim.keymap.set("n", "mtt", "<C-w>k<CR>")
vim.keymap.set("n", "mtb", "<C-w>j<CR>")
vim.keymap.set("n", "<leader>1", "<C-w>o<CR>")

-- Move between opened buffers and close them if i want
vim.keymap.set("n", "<A-n>", ":bN<CR>")
vim.keymap.set("n", "<leader>cb", ":bp | bd#<CR>") -- close the buffer even if it has somiething in it

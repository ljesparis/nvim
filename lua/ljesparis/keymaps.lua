vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move code down and up respectively
vim.keymap.set("v", "qq", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "ww", ":m '<-2<CR>gv=gv")

-- split vertically and split horizontally
-- navigate and close.
vim.keymap.set("n", "Sv", "<C-w>v<CR>")
vim.keymap.set("n", "Sh", "<C-w>s<CR>")
vim.keymap.set("n", "A", "<C-w>h<CR>")
vim.keymap.set("n", "D", "<C-w>l<CR>")
vim.keymap.set("n", "W", "<C-w>k<CR>")
vim.keymap.set("n", "S", "<C-w>j<CR>")
vim.keymap.set("n", "<leader>1", "<C-w>o<CR>")

-- Move between opened buffers and close them if i want
vim.keymap.set("n", "--", ":bN<CR>")
vim.keymap.set("n", "..", ":bp<CR>")
vim.keymap.set("n", ",,", ":bp | bd#<CR>") -- close the buffer even if it has somiething in it

-- Delete shit inside ", ', }, ]
vim.keymap.set("n", "<A-w>11", "di\"") -- Delete shit inside double quote
vim.keymap.set("n", "<A-w>22", "di'") -- Delete shit inside single quote
vim.keymap.set("n", "<A-w>33", "diB") -- Delete Shit inside { here }
vim.keymap.set("n", "<A-w>44", "dib") -- Delete Shit inside ( here )
vim.keymap.set("n", "<A-w>55", "di]") -- Delete Shit inside [ here ]

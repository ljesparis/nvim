local importer = require("ljesparis.utils")
-- lsp-zero v4
local lsp_zero = importer.require("lsp-zero")

vim.lsp.config("zls", {
  cmd = { "zls" },
  filetypes = { "zig", "zir" },
  root_markers = { "build.zig", ".git" },
  settings = {
    zls = {},
  },
})
vim.lsp.enable("zls")

-- format zig files
vim.api.nvim_create_autocmd('BufWritePre',{
  pattern = {"*.zig", "*.zon"},
  callback = function(ev)
    vim.lsp.buf.format()
  end
})


vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
            }
        },
        pyright = {
            disableOrganizeImports = false,
        }
    },
})
-- enable python
vim.lsp.enable("pyright")


-- global keymaps
-- it will work on each language
lsp_zero.on_attach(function(_, bufnr)
    local buffer_opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, buffer_opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, buffer_opts)

    vim.keymap.set("n", "<leader>od", vim.diagnostic.open_float, buffer_opts)
    vim.keymap.set("n", "<c-n>", vim.diagnostic.goto_next, buffer_opts)
    vim.keymap.set("n", "<c-p>", vim.diagnostic.goto_prev, buffer_opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, buffer_opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.references, buffer_opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, buffer_opts)
end)

-- autocomplete
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})


local importer = require("ljesparis.utils")
local lsp = importer.require('lsp-zero')

lsp.preset('recommended')
lsp.ensure_installed({
    'rust_analyzer',
    'tsserver',
    'eslint'
})

lsp.nvim_workspace() -- configure lua for neovim

-- don't initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.skip_server_setup({ 'rust_analyzer' })
lsp.setup()
vim.diagnostic.config({
    virtual_text = true,
})

-- Configure LSP through rust-tools.nvim plugin.
-- rust-tools will configure and enable certain LSP features for us.
-- See https://github.com/simrat39/rust-tools.nvim#configuration
local opts = {
    tools = {
        runnables = {
            use_telescope = true,
        },
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = lsp.build_options('rust_analyzer', {
        single_file_support = false,
        cargo = {
            buildScripts = {
                enable = true,
            },
        },
        on_attach = function(_, _)
            -- attach something with an specific buffer
        end
    }),
}
require("rust-tools").setup(opts)

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
})

lsp.on_attach(function(_, bufnr)
    local buffer_opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, buffer_opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, buffer_opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, buffer_opts)
    vim.keymap.set("n", "<leader>od", function() vim.diagnostic.open_float() end, buffer_opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, buffer_opts) -- go to next error, info or whatever
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, buffer_opts) -- go to prev error, info or whatever
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, buffer_opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, buffer_opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, buffer_opts) -- rename function, variable or whatever
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, buffer_opts)
end)

-- auto command that will format rust files
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.lsp.buf.format(nil, 100)
    end,
})

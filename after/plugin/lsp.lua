local importer = require("ljesparis.utils")

local lsp = importer.require('lsp-zero')
local rust_tools = importer.require("rust-tools");


-- Right now i want to have everything configured,
-- so i'm going to use default lsp-zero preset.
lsp.preset('recommended');
lsp.ensure_installed({
    'rust_analyzer',
    'tsserver',
    'eslint',
});


-- Configure lua for neovim
lsp.nvim_workspace();

-- This option is used to let rust-tools do its job
lsp.skip_server_setup({ 'rust_analyzer' });
lsp.setup();

-- setup rust
local opts = {
    tools = {
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },

        hover_actions = {
            auto_focus = true
        },
    },
    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = lsp.build_options('rust_analyzer', {
        single_file_support = false,
        on_attach = function(_, bufnr)
            local buffer_opts = { buffer = bufnr, remap = false }
            -- https://github.com/simrat39/rust-tools.nvim

            vim.keymap.set("n", "<leader>,r", rust_tools.runnables.runnables, buffer_opts)
            vim.keymap.set("n", "<leader>em", rust_tools.expand_macro.expand_macro, buffer_opts)
            vim.keymap.set("n", "<leader>K", rust_tools.hover_actions.hover_actions, buffer_opts)
        end
    }),
}
rust_tools.setup(opts);


lsp.on_attach(function(_, bufnr)
    local buffer_opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, buffer_opts)

    -- show popup with object information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, buffer_opts)

    --
    vim.keymap.set("n", "<leader>od", vim.diagnostic.open_float, buffer_opts)

    -- go to next error, info or whatever
    vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, buffer_opts)

    -- go to prev error, info or whatever
    vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, buffer_opts)

    -- execute a code action
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, buffer_opts)

    -- Check variable, function, classes references
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.references, buffer_opts)

    -- rename variable, function, classes references
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, buffer_opts) -- rename function, variable or whatever
end);

vim.diagnostic.config({
    virtual_text = true
})

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
-- local cmp = require('cmp')
-- local cmp_select = { behavior = cmp.SelectBehavior.Select }
-- local cmp_mappings = lsp.defaults.cmp_mappings({
--    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
--    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
--    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
--    ["<C-Space>"] = cmp.mapping.complete(),
-- })

-- lsp.setup_nvim_cmp({
--    mapping = cmp_mappings,
-- })

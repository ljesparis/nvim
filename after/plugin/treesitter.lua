local importer = require("ljesparis.utils");
local treesitter_configs = importer.require("nvim-treesitter.configs");


treesitter_configs.setup({
    ensure_installed = {
        "help",
        "c",
        "javascript",
        "lua",
        "python",
        "typescript",
        "rust"
    },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        assitional_vim_regex_hightlighting = false,
    },
    indent = { enable = true, disable = { "python", } },
})

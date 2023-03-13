local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup({
    ensure_installed = { "help", "c", "javascript", "lua", "python", "typescript", "rust" },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        assitional_vim_regex_hightlighting = false,
    },
    indent = { enable = true, disable = { "python", } },
})

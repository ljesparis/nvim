local importer = require("ljesparis.utils")
-- lsp-zero v4
local lsp_zero = importer.require("lsp-zero")

vim.lsp.config("zls", {
    cmd = { "zls" },
    filetypes = { "zig", "zir" },
    root_markers = { "build.zig", ".git" },
    settings = {
        zls = {
            semantic_tokens = "partial",
            warn_style = true
        },
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

-- find python interpreter
local function get_python_path(workspace)
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end

  local paths = { "venv", ".venv", "env", ".env" }
  for _, v in ipairs(paths) do
    local python_path = workspace .. "/" .. v .. "/bin/python"
    if vim.fn.filereadable(python_path) == 1 then
      return python_path
    end
  end

  local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info -p 2>/dev/null"))
  if vim.v.shell_error == 0 and poetry_venv ~= "" then
    return poetry_venv .. "/bin/python"
  end
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    settings = {
        python = {
            analysis = {
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                    reportUnusedVariable = "warning",
                },
                typeCheckingMode = "off", -- Set type-checking mode to off
                diagnosticMode = "off",
            }
        },
        pyright = {
            disableOrganizeImports = false,
        }
    },
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path(vim.fn.getcwd())
    end
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


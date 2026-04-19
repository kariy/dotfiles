set number

lua <<EOF
require("strudel").setup()

local strudel = require("strudel")
vim.keymap.set("n", "<leader>sl", strudel.launch,     { desc = "Launch Strudel" })
vim.keymap.set("n", "<leader>sq", strudel.quit,       { desc = "Quit Strudel" })
vim.keymap.set("n", "<leader>st", strudel.toggle,     { desc = "Strudel toggle play/stop" })
vim.keymap.set("n", "<leader>su", strudel.update,     { desc = "Strudel update" })
vim.keymap.set("n", "<leader>ss", strudel.stop,       { desc = "Strudel stop" })
vim.keymap.set("n", "<leader>sb", strudel.set_buffer, { desc = "Strudel set buffer" })
vim.keymap.set("n", "<leader>sx", strudel.execute,    { desc = "Strudel set buffer + update" })

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})
vim.lsp.enable("ts_ls")

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.str", "*.std" },
  callback = function() vim.bo.filetype = "strudel" end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "strudel",
  callback = function() vim.bo.syntax = "javascript" end,
})
vim.lsp.config("strudel_ls", {
  cmd = { vim.fn.expand("~/Projects/strudel-language-server/dist/server.cjs"), "--stdio" },
  filetypes = { "strudel" },
  root_markers = { "package.json", ".git" },
})
vim.lsp.enable("strudel_ls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover,      opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("i", "<C-Space>",  vim.lsp.completion.get,  opts)
  end,
})
EOF

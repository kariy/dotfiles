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
EOF

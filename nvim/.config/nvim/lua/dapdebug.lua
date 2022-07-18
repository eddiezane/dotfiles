local dap, dapui = require("dap"), require("dapui")

require('nvim-dap-virtual-text').setup()
require('dap-go').setup()
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<S-F9>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<C-F9>", ":lua require'dap'.terminate()<CR>")
vim.keymap.set("n", "<F8>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<S-F8>", ":lua require'dap'.step_back()<CR>")
vim.keymap.set("n", "<F7>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<S-F7>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set("n", "<leader>bc", ":lua require'dap'.clear_breakpoints()<CR>")
vim.keymap.set("n", "<leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")
vim.keymap.set("n", "<leader>dt", ":lua require'dap-go'.debug_test()<CR>")

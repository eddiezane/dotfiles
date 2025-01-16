return {
  "FabijanZulj/blame.nvim",
  config = function()
    require("blame").setup()
    vim.keymap.set("n", "<leader>gB", "<cmd>BlameToggle<cr>")
  end,
}

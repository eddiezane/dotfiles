---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  config = function(plugin, opts)
    opts.defaults.path_display = { filename_first = { reverse_directories = true } }
    require "astronvim.plugins.configs.telescope"(plugin, opts)
  end,
}

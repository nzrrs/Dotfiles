return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      size = 15,
      open_mapping = [[<C-\>]],
      direction = 'float',
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
    }
  end,
}

return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    {
      '<leader>y',
      '<cmd>Yazi<CR>',
      desc = 'Open Yazi',
    },
  },
}

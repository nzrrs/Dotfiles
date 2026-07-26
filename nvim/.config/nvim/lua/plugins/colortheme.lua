local theme = require 'theme'
local theme_utils = require 'core.theme_utils'

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'LineNr', {
      fg = '#565f89',
    })

    vim.api.nvim_set_hl(0, 'CursorLineNr', {
      fg = '#ff9e64',
      bold = true,
    })
  end,
})
return {
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'rebelot/kanagawa.nvim' },
  { 'shaunsingh/nord.nvim' },
  { 'ellisonleao/gruvbox.nvim' },
  { 'EdenEast/nightfox.nvim' },
  { 'Mofiqul/vscode.nvim' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'navarasu/onedark.nvim' },
  { 'sainnhe/everforest' },
  { 'nyoom-engineering/oxocarbon.nvim' },
  { 'projekt0n/github-nvim-theme', name = 'github-theme' },
  { 'sainnhe/sonokai' },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      if not theme_utils.apply(theme.current) then
        theme_utils.apply 'tokyonight'
        theme_utils.persist 'tokyonight'
      end
    end,
  },
}

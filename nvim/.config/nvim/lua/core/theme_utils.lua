local M = {}

local function style_ui()
  vim.api.nvim_set_hl(0, 'NeoTreeNormal', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { link = 'NormalNC' })
  vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { link = 'EndOfBuffer' })
  vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { link = 'WinSeparator' })
  vim.api.nvim_set_hl(0, 'NeoTreeFloatBorder', { link = 'FloatBorder' })
end

function M.apply(name)
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify(string.format("Failed to load colorscheme '%s': %s", name, err), vim.log.levels.ERROR)
    return false
  end

  style_ui()
  return true
end

function M.persist(name)
  local path = vim.fn.stdpath 'config' .. '/lua/theme.lua'
  local ok, err = pcall(vim.fn.writefile, {
    'return {',
    string.format('\tcurrent = %q,', name),
    '}',
  }, path)

  if not ok then
    vim.notify(string.format("Failed to save colorscheme '%s': %s", name, err), vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.apply_and_persist(name)
  if M.apply(name) then
    M.persist(name)
  end
end

return M

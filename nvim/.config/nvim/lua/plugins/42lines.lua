return {
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local group = vim.api.nvim_create_augroup('FunctionLineCounter', { clear = true })

      local ns = vim.api.nvim_create_namespace 'function_line_counter'

      local function update()
        local bufnr = vim.api.nvim_get_current_buf()

        if vim.bo[bufnr].filetype ~= 'c' then
          return
        end

        local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'c')

        if not ok then
          return
        end

        local tree = parser:parse()[1]
        if not tree then
          return
        end

        local query = vim.treesitter.query.parse('c', '(function_definition) @func')

        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

        for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
          local start_row, _, end_row = node:range()

          local count = end_row - start_row + 1

          vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, 0, {
            virt_lines = {
              {
                {
                  '  ' .. count .. ' lines',
                  'Comment',
                },
              },
            },
            virt_lines_above = true,
          })
        end
      end

      vim.api.nvim_create_autocmd({
        'BufEnter',
        'BufWritePost',
        'TextChanged',
        'TextChangedI',
      }, {
        group = group,
        callback = update,
      })
    end,
  },
}

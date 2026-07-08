return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  config = function()
    local ts_language = vim.treesitter and vim.treesitter.language
    if ts_language and ts_language.ft_to_lang == nil and type(ts_language.get_lang) == "function" then
      ts_language.ft_to_lang = ts_language.get_lang
    end

    local telescope = require("telescope")

    telescope.setup({})

    local builtin = require("telescope.builtin")
    local keymap = vim.keymap
    local uv = vim.uv or vim.loop

    local function safe_cwd()
      local cwd = uv and uv.cwd and uv.cwd() or nil
      if type(cwd) ~= "string" or cwd == "" then
        cwd = vim.fn.getcwd()
      end
      if type(cwd) ~= "string" or cwd == "" then
        cwd = vim.fn.expand("~")
      end
      return cwd
    end

    local function with_cwd(fn)
      return function()
        fn({ cwd = safe_cwd() })
      end
    end

    keymap.set("n", "<leader>ff", with_cwd(builtin.find_files), { desc = "Find Files" })
    keymap.set("n", "<leader>fg", with_cwd(builtin.live_grep), { desc = "Live Grep" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
    keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
    keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
    keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
    keymap.set("n", "<leader>fs", builtin.current_buffer_fuzzy_find, { desc = "Search Current Buffer" })
    keymap.set("n", "<leader>fw", with_cwd(builtin.grep_string), { desc = "Word Under Cursor" })
    keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
  end,
}

return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				preview = {
					treesitter = {
						enable = false,
					},
				},
			},
			pickers = {
				colorscheme = {
					enable_preview = true,
				},
			},
		})

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
		keymap.set("n", "<leader>ut", function()
			builtin.colorscheme({
				enable_preview = true,
				attach_mappings = function(prompt_bufnr)
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")

					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)

						local theme = selection.value

						vim.cmd.colorscheme(theme)
						vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
						vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

						local path = vim.fn.stdpath("config") .. "/lua/theme.lua"
						local file = io.open(path, "w")

						if file then
							file:write(string.format('return {\n\tcurrent = "%s",\n}\n', theme))
							file:close()
						end
					end)

					return true
				end,
			})
		end, { desc = "Choose Colorscheme" })
	end,
}

local CURRENT_THEME = "tokyonight" -- Change this

return {
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000 },
	{ "catppuccin/nvim", name = "catppuccin" },
	{ "rebelot/kanagawa.nvim" },
	{ "shaunsingh/nord.nvim" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "EdenEast/nightfox.nvim" },
	{ "Mofiqul/vscode.nvim" },
	{ "projekt0n/github-nvim-theme" },

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme(CURRENT_THEME)

			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end,
	},
}

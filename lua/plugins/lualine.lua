return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				-- component_separators = { left = "", right = "" },
				-- section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = {
					"encoding",
					"fileformat",
					-- "filetype",
					{
						function()
							return _G.keyboard_layout
						end,
						color = function()
							return { fg = _G.keyboard_layout == "RU" and "#ff5555" or "#50fa7b" }
						end,
						icon = { " ", align = "right" },
					},
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}

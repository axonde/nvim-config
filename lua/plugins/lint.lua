return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufWritePost", "BufReadPost" },
		config = function()
			require("lint").linters_by_ft = {
				python = { "flake8" },
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
			}

			-- Автопроверка при сохранении
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"rshkarin/mason-nvim-lint",
		dependencies = {
			"mfussenegger/nvim-lint",
			"https://github.com/williamboman/mason.nvim",
		},
		config = function()
			require("mason-nvim-lint").setup({
				ensure_installed = { "eslint_d" },
			})
		end,
	},
}

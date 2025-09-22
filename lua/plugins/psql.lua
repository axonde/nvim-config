return {
	"axonde/psql.nvim",
	enabled = false,
	config = function()
		vim.keymap.set("n", "<leader>p", psql.psql_run_file, { desc = "Execute file with psql [P]sql " })
		vim.keymap.set(
			"x",
			"<leader>p",
			'<ESC><CMD>lua require("psql").psql_run_visual()<CR>',
			{ desc = "Execute selection with [P]sql" }
		)
	end,
}

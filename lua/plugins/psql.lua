local function loadJsonFromFile(filepath)
	local file = io.open(filepath, "r")
	if not file then
		vim.notify("Не удалось открыть файл: " .. filepath, vim.log.levels.ERROR)
		return nil
	end

	local content = file:read("*a")
	io.close(file)

	local ok, decoded_json = pcall(vim.fn.json_decode, content)

	if not ok then
		vim.notify("Ошибка декодирования JSON из файла: " .. filepath, vim.log.levels.ERROR)
		return nil
	end

	return decoded_json
end

local connections = loadJsonFromFile(vim.fn.stdpath("config") .. "/keys/psql.json")

return {
	"axonde/psql.nvim",
	cmd = { "Psql", "PsqlExec", "PsqlListDBs" },
	config = function()
		require("psql").setup({
			connections = connections,
			runner_output = "split",
		})
	end,
}

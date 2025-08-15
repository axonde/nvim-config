return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
					"svelte",
					"omnisharp",
					"pyright",
					"emmet_language_server",
					"eslint",
					"ts_ls", -- Исправлено имя сервера
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/nvim-cmp",
		},
		config = function()
			-- Общие настройки LSP
			vim.diagnostic.config({
				virtual_text = true,
				update_in_insert = false,
			})

			-- Общая функция on_attach
			local on_attach = function(client, bufnr)
				-- Keymaps для всех LSP
				vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, { buffer = bufnr })
				vim.keymap.set({ "n", "v" }, "<leader>lf", function()
					vim.lsp.buf.format({ async = false })
				end, { buffer = bufnr, desc = "[L]SP [F]ormat" })
				vim.keymap.set(
					{ "n", "v" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					{ buffer = bufnr, desc = "[L]SP Code [A]ctions" }
				)
				vim.keymap.set(
					{ "n", "v" },
					"<leader>ld",
					vim.diagnostic.open_float,
					{ buffer = bufnr, desc = "[L]SP [D]iagnostics" }
				)
			end

			-- Настройка capabilities
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities()
			end

			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")

			-- Универсальный способ настройки серверов
			local servers = {
				"lua_ls",
				"clangd",
				"svelte",
				"omnisharp",
				"pyright",
				"emmet_language_server",
				"eslint",
				"ts_ls", -- Исправлено имя сервера
			}

			-- Базовые настройки для всех серверов
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end

			-- Специфичные настройки для отдельных серверов

			-- Lua
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						telemetry = { enable = false },
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					},
				},
			})

			-- Clangd
			lspconfig.clangd.setup({
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=never",
					"--query-driver=/usr/bin/clang*",
				},
				filetypes = { "c", "cpp", "h", "hpp" },
				init_options = {
					compilationDatabasePath = "build",
				},
			})

			-- ESLint
			lspconfig.eslint.setup({
				settings = {
					eslint = {
						validate = "on",
						run = "onType",
						codeAction = {
							disableRuleComment = {
								enable = true,
								location = "separateLine",
							},
							showDocumentation = {
								enable = true,
							},
						},
						experimental = {
							useFlatConfig = true,
						},
						workingDirectory = {
							mode = "auto",
						},
					},
				},
			})

			-- Svelte
			lspconfig.svelte.setup({
				on_attach = function(client, bufnr)
					on_attach(client, bufnr) -- Вызываем общую on_attach

					-- Форматирование при сохранении
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})

					-- Определение языка для Svelte
					local content = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
					local lang = "javascript" -- по умолчанию

					for _, line in ipairs(content) do
						if line:match("<script%s+lang=%s?['\"]ts") then
							lang = "typescript"
							break
						end
					end

					-- Устанавливаем переменную буфера
					vim.b[bufnr].svelte_lang = lang
				end,
			})

			-- TypeScript/JavaScript
			lspconfig.ts_ls.setup({ -- Исправлено имя сервера
				on_attach = function(client, bufnr)
					on_attach(client, bufnr) -- Общие keymaps

					-- Определяем тип файла
					local ft = vim.bo[bufnr].filetype

					-- Для JavaScript отключаем диагностику
					if ft == "javascript" or ft == "javascriptreact" or ft == "javascript.jsx" then
						client.server_capabilities.diagnosticProvider = false
					end
				end,
				root_dir = function(fname)
					return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(fname)
						or util.path.dirname(fname)
				end,
				init_options = {
					preferences = {
						includeCompletionsForModuleExports = true,
						includeCompletionsWithInsertText = true,
					},
				},
				single_file_support = true,
			})
		end,
	},
}

return {
	-- Mason: Установщик LSP серверов
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-LSP: Автоустановка серверов
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
					"ts_ls",
				},
			})
		end,
	},

	-- Настройка LSP клиента
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			vim.diagnostic.config({
				virtual_text = true,
				update_in_insert = false,
			})

			--[[ 1. on_attach ]]
			local on_attach = function(client, bufnr)
				-- Keymaps для всех LSP серверов
				vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover info" })

				vim.keymap.set({ "n", "v" }, "<leader>lf", function()
					vim.lsp.buf.format({ async = false })
				end, { buffer = bufnr, desc = "[L]SP [F]ormat" })

				vim.keymap.set(
					{ "n", "v" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					{ buffer = bufnr, desc = "LSP [C]ode [A]ctions" }
				)

				vim.keymap.set(
					{ "n", "v" },
					"<leader>ld",
					vim.diagnostic.open_float,
					{ buffer = bufnr, desc = "[L]SP [D]iagnostics" }
				)
			end

			--[[ 2. CAPABILITIES ]]
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities()
			end

			--[[ 3. НАСТРОЙКА СЕРВЕРОВ ]]

			-- Базовые серверы без спец. настроек
			local base_servers = { "omnisharp", "pyright", "emmet_language_server" }
			for _, server in ipairs(base_servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
					on_attach = on_attach,
				})
				vim.lsp.enable(server)
			end

			-- Специфичные настройки серверов

			-- Lua
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						telemetry = { enable = false },
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					},
				},
			})
			vim.lsp.enable("lua_ls")

			-- Clangd (C/C++)
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				on_attach = on_attach,
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
			vim.lsp.enable("clangd")

			-- ESLint
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					eslint = {
						validate = "on",
						codeAction = { disableRuleComment = { enable = true } },
						experimental = { useFlatConfig = true },
						workingDirectory = { mode = "auto" },
					},
				},
			})
			vim.lsp.enable("eslint")

			-- Svelte
			vim.lsp.config("svelte", {
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr) -- Общие keymaps

					-- Автоформатирование при сохранении
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})
				end,
			})
			vim.lsp.enable("svelte")

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				on_attach = on_attach,

				-- Ключевые настройки для JS!
				init_options = {
					preferences = {
						includeCompletionsForModuleExports = true,
						includeCompletionsWithInsertText = true,
						-- Отключаем проверку типов в JS файлах
						disableSuggestions = true,
					},
					-- Форсируем использование JSDoc вместо TS проверок
					plugins = {
						{
							name = "typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/typescript-language-server/node_modules/typescript-plugin",
							enableForJS = true,
							jsDocParsing = true,
							tsChecker = false, -- Выключаем проверщик типов!
						},
					},
				},
				-- Настройки для разных типов файлов
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				settings = {
					completions = {
						completeFunctionCalls = true,
					},
				},
			})
			vim.lsp.enable("ts_ls")
		end,
	},
}

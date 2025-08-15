return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require("toggleterm").setup({
            on_open = function(term)
                -- Создаем буферно-локальное отображение для <CR>
                vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<CR>", "", {
                    callback = function()
                        -- 1. Отправляем <CR> напрямую в процесс терминала
                        if term.job_id then
                            vim.api.nvim_chan_send(term.job_id, "\r")
                        end
                        -- 2. Откладываем обновление Neotree
                        vim.defer_fn(function()
                            pcall(function()
                                if package.loaded["neo-tree"] then
                                    require("neo-tree.sources.manager").refresh("filesystem")
                                end
                            end)
                        end, 50) -- Задержка 50мс для гарантии
                    end,
                    noremap = true,
                    silent = true,
                })
            end,
        })

        -- Маппинг для обычного режима
        vim.keymap.set('n', '<C-`>', "<C-[>:ToggleTerm<CR>")
        -- Маппинг для терминального режима
        vim.keymap.set('t', '<C-`>', '<cmd>ToggleTerm<CR>')
        -- Опционально: маппинг для режима вставки
        vim.keymap.set('i', '<C-`>', '<Esc><cmd>ToggleTerm<CR>')
    end
}

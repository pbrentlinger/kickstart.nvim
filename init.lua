vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

-- 1. lazy.nvim bootstrap (standard snippet from docs)
-- local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- if not vim.loop.fs_stat(lazypath) then
--     vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- -- 2. Plugins
-- require('lazy').setup({
--     {
--         'martineausimon/nvim-lilypond-suite',
--         opts = {},
--     },
--     { 'nvim-lua/plenary.nvim', lazy = true }, -- Required for blink.cmp
--     {
--         'saghen/blink.cmp',
--         dependencies = {
--             'Kaiser-Yang/blink-cmp-dictionary', -- Required for dictionary completion
--         },
--         version = '*',
--         opts = {
--             sources = {
--                 default = { 'dictionary', 'lsp', 'path', 'snippets', 'buffer' }, -- Add 'dictionary'
--                 providers = {
--                     dictionary = {
--                         module = 'blink-cmp-dictionary',
--                         name = 'Dict',
--                         min_keyword_length = 3,
--                         max_items = 8,
--                         opts = {
--                             dictionary_files = function()
--                                 if vim.bo.filetype == 'lilypond' then -- Add lilypond words to sources
--                                     return vim.fn.glob(vim.fn.expand '$LILYDICTPATH' .. '/*', true, true)
--                                 end
--                             end,
--                         },
--                     },
--                 },
--             },
--         },
--         opts_extend = { 'sources.default' },
--     },
-- }, {})
--
-- vim.diagnostic.config { -- Show diagnostics if errors
--     virtual_text = true,
--     signs = true,
--     update_in_insert = false,
--     underline = true,
-- }
-- -- 3. Recommended syntax sync (from wiki)
-- vim.api.nvim_create_autocmd('FileType', {
--     command = 'syntax sync fromstart',
--     pattern = { '*.ly', '*.ily', '*.tex', 'lilypond' },
--     vim.keymap.set('n', '<leader>a', 'Nop', { silent = true, desc = '[A] Lilypond...' }),
-- })
--
-- vim.api.nvim_create_autocmd('QuickFixCmdPost', { -- Show quickfix if errors, else close window
--     command = 'cwindow',
--     pattern = '*',
-- })
vim.cmd 'filetype on'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

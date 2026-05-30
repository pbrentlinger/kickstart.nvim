vim.cmd [[
  augroup FiletypeMappings
  autocmd!
  autocmd BufNewFile,BufRead *.v setfiletype v
  autocmd BufNewFile,BufRead *.bats setfiletype sh
]]
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    callback = function()
        vim.opt_local.list = true
        vim.opt_local.listchars:append { space = '·', tab = '» ', trail = '×', eol = '↴' }
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'asciidoctor', 'asciidoc', 'adoc' },
    callback = function()
        vim.keymap.set('x', '<leader>w', '<Nop>', {
            buffer = true,
            silent = true,
            desc = '[W]rap selection in...',
        })

        vim.keymap.set('x', '<leader>we', function()
            require('custom.my_plugins.asciidoc_macros').wrap_with_ifeval()
        end, {
            buffer = true,
            silent = true,
            desc = '[W]rap selection in if[E]val block',
        })

        vim.keymap.set('x', '<leader>wd', function()
            require('custom.my_plugins.asciidoc_macros').wrap_with_ifdef()
        end, {
            buffer = true,
            silent = true,
            desc = '[W]rap selection in if[D]ef block',
        })

        vim.keymap.set('x', '<leader>wn', function()
            require('custom.my_plugins.asciidoc_macros').wrap_with_ifndef()
        end, {
            buffer = true,
            silent = true,
            desc = '[W]rap selection in if[N]def block',
        })
    end,
})
return {}

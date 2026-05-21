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
return {}

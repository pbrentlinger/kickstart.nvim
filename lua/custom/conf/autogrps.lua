return {
  vim.cmd([[
  augroup FiletypeMappings
  autocmd!
  autocmd BufNewFile,BufRead *.v setfiletype v
  autocmd BufNewFile,BufRead *.bats setfiletype sh
]])

}

return {
  vim.cmd([[
  augroup SalesForceGroup
  autocmd!
  autocmd BufNewFile,BufRead *.cls setfiletype apex
  autocmd BufNewFile,BufRead *.apxc setfiletype apex
  autocmd BufNewFile,BufRead *.apex setfiletype apex
  autocmd BufNewFile,BufRead *.trigger setfiletype apex
  autocmd BufNewFile,BufRead *.soql setfiletype soql
  autocmd BufNewFile,BufRead *.sosl setfiletype sosl
  augroup END
]]),

  vim.cmd([[
  augroup FiletypeMappings
  autocmd!
  autocmd BufNewFile,BufRead *.v setfiletype v
]])
}

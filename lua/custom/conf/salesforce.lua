local ft = require('Comment.ft')
ft.set('apex', { '//%s', '/*%s*/' })

-- apex_comment.lua
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
        ]])
}

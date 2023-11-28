-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
-- === Settings ===
if vim.g.vscode then
    -- VSCode extension
vim.wo.relativenumber = false
else
    -- ordinary Neovim
vim.wo.relativenumber = true
end

vim.o.termguicolors = true
vim.o.t_Co = 256
vim.wo.linebreak=true
vim.wo.breakindent=true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- utility plugins
if vim.g.vscode then
    -- VSCode extension
else
    -- ordinary Neovim
  return {
    'phelipetls/vim-hugo',
    'tpope/vim-unimpaired',
    'tpope/vim-surround',
    'tpope/vim-repeat',
    'leafOfTree/vim-matchtag',
  }
end

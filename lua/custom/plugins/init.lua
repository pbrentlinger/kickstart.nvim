-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.wo.relativenumber = true
vim.o.termguicolors = true
vim.o.t_Co = 256

return {
	'phelipetls/vim-hugo',
	'tpope/vim-unimpaired',
	'tpope/vim-surround',
	'tpope/vim-repeat',
}

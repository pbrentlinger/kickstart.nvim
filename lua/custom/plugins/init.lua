-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.wo.relativenumber = true
vim.o.termguicolors = true
vim.o.t_Co = 256
vim.wo.linebreak=true
vim.wo.breakindent=true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true


-- Set the variable g:copilot_no_tab_map to true
vim.g.copilot_no_tab_map = true
-- Define the mapping for copilot to <C-l>
vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

return {
	'phelipetls/vim-hugo',
	'tpope/vim-unimpaired',
	'tpope/vim-surround',
	'tpope/vim-repeat',
	'github/copilot.vim',
	'leafOfTree/vim-matchtag',
}

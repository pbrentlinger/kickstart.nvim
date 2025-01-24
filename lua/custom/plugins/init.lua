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
  vim.wo.number = true
  vim.wo.cursorline = true
end

vim.o.termguicolors = true
-- vim.o.t_Co = 256
vim.wo.linebreak = true
vim.wo.breakindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Set local foldmethod to 'indent'
vim.api.nvim_command 'setlocal foldmethod=indent'
-- Disable folding
vim.api.nvim_command 'setlocal nofoldenable'
-- Set foldlevel to 99
vim.api.nvim_command 'setlocal foldlevel=99'
vim.api.nvim_command 'setlocal foldminlines=2'
vim.api.nvim_command 'setlocal foldnestmax=2'
vim.cmd 'command! -nargs=* -complete=help H tab help <args>'

-- load utility plugins
if vim.g.vscode then
  -- VSCode extension
else
  -- ordinary Neovim
  return {
    'phelipetls/vim-hugo', -- HUGO syntax highlighting https://github.com/phelipetls/vim-hugo
    'tpope/vim-unimpaired', -- pairs of handy bracket mappings as well as adding line above and below https://github.com/tpope/vim-unimpaired
    'tpope/vim-surround', -- quoting/parenthesizing made simple https://github.com/tpope/vim-surround
    'tpope/vim-repeat', -- enable repeating supported plugin maps with . https://github.com/tpope/vim-repeat
    'tpope/vim-abolish', -- easily search for, substitute, and abbreviate multiple variants of a word, coerce to snake case etc. https://github.com/tpope/vim-abolish
    'leafOfTree/vim-matchtag', -- highlight matching tags https://github.com/leafOfTree/vim-matchtag
    'nanotee/zoxide.vim', -- z command for faster directory navigation https://github.com/nanotee/zoxide.vim
    'mcombeau/vim-twee-sugarcube', -- tweet syntax highlighting https://github.com/mcombeau/vim-twee-sugarcube
    'tpope/vim-obsession', -- https://github.com/tpope/vim-obsession
    'mg979/vim-visual-multi', -- https://github.com/mg979/vim-visual-multi
    -- zettel plugins
    -- 'nvim-telekasten/calendar-vim',
  }
end

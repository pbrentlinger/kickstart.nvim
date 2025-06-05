-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
--
-- === Settings ===

-- When in Neovide
if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  -- vim.print(vim.g.neovide_version)
  vim.g.neovide_opacity = 0.9
  vim.g.neovide_normal_opacity = 0.9

  -- fonts
  -- Using a no ligature font since I want to see what I have typed;
  -- Font size h:14 = 14px
  vim.o.guifont = 'JetBrains Mono NL:h14'

  -- Scale factor settings
  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set('n', '<C-=>', function()
    change_scale_factor(1.1)
  end)
  vim.keymap.set('n', '<C-->', function()
    change_scale_factor(1 / 1.1)
  end)
end

-- When in VSCODE
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
vim.filetype.add {
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
}
-- load utility plugins
if vim.g.vscode then
  -- VSCode extension
else
  -- ordinary Neovim
  return {
    -- VIM motion/selection plugins
    'tpope/vim-unimpaired', -- pairs of handy bracket mappings as well as adding line above and below https://github.com/tpope/vim-unimpaired
    'tpope/vim-surround', -- quoting/parenthesizing made simple https://github.com/tpope/vim-surround
    'tpope/vim-abolish', -- easily search for, substitute, and abbreviate multiple variants of a word, coerce to snake case etc. https://github.com/tpope/vim-abolish
    'tpope/vim-repeat', -- enable repeating supported plugin maps with . https://github.com/tpope/vim-repeat
    'leafOfTree/vim-matchtag', -- highlight matching tags https://github.com/leafOfTree/vim-matchtag
    'mg979/vim-visual-multi', -- fancy cursor things https://github.com/mg979/vim-visual-multi
    -- VIM SYS plugins
    'tpope/vim-obsession', -- session management https://github.com/tpope/vim-obsession
    'nanotee/zoxide.vim', -- z command for faster directory navigation https://github.com/nanotee/zoxide.vim
    -- ===================================
    -- language plugins
    'phelipetls/vim-hugo', -- HUGO syntax highlighting https://github.com/phelipetls/vim-hugo
    'mcombeau/vim-twee-sugarcube', -- tweet syntax highlighting https://github.com/mcombeau/vim-twee-sugarcube
    -- zettel plugins
    -- 'nvim-telekasten/calendar-vim',
  }
end

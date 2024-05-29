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
vim.api.nvim_command('setlocal foldmethod=indent')
-- Disable folding
vim.api.nvim_command('setlocal nofoldenable')
-- Set foldlevel to 99
vim.api.nvim_command('setlocal foldlevel=99')
vim.api.nvim_command('setlocal foldminlines=2')
vim.api.nvim_command('setlocal foldnestmax=2')

-- load utility plugins
if vim.g.vscode then
    -- VSCode extension
else
    -- ordinary Neovim
    return {
        vim.cmd("command! -nargs=* -complete=help H tab help <args>"),
        'phelipetls/vim-hugo',         -- HUGO syntax
        'tpope/vim-unimpaired',        -- pairs of handy bracket mappings as well as adding line above and below
        'tpope/vim-surround',          -- quoting/parenthesizing made simple
        'tpope/vim-repeat',            -- enable repeating supported plugin maps with .
        'tpope/vim-abolish',           -- easily search for, substitute, and abbreviate multiple variants of a word, coerce to snake case etc.
        'leafOfTree/vim-matchtag',     -- highlight matching tags
        'nanotee/zoxide.vim',          -- z command for faster directory navigation
        -- 'jvgrootveld/telescope-zoxide', -- z command for faster directory navigation in telescope
        'mcombeau/vim-twee-sugarcube', -- tweet syntax highlighting

    }
end

if vim.g.vscode then
  -- VSCode extension not needed
else
  return {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
  }
end

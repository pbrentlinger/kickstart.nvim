return {
  'olrtg/nvim-emmet', -- https://github.com/olrtg/nvim-emmet
  config = function()
    vim.keymap.set({ 'n', 'v' }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation, { desc = '[E]mmet wrap with abbreviation' })
  end,
}

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_x = {
          {
            function()
              local status = vim.api.nvim_call_function("codeium#GetStatusString", {})
              return status
            end,
          },
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    },
    config = function(_, opts)
      require('lualine').setup(opts)
    end,
  },
}

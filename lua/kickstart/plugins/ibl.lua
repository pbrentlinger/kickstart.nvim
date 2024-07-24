-- https://github.com/lukas-reineke/indent-blankline.nvim
return {
  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = { char = '│' },
    },
    config = function()
      local highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      }

      local hooks = require 'ibl.hooks'
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#dda6aa' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#e2cfaa' })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#b1d2ed' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#ceb39a' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#a6c191' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#cea4db' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#91bcc1' })
      end)

      require('ibl').setup { indent = { highlight = highlight, char = '│' } }
    end,
  },
}

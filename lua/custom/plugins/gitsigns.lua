-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.
-- https://github.com/lewis6991/gitsigns.nvim
return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },

      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>gh', function() end, { desc = 'git [h]unk commands' })
        map('v', '<leader>ghs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[g]it [h]unk [s]tage' })
        map('v', '<leader>ghr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[g]it [r]eset [h]unk' })

        -- normal mode
        map('n', '<leader>gh', function() end, { desc = 'git [h]unk commands' })
        map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'git [h]unk [s]tage' })
        map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'git [h]unk [r]eset' })
        map('n', '<leader>ghu', gitsigns.undo_stage_hunk, { desc = 'git [h]unk [u]ndo stage' })
        map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'git [h]unk [p]review ' })

        map('n', '<leader>gbs', gitsigns.stage_buffer, { desc = 'git [b]uffer [S]tage ' })
        map('n', '<leader>gbr', gitsigns.reset_buffer, { desc = 'git [b]uffer [R]eset' })

        map('n', '<leader>gd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>gD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles

        map('n', '<leader>gl', gitsigns.blame_line, { desc = 'git b[l]ame line' })

        map('n', '<leader>gt', function() end, { desc = '[T]oggle git show...' })
        map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>gtD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
}

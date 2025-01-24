-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- DocumencopeFuzzyCommandSearch) existing key chains
      require('which-key').add {
        { '<leader>b', group = '[B]uild' }, -- automatic icon
        { '<leader>c', group = '[C]ode', icon = '' },
        { '<leader>f', group = '[F]lip Toggles' }, -- automatic icon
        { '<leader>g', group = '[G]it Hunk', mode = { 'n', 'v' }, icon = '' },
        { '<leader>l', group = '[L]sp', icon = '' },
        { '<leader>lg', group = '[L]sp [G]oto', icon = '' },
        { '<leader>r', group = '[R]efactor', icon = '' },
        { '<leader>s', group = '[S]earch', icon = '' },
        { '<leader>t', group = '[T]abs', icon = '' },
        { '<leader>x', group = 'e[X]ecute commands', icon = '' },
        -- { '<leader>z', group = '[z]ettel' },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

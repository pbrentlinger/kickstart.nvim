return {
  dir = vim.fn.stdpath 'config', -- Point to the neovim config directory
  name = 'lsptoggle',
  lazy = false,
  config = function()
    local M = {}

    -- Store LSP state per buffer
    M.stored_states = {}

    -- Function to hide/disable LSP
    function M.LspHide()
      local buf = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients { bufnr = buf }

      -- Store buffer's LSP state
      M.stored_states[buf] = {}
      for _, client in ipairs(clients) do
        table.insert(M.stored_states[buf], {
          name = client.name,
          config = client.config,
        })
        vim.lsp.stop_client(client.id)
      end

      vim.diagnostic.hide(buf)
      vim.b.lsp_enabled = false
      print 'LSP disabled'
    end

    -- Function to show/enable LSP
    function M.LspShow()
      local buf = vim.api.nvim_get_current_buf()

      -- Restore buffer's LSP state
      if M.stored_states[buf] then
        for _, client_info in ipairs(M.stored_states[buf]) do
          vim.lsp.start(client_info.config)
        end
        M.stored_states[buf] = nil
      end

      vim.diagnostic.show(buf)
      vim.b.lsp_enabled = true
      print 'LSP enabled'
    end

    -- Main toggle function
    function M.LspToggle()
      if vim.b.lsp_enabled == false then
        M.LspShow()
      else
        M.LspHide()
      end
    end

    -- Initialize buffer variable if not set
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        if vim.b.lsp_enabled == nil then
          vim.b.lsp_enabled = true
        end
      end,
    })

    -- Set up keymapping
    vim.keymap.set('n', '<leader>fl', function()
      M.LspToggle()
    end, { noremap = true, silent = true, desc = '[F]lip [L]SP Toggle' })

    -- Make the module available globally
    _G.lsptoggle = M
  end,
}

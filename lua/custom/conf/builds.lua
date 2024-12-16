-- Function to find or create a terminal buffer
local function manage_terminal(command)
  -- Check for an existing terminal buffer with an active channel
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' and vim.bo[buf].channel ~= 0 then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          vim.fn.chansend(vim.bo[buf].channel, command .. '\n')
          return
        end
      end
      -- Terminal not visible, open in a new split
      vim.cmd('vsplit')
      vim.api.nvim_set_current_buf(buf)
      vim.fn.chansend(vim.bo[buf].channel, command .. '\n')
      return
    end
  end
  -- No terminal found, create a new one
  vim.cmd.vnew()
  vim.cmd.term()
  local job_id = vim.bo.channel
  vim.fn.chansend(job_id, command .. '\n')
  vim.cmd 'normal! G'
end

-- Function to determine the file type and execute the appropriate build command
local function build_run()
  local filetype = vim.bo.filetype
  if filetype == 'odin' then
    manage_terminal('odin run .')
  else
    print('No build command configured for this file type: ' .. filetype)
  end
end

-- Function to determine the file type and execute the appropriate test command
local function test_run()
  local filetype = vim.bo.filetype
  if filetype == 'odin' then
    manage_terminal('odin test .')
  else
    print('No test command configured for this file type: ' .. filetype)
  end
end

return {
  -- Key mapping for <leader>br to run the build command
  vim.keymap.set('n', '<leader>br', build_run, { desc = 'Build and run project based on file type' }),
  vim.keymap.set('n', '<leader>bt', test_run, { desc = 'Test project based on file type' }),
}

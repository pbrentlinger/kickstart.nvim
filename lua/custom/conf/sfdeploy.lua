-- Define a custom command to deploy the current file
vim.api.nvim_create_user_command('SFDeployCurrentClass', function()
  -- Get the current file path
  local file = vim.fn.expand('%:p')

  -- Check if a terminal buffer already exists
  local term_bufnr = nil
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(bufnr, 'buftype') == 'terminal' then
      term_bufnr = bufnr
      break
    end
  end

  -- If no terminal buffer exists, create a new one in a new tab
  if not term_bufnr then
    -- Open a new terminal in a new tab
    vim.cmd('tabnew | terminal')
    term_bufnr = vim.api.nvim_get_current_buf()
    -- Set the tab name
    vim.cmd('file FileToDefOrg')
  else
    -- If a terminal buffer exists, switch to it
    -- Find the window containing the terminal buffer and switch to it
    local term_win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_bufnr then
        term_win = win
        break
      end
    end
    if term_win then
      vim.api.nvim_set_current_win(term_win)
    else
      -- If the window is not found (shouldn't happen), switch to the buffer in the current window
      vim.cmd('buffer ' .. term_bufnr)
    end
  end

  -- Send the deploy command to the terminal
  local term_channel_id = vim.b.terminal_job_id
  local deploy_command = '/home/patrick/scripts/sf-deploy.sh ' .. vim.fn.shellescape(file)
  vim.fn.chansend(term_channel_id, deploy_command .. '\n')
end, {})

return {}

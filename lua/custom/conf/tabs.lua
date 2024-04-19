function MyTabline()
  if vim.fn.tabpagenr('$') <= 1 then
    return ''
  end

  local tabline = ''
  local current_tab = vim.fn.tabpagenr()

  for t = 1, vim.fn.tabpagenr('$') do
    local tab_page = '%#TabLine#'
    if t == current_tab then
      tab_page = '%#TabLineSel#'
    end

    local tab_name = ' ' .. t .. ' '
    local win_number = vim.fn.tabpagewinnr(t)
    if win_number ~= -1 then
      local bufnr = vim.fn.tabpagebuflist(t)[win_number]
      local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
      if bufname == '' then
        bufname = '[No Name]'
      end
      tab_name = tab_name .. bufname .. ' '
    end

    tabline = tabline .. tab_page .. tab_name
  end

  return tabline .. '%#TabLineFill#%T'
end

-- Set tabline as a custom statusline
vim.o.showtabline = 1
vim.o.tabline = '%!v:lua.MyTabline()'


-- Function to close all tabs to the right of the current tab
function CloseTabsToRight()
  local current_tab = vim.fn.tabpagenr()

  for t = vim.fn.tabpagenr('$'), current_tab + 1, -1 do
    vim.cmd(t .. 'tabclose')
  end
end

-- Function to close all tabs to the left of the current tab
function CloseTabsToLeft()
  local current_tab = vim.fn.tabpagenr()

  for t = current_tab - 1, 1, -1 do
    vim.cmd(t .. 'tabclose')
  end
end

-- Function to move the current tab by n positions
function MoveTab(n)
  local current_tab = vim.fn.tabpagenr()
  local total_tabs = vim.fn.tabpagenr('$')

  -- Calculate the new tab position
  local new_tab = current_tab + n
  if new_tab < 1 then
    new_tab = 1
  elseif new_tab > total_tabs then
    new_tab = total_tabs
  end

  -- Move to the new tab
  vim.cmd(tostring(new_tab) .. 'tabmove')
end

function MoveTabWrapper(positive)
  local count = vim.v.count or 0

  if not positive then
    if count <= 0 or nil then
      count = -2                   -- default if no count is passed in, -2 so it actually moves 1 to the left
    else
      count = -math.abs(count + 1) -- this part handles the negative count and works as expected
    end
  else
    if count == 0 then
      count = 1
    end
  end

  MoveTab(count)
end

---------------------------
--- Tabpage keybindings ---
---------------------------
vim.api.nvim_set_keymap('n', '<leader>tt', ':tabnew<CR>', { noremap = true, silent = true, desc = 'New Tab' })
-- Map a key combination to invoke the CloseTabsToLeft function
vim.api.nvim_set_keymap('n', '<leader>tcl', ':lua CloseTabsToLeft()<CR>',
  { noremap = true, silent = true, desc = 'Close Tabs to the Left' })
-- Map a key combination to invoke the CloseTabsToRight function
vim.api.nvim_set_keymap('n', '<leader>tcr', ':lua CloseTabsToRight()<CR>',
  { noremap = true, silent = true, desc = 'Close Tabs to the Right' })
vim.api.nvim_set_keymap('n', '<leader>tcc', ':tabclose<CR>',
  { noremap = true, silent = true, desc = 'Close Tabs to the Right' })
-- Map to move tab positon by n where n can be a positive or negative number meaning to the right or left respectively
vim.api.nvim_set_keymap('n', '<leader>tmr', ':<C-u>lua MoveTabWrapper(true)<CR>',
  { noremap = true, silent = true, desc = 'Move Tab [n] times right' })
vim.api.nvim_set_keymap('n', '<leader>tml', ':<C-u>lua MoveTabWrapper(false)<CR>',
  { noremap = true, silent = true, desc = 'Move Tab [n] times left' })
vim.api.nvim_set_keymap('n', '<leader>to', ':tabo', { noremap = true, silent = true, desc = 'Close all other tabs' })

-- Move current tab to the right using Shift + Ctrl + PageDown
vim.api.nvim_set_keymap('n', '<S-C-PageDown>', ':tabm +1<CR>', { noremap = true, silent = true })
-- Move current tab to the left using Shift + Ctrl + PageUp
vim.api.nvim_set_keymap('n', '<S-C-PageUp>', ':tabm -1<CR>', { noremap = true, silent = true })

return {}

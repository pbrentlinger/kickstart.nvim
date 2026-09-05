-- Fade all lines except the current one, with a toggle.
-- Active only for markdown and asciidoc.

local ns = vim.api.nvim_create_namespace 'fade_current_line'
local state = { enabled = false, line_ids = {}, prev_row = nil, original_scrolloff = nil }

local function ensure_hl()
  -- Use Comment as the fade color to be colorscheme-friendly.
  if vim.fn.hlexists 'LineFade' == 0 then
    vim.api.nvim_set_hl(0, 'LineFade', { link = 'Comment' })
  end
end

local function clear_all(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  state.line_ids = {}
  state.prev_row = nil
end

local function fade_line(buf, row)
  if state.line_ids[row] then
    return
  end
  state.line_ids[row] = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    end_row = row + 1,
    end_col = 0,
    hl_group = 'LineFade',
    hl_eol = true,
    hl_mode = 'combine',
    priority = 100,
  })
end

local function unfade_line(buf, row)
  local id = state.line_ids[row]
  if id then
    pcall(vim.api.nvim_buf_del_extmark, buf, ns, id)
    state.line_ids[row] = nil
  end
end

local function set_current_line(buf, win)
  ensure_hl()
  local row = (vim.api.nvim_win_get_cursor(win)[1] or 1) - 1
  if state.prev_row ~= nil and state.prev_row ~= row then
    fade_line(buf, state.prev_row)
  end
  unfade_line(buf, row)
  state.prev_row = row
end

local function refresh(buf, win)
  if not state.enabled then
    return
  end
  ensure_hl()
  clear_all(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local row = (vim.api.nvim_win_get_cursor(win)[1] or 1) - 1
  for r = 0, line_count - 1 do
    if r ~= row then
      fade_line(buf, r)
    end
  end
  state.prev_row = row
end

local function enable(buf, win)
  if state.enabled then
    return
  end
  state.enabled = true
  -- Save original scrolloff and set to large value to center cursor
  state.original_scrolloff = vim.wo[win].scrolloff
  vim.wo[win].scrolloff = 999
  refresh(buf, win)

  -- Buffer-local autocmds for responsive updates
  local grp = vim.api.nvim_create_augroup('FadeCurrentLine_' .. buf, { clear = true })
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = grp,
    buffer = buf,
    callback = function(args)
      set_current_line(args.buf, vim.api.nvim_get_current_win())
    end,
  })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufEnter' }, {
    group = grp,
    buffer = buf,
    callback = function(args)
      refresh(args.buf, vim.api.nvim_get_current_win())
    end,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = grp,
    buffer = buf,
    callback = function(args)
      if state.enabled then
        set_current_line(args.buf, vim.api.nvim_get_current_win())
      end
    end,
  })
end

local function disable(buf, win)
  if not state.enabled then
    return
  end
  state.enabled = false
  clear_all(buf)
  -- Restore original scrolloff
  if state.original_scrolloff ~= nil and win then
    vim.wo[win].scrolloff = state.original_scrolloff
    state.original_scrolloff = nil
  end
  -- Clear this buffer’s augroup
  pcall(vim.api.nvim_del_augroup_by_name, 'FadeCurrentLine_' .. buf)
end

local function toggle(buf, win)
  if state.enabled then
    disable(buf, win)
  else
    enable(buf, win)
  end
end

-- Create the command only for markdown/asciidoc buffers
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'asciidoc' },
  callback = function(args)
    -- Buffer-local user command
    vim.api.nvim_buf_create_user_command(args.buf, 'FadeCurrentLineToggle', function()
      toggle(args.buf, vim.api.nvim_get_current_win())
    end, { desc = 'Toggle fade-all-but-current-line' })

    -- Optional: buffer-local keymap to toggle (change to your preference)
    vim.keymap.set('n', '<leader>fz', function()
      toggle(args.buf, vim.api.nvim_get_current_win())
    end, { buffer = args.buf, desc = 'Toggle fade current line' })
  end,
})

return {}

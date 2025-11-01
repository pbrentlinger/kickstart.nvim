-- Fade all lines except the current one, with a toggle.
-- Active only for markdown and asciidoc.

local ns = vim.api.nvim_create_namespace 'fade_current_line'
local state = { enabled = false, overlay_id = nil, line_id = nil }

local function ensure_hl()
  -- Use Comment as the fade color to be colorscheme-friendly.
  if vim.fn.hlexists 'LineFade' == 0 then
    vim.api.nvim_set_hl(0, 'LineFade', { link = 'Comment' })
  end
end

local function clear_all(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  state.overlay_id = nil
  state.line_id = nil
end

local function set_overlay(buf)
  ensure_hl()
  local line_count = vim.api.nvim_buf_line_count(buf)
  -- One big faded region covering entire buffer
  state.overlay_id = vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    end_row = line_count, -- end_row is exclusive
    end_col = 0,
    hl_group = 'LineFade',
    hl_eol = true,
    hl_mode = 'combine',
    priority = 100,
  })
end

local function set_current_line(buf, win)
  local row = (vim.api.nvim_win_get_cursor(win)[1] or 1) - 1
  if state.line_id then
    pcall(vim.api.nvim_buf_del_extmark, buf, ns, state.line_id)
  end
  -- Replace fade on the current line with Normal
  state.line_id = vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    end_row = row + 1,
    end_col = 0,
    hl_group = 'Normal',
    hl_eol = true,
    hl_mode = 'replace',
    priority = 200,
  })
end

local function refresh(buf, win)
  if not state.enabled then
    return
  end
  clear_all(buf)
  set_overlay(buf)
  set_current_line(buf, win)
end

local function enable(buf, win)
  if state.enabled then
    return
  end
  state.enabled = true
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

local function disable(buf)
  if not state.enabled then
    return
  end
  state.enabled = false
  clear_all(buf)
  -- Clear this buffer’s augroup
  pcall(vim.api.nvim_del_augroup_by_name, 'FadeCurrentLine_' .. buf)
end

local function toggle(buf, win)
  if state.enabled then
    disable(buf)
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

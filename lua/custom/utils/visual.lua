local M = {}

local unpack = table.unpack or unpack

local function leave_visual_mode()
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'n', true)
end

local function feedkeys_no_remap(keys)
    local term = vim.api.nvim_replace_termcodes(keys, true, false, true)
    -- 'n' = normal mode, no remap
    vim.api.nvim_feedkeys(term, 'n', false)
end

local function get_visual_line_range()
    local line_start = vim.fn.line 'v'
    local line_end = vim.fn.line '.'

    print('start line and endline: ', line_start, line_end)

    if line_start > line_end then
        line_start, line_end = line_end, line_start
    end

    return line_start, line_end
end

local function get_visual_lines(bufnr)
    bufnr = bufnr or 0
    local line_start, line_end = get_visual_line_range()
    local lines = vim.api.nvim_buf_get_lines(bufnr, line_start - 1, line_end, false)
    return line_start, line_end, lines
end

local function get_visual_selection(bufnr)
    bufnr = bufnr or 0

    local vpos = vim.fn.getpos 'v'
    local cpos = vim.fn.getpos '.'

    local vline, vcol = vpos[2], vpos[3]
    local cline, ccol = cpos[2], cpos[3]

    if vline > cline or (vline == cline and vcol > ccol) then
        vline, cline = cline, vline
        vcol, ccol = ccol, vcol
    end

    local row_start = vline - 1
    local col_start = vcol - 1
    local row_end = cline - 1
    local col_end = ccol

    local lines = vim.api.nvim_buf_get_text(bufnr, row_start, col_start, row_end, col_end, {})

    return {
        bufnr = bufnr,
        row_start = row_start,
        col_start = col_start,
        row_end = row_end,
        col_end = col_end,
        lines = lines,
    }
end

M.leave_visual_mode = leave_visual_mode
M.feedkeys_no_remap = feedkeys_no_remap
M.get_visual_line_range = get_visual_line_range
M.get_visual_lines = get_visual_lines
M.get_visual_selection = get_visual_selection

return M

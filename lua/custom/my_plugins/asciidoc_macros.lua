local M = {}

local unpack = table.unpack or unpack

local visual = require 'custom.utils.visual'

M.feedkeys_no_remap = visual.feedkeys_no_remap

local function get_visual_lines(bufnr)
    bufnr = bufnr or 0
    local line_start, line_end, lines = visual.get_visual_lines(bufnr)
    return line_start, line_end, lines
end

function M.wrap_with_ifeval()
    local bufnr = 0
    local line_start, line_end, lines = get_visual_lines(bufnr)
    if #lines == 0 then
        return
    end

    -- Ask user for variable name (default: "var")
    local var = vim.fn.input 'ifeval variable (default: var): '
    if var == nil or var == '' then
        var = 'var'
    end

    local header = ('ifeval::[{%s} == true]'):format(var)
    local footer = 'endif::[]'

    local new_lines = { header }
    vim.list_extend(new_lines, lines)
    vim.list_extend(new_lines, { footer })

    vim.api.nvim_buf_set_lines(bufnr, line_start - 1, line_end, false, new_lines)

    visual.leave_visual_mode()
end

function M.wrap_with_ifdef()
    local bufnr = 0
    local line_start, line_end, lines = get_visual_lines(bufnr)
    if #lines == 0 then
        return
    end

    -- Ask user for variable name (default: "var")
    local var = vim.fn.input 'ifdef variable (default: var): '
    if var == nil or var == '' then
        var = 'var'
    end

    local header = ('ifdef::%s[]'):format(var)
    local footer = 'endif::[]'

    local new_lines = { header }
    vim.list_extend(new_lines, lines)
    vim.list_extend(new_lines, { footer })

    vim.api.nvim_buf_set_lines(bufnr, line_start - 1, line_end, false, new_lines)

    visual.leave_visual_mode()
end

function M.wrap_with_ifndef()
    local bufnr = 0
    local line_start, line_end, lines = get_visual_lines(bufnr)
    if #lines == 0 then
        return
    end

    -- Ask user for variable name (default: "var")
    local var = vim.fn.input 'if NOT def variable (default: var): '
    if var == nil or var == '' then
        var = 'var'
    end

    local header = ('ifndef::%s[]'):format(var)
    local footer = 'endif::[]'

    local new_lines = { header }
    vim.list_extend(new_lines, lines)
    vim.list_extend(new_lines, { footer })

    vim.api.nvim_buf_set_lines(bufnr, line_start - 1, line_end, false, new_lines)

    visual.leave_visual_mode()
end

function M.insert_doc_meta()
    -- going to insert the following
    -- = Title derived from the file name replacing - or _ with spaces
    -- :author: Patrick Brentlinger
    -- 1.0, today's date: Initial commit
    -- :doctype: article
    -- :experimental:
    -- :toc: left

    -- Get current buffer and filename
    local buf = vim.api.nvim_get_current_buf()
    local full_path = vim.api.nvim_buf_get_name(buf)

    -- Extract filename without extension
    -- :t  -> tail (filename)
    -- :r  -> root (strip extension)
    local base_name = vim.fn.fnamemodify(full_path, ':t:r')

    if base_name == nil or base_name == '' then
        base_name = 'Untitled'
    end

    -- Replace - and _ with spaces
    local title = base_name:gsub('[-_]', ' ')

    -- Title Case: capitalize first letter of each word
    title = title:gsub('(%S)(%S*)', function(first, rest)
        return first:upper() .. rest:lower()
    end)

    -- Date in YYYY-MM-DD format
    local date = os.date '%Y-%m-%d'

    -- Build header lines
    local header = {
        '= ' .. title,
        ':author: Patrick Brentlinger',
        '1.0, ' .. date .. ': Initial commit',
        ':doctype: article',
        ':experimental:',
        ':icons: font',
        ':toc: left',
        '', -- blank line after header
    }

    -- Insert at top of file (before current first line)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, header)
end

local function split_headers(input)
    local headers = {}
    for header in input:gmatch '[^,]+' do
        header = vim.trim(header)
        if header ~= '' then
            table.insert(headers, header)
        end
    end
    return headers
end

function M.insert_table()
    local headers = split_headers(vim.fn.input 'Column headers (comma-separated): ')
    if #headers == 0 then
        vim.notify('At least one column header is required', vim.log.levels.WARN)
        return
    end

    local body_rows = tonumber(vim.fn.input('Body rows (default: 1): ', '1'))
    if not body_rows or body_rows < 0 or body_rows % 1 ~= 0 then
        vim.notify('Body rows must be a non-negative integer', vim.log.levels.WARN)
        return
    end

    local caption = vim.trim(vim.fn.input 'Caption (optional): ')
    local include_header = vim.fn.input('Use header row? [Y/n]: ', 'y'):lower() ~= 'n'
    local widths = vim.trim(vim.fn.input 'Column widths (optional, e.g. 1,2,1): ')
    local extra_attributes = vim.trim(vim.fn.input 'Additional attributes (optional): ')
    local attributes = {}

    if widths ~= '' then
        table.insert(attributes, ('cols="%s"'):format(widths))
    end
    if include_header then
        table.insert(attributes, 'options="header"')
    end
    if extra_attributes ~= '' then
        table.insert(attributes, extra_attributes)
    end

    local lines = {}
    if caption ~= '' then
        table.insert(lines, '.' .. caption)
    end
    if #attributes > 0 then
        table.insert(lines, '[' .. table.concat(attributes, ',') .. ']')
    end
    table.insert(lines, '|===')

    if include_header then
        for _, header in ipairs(headers) do
            table.insert(lines, '| ' .. header)
        end
        table.insert(lines, '')
    end

    local first_body_line
    for row = 1, body_rows do
        table.insert(lines, ('// Row %d'):format(row))
        first_body_line = first_body_line or #lines + 1
        for _ = 1, #headers do
            table.insert(lines, '| ')
        end
        if row < body_rows then
            table.insert(lines, '')
        end
    end

    table.insert(lines, '|===')

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(bufnr, cursor_row, cursor_row, false, lines)
    if body_rows > 0 then
        vim.api.nvim_win_set_cursor(0, { cursor_row + first_body_line, 2 })
        vim.cmd 'startinsert'
    end
end

-- Toggle 'true' <-> 'false' at the current word.
-- If not on a bool, insert `default_bool` at cursor.
local function toggle_bool_under_cursor()
    local bufnr = 0
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
    if line == '' then
        return false
    end

    local cword = vim.fn.expand '<cword>'
    if cword ~= 'true' and cword ~= 'false' then
        return false
    end

    -- Find this occurrence (prefer around cursor)
    local s, e = line:find(cword, col + 1, true)
    if not s then
        s, e = line:find(cword, 1, true)
    end
    if not s then
        return false
    end

    local new_val = (cword == 'true') and 'false' or 'true'
    vim.api.nvim_buf_set_text(bufnr, row, s - 1, row, e, { new_val })
    return true
end

M.toggle_bool_under_cursor = toggle_bool_under_cursor

return M

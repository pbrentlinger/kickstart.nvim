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

local function display_width(s)
    return vim.fn.strdisplaywidth(s)
end

local function pad_to_width(s, width)
    local w = display_width(s)
    if w < width then
        return s .. string.rep(' ', width - w)
    end
    return s
end

local function parse_row_line(line)
    -- Parse one or more table cells from a line, preserving optional cell
    -- prefixes such as `a|`, `l|`, `.2+|`, `2*|`, `^|`, etc.
    -- Returns a list of { prefix, content } tables, or nil if not a cell line.
    local specifier = '[0-9a-zA-Z.<^>+*]*'
    local cells = {}
    local pos = 1
    local len = #line
    while pos <= len do
        local s, e, prefix = line:find('^%s*(' .. specifier .. ')|', pos)
        if not s then
            break
        end
        pos = e + 1
        -- Content runs until the next cell boundary (whitespace + prefix + |).
        local ns = line:find('%s+(' .. specifier .. ')|', pos)
        local content
        if ns then
            content = line:sub(pos, ns - 1)
            pos = ns
        else
            content = line:sub(pos, len)
            pos = len + 1
        end
        table.insert(cells, { prefix = prefix, content = vim.trim(content) })
    end
    return #cells > 0 and cells or nil
end

local function compact_stacked_cells(lines)
    -- Parse stacked single-cell lines and existing compact rows into rows.
    local items = {}
    local pending = {}
    local pending_indent = ''

    local function flush_pending()
        if #pending > 0 then
            table.insert(items, { kind = 'row', indent = pending_indent, cells = pending })
            pending = {}
        end
    end

    for _, line in ipairs(lines) do
        local indent = line:match '^(%s*)'
        local cells = parse_row_line(line)
        if not cells then
            flush_pending()
            table.insert(items, { kind = 'separator', line = line })
        elseif #cells > 1 then
            flush_pending()
            table.insert(items, { kind = 'row', indent = indent, cells = cells })
        else
            if #pending == 0 then
                pending_indent = indent
            end
            table.insert(pending, cells[1])
        end
    end
    flush_pending()

    -- Compute per-column display widths per prefix signature so rows with the
    -- same cell prefixes align with each other (e.g. header rows vs. `a|` body rows).
    local function signature(cells)
        local parts = {}
        for _, cell in ipairs(cells) do
            table.insert(parts, cell.prefix)
        end
        return table.concat(parts, '\0')
    end

    local widths_by_sig = {}
    for _, item in ipairs(items) do
        if item.kind == 'row' then
            local sig = signature(item.cells)
            local widths = widths_by_sig[sig] or {}
            for col, cell in ipairs(item.cells) do
                widths[col] = math.max(widths[col] or 0, display_width(cell.content))
            end
            widths_by_sig[sig] = widths
        end
    end

    -- Rebuild as aligned horizontal rows, dropping blank lines between rows.
    local compacted = {}
    local in_row_group = false
    for _, item in ipairs(items) do
        if item.kind == 'row' then
            in_row_group = true
            local widths = widths_by_sig[signature(item.cells)] or {}
            local row = item.indent
            for col, cell in ipairs(item.cells) do
                if col > 1 then
                    row = row .. ' '
                end
                row = row .. cell.prefix .. '| ' .. pad_to_width(cell.content, widths[col])
            end
            row = row:gsub('%s+$', '')
            table.insert(compacted, row)
        else
            local blank = vim.trim(item.line) == ''
            if in_row_group and blank then
                -- Skip blank spacing between horizontal rows.
            else
                table.insert(compacted, item.line)
                if not blank then
                    in_row_group = false
                end
            end
        end
    end

    return compacted
end

local function stack_compact_cells(lines)
    -- Infer the number of columns from any multi-cell row so we can group
    -- stacked single-cell lines into proper rows.
    local num_cols = 1
    for _, line in ipairs(lines) do
        local cells = parse_row_line(line)
        if cells and #cells > num_cols then
            num_cols = #cells
        end
    end

    local stacked = {}
    local pending = {}
    local pending_indent = ''
    local needs_blank = false

    local function flush_pending()
        if #pending == 0 then
            return
        end
        if needs_blank then
            table.insert(stacked, '')
        end
        for _, cell in ipairs(pending) do
            table.insert(stacked, pending_indent .. cell.prefix .. '| ' .. cell.content)
        end
        pending = {}
        needs_blank = true
    end

    for _, line in ipairs(lines) do
        local indent = line:match '^(%s*)'
        local cells = parse_row_line(line)
        if not cells then
            flush_pending()
            table.insert(stacked, line)
            needs_blank = false
        elseif #cells > 1 then
            flush_pending()
            if needs_blank then
                table.insert(stacked, '')
            end
            for _, cell in ipairs(cells) do
                table.insert(stacked, indent .. cell.prefix .. '| ' .. cell.content)
            end
            needs_blank = true
        else
            if #pending == 0 then
                pending_indent = indent
            end
            table.insert(pending, cells[1])
            if #pending == num_cols then
                flush_pending()
            end
        end
    end
    flush_pending()

    return stacked
end

function M.toggle_table_row_layout()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local delimiters = {}

    for row, line in ipairs(lines) do
        if vim.trim(line) == '|===' then
            table.insert(delimiters, row)
        end
    end

    local table_start, table_end
    for index = 1, #delimiters - 1 do
        if cursor_row >= delimiters[index] and cursor_row <= delimiters[index + 1] then
            table_start = delimiters[index]
            table_end = delimiters[index + 1]
            break
        end
    end

    if not table_start then
        vim.notify('Cursor is not inside an AsciiDoc table', vim.log.levels.WARN)
        return
    end

    local table_lines = vim.api.nvim_buf_get_lines(bufnr, table_start, table_end - 1, false)
    local has_compact_rows = vim.iter(table_lines):any(function(line)
        return line:match '^%s*[0-9a-zA-Z.<^>+*]*|.*|' ~= nil
    end)
    local formatted = has_compact_rows and stack_compact_cells(table_lines) or compact_stacked_cells(table_lines)
    vim.api.nvim_buf_set_lines(bufnr, table_start, table_end - 1, false, formatted)
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

function M.follow_include()
    local bufnr = 0
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''

    -- include::path/to/file.adoc[leveloffset=+1]
    local target = line:match('^%s*include::([^%[]+)%[.*%]%s*$')
    if not target or vim.trim(target) == '' then
        vim.notify('Cursor is not on an include:: directive', vim.log.levels.WARN)
        return
    end

    target = vim.trim(target)

    -- Resolve relative paths against the current buffer's directory
    if not target:match('^/') then
        local dir = vim.fn.expand '%:p:h'
        target = dir .. '/' .. target
    end

    target = vim.fn.fnamemodify(target, ':p')

    if vim.fn.filereadable(target) == 0 then
        vim.notify('Include target not readable: ' .. target, vim.log.levels.ERROR)
        return
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(target))
end

return M

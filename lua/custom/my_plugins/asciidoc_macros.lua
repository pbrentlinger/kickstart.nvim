local M = {}

local unpack = table.unpack or unpack

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

return M

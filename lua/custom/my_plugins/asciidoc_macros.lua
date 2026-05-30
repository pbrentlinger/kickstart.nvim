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
return M

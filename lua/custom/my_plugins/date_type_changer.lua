local M = {}

local visual = require 'custom.utils.visual'

-- Format the current visual selection using the `date` CLI:
--   date --date="{Selected Text}" '+%a %b %m'
-- and replace the selection with the output.
function M.format_selection_with_date()
    local bufnr = 0
    local sel = visual.get_visual_selection(bufnr)

    if not sel or not sel.lines or #sel.lines == 0 then
        vim.notify('No visual selection', vim.log.levels.WARN)
        return
    end

    -- Join the selected text into a single string for the date CLI.
    local selection = table.concat(sel.lines, ' ')

    -- Build and run the date command.
    local cmd = 'date --date=' .. vim.fn.shellescape(selection) .. " '+%a %b %d'"
    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify('date command failed: ' .. output, vim.log.levels.ERROR)
        return
    end

    -- Trim trailing whitespace/newlines from the output.
    output = output:gsub('%s+$', '')

    -- Replace the selected range with the formatted date (single line).
    vim.api.nvim_buf_set_text(bufnr, sel.row_start, sel.col_start, sel.row_end, sel.col_end, { output })

    -- Leave visual mode after replacement.
    visual.leave_visual_mode()
end

return M

-- Wrap visual selection (whole lines) in an Asciidoctor ifeval block
local function wrap_with_ifeval()
  -- Ask user for variable name (default: "var")
  local var = vim.fn.input 'ifeval variable (default: var): '
  if var == nil or var == '' then
    var = 'var'
  end

  -- Get visual selection line range using unpack not table.unpack because nvim LuaJIT doesn't have the newer method yet.
  -- lua print(unpack) and lua print(table.unpack) shows that
  local _, line_Start, _, _ = unpack(vim.fn.getpos "'<")
  local _, line_End, _, _ = unpack(vim.fn.getpos "'>")

  -- if selection was done bottom to top flip line_Start and line_End
  if line_Start > line_End then
    line_Start, line_End = line_End, line_Start
  end

  local bufnr = 0
  -- nvim_buf_get_lines end index is exclusive, so use line_End instead of line_End-1
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_Start - 1, line_End, false)
  if #lines == 0 then
    return
  end

  -- Build wrapped block
  local header = ('ifeval::[{%s} == true]'):format(var)
  local footer = 'endif::[]'

  local new_lines = { header }
  vim.list_extend(new_lines, lines)
  vim.list_extend(new_lines, { footer })

  -- Replace original lines
  vim.api.nvim_buf_set_lines(bufnr, line_Start - 1, line_End, false, new_lines)
end

_G.asciidoctor_wrap_ifeval = wrap_with_ifeval

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'asciidoctor', 'asciidoc', 'adoc' },
  callback = function()
    vim.keymap.set('x', '<leader>iw', [[:<C-U>lua _G.asciidoctor_wrap_ifeval()<CR>]], { buffer = true, silent = true, desc = 'Wrap selection in ifeval block' })
  end,
})
return {}

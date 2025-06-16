-- Function to find or create a terminal buffer
local function managed_terminal(command)
  -- Check for an existing terminal buffer with an active channel
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' and vim.bo[buf].channel ~= 0 then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          vim.fn.chansend(vim.bo[buf].channel, command .. '\n')
          vim.cmd 'normal! G'
          return
        end
      end
      -- Terminal not visible, open in a new split
      vim.cmd 'botright vsplit'
      vim.api.nvim_set_current_buf(buf)
      vim.fn.chansend(vim.bo[buf].channel, command .. '\n')
      vim.cmd 'normal! G'
      return
    end
  end
  -- No terminal found, create a new one
  vim.cmd 'botright vsplit'
  vim.cmd.term()
  local job_id = vim.bo.channel
  vim.fn.chansend(job_id, command .. '\n')
  vim.cmd 'normal! G'
end

local function setup_bin_dir()
  local bin_dir = vim.fn.expand '%:p:h' .. '/bin'
  if vim.fn.isdirectory(bin_dir) == 0 then
    vim.fn.mkdir(bin_dir, 'p')
  end
  return bin_dir
end

-- Function to determine the file type and execute the appropriate build command
local function build_run()
  local current_dir_name = vim.fn.fnamemodify(vim.fn.expand '%:p:h', ':t')
  local file_name = vim.fn.expand '%:t:r'
  local file_path = vim.fn.expand '%:p:h'
  -- Ensure the 'bin' directory exists
  local bin_dir = setup_bin_dir()
  local filetype = vim.bo.filetype

  if filetype == 'odin' then
    -- Construct the build command with output to 'bin'
    local command = 'odin run ' .. file_path .. '/. -out:' .. bin_dir .. '/' .. current_dir_name .. '_' .. file_name
    managed_terminal(command)
    vim.cmd 'normal! G'
  else
    print('No build command configured for this file type: ' .. filetype)
  end
end

local function build_run_file()
  local file_name = vim.fn.expand '%:t:r'
  local file_path = vim.fn.expand '%:p:h'
  -- Ensure the 'bin' directory exists
  local bin_dir = setup_bin_dir()
  local filetype = vim.bo.filetype
  if filetype == 'odin' then
    -- Construct the build command with output to 'bin'
    local command = 'odin run ' .. file_path .. '/' .. file_name .. '.odin -file -out:' .. bin_dir .. '/' .. file_name
    managed_terminal(command)
    vim.cmd 'normal! G'
  elseif filetype == 'asciidoc' then
    -- asciidoctor --backend=pdf --require=asciidoctor-pdf 'report-from-wester-ny.adoc'
    local pdf_command = 'asciidoctor --backend=pdf --require=asciidoctor-pdf ' .. file_path .. '/' .. file_name .. '.adoc'
    managed_terminal(pdf_command)
    vim.cmd 'normal! G'
    -- GhostScript Optimization
    local pdf_optimizer_command = 'gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile='
      .. file_name
      .. '-opt.pdf '
      .. file_name
      .. '.pdf'
    managed_terminal(pdf_optimizer_command)
    vim.cmd 'normal! G'

    local cleanup_cmd = 'rm -f ' .. file_name .. '.pdf'
    managed_terminal(cleanup_cmd)
    vim.cmd 'normal! G'

    local open_pdf_cmd = 'xdg-open ' .. file_name .. '-opt.pdf'
    managed_terminal(open_pdf_cmd)
  elseif filetype == 'c' then
    local bin_path = bin_dir .. '/' .. file_name
    local command = 'gcc -ansi ' .. file_path .. '/' .. file_name .. '.c' .. ' -o ' .. bin_dir .. '/' .. file_name
    managed_terminal(command)
    managed_terminal(bin_path)
    vim.cmd 'normal! G'
  else
    print('No build command configured for this file type: ' .. filetype)
  end
end

-- Function to determine the file type and execute the appropriate test command
local function test_run()
  local file_name = vim.fn.expand '%:t:r'
  -- Ensure the 'bin' directory exists
  local bin_dir = setup_bin_dir()
  local filetype = vim.bo.filetype
  if filetype == 'odin' then
    managed_terminal('odin test . -out:' .. bin_dir .. '/' .. file_name)
  else
    print('No test command configured for this file type: ' .. filetype)
  end
end

-- Function to retrieve the package name using LSP
local function get_package_name(callback)
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, function(err, _, result)
    if err or not result then
      print 'Error retrieving symbols'
      return
    end

    -- Find the package symbol
    local package_name = 'main' -- Default to 'main' if not found
    for _, symbol in ipairs(result) do
      if symbol.kind == 3 and symbol.name then -- 3 corresponds to 'Namespace' or similar
        package_name = symbol.name
        break
      end
    end
    callback(package_name)
  end)
end

-- Function to test a specific test case using LSP to get package name
local function test_specific_case()
  local filetype = vim.bo.filetype
  -- Yank the word under the cursor
  vim.cmd 'normal! yaw'
  local test_name = vim.fn.getreg '"'
  test_name = vim.fn.trim(test_name)

  -- Ensure the 'bin' directory exists
  local bin_dir = setup_bin_dir()

  if filetype == 'odin' then
    -- Retrieve the package name and execute the test command
    get_package_name(function(package_name)
      local command = 'odin test . -define:ODIN_TEST_NAMES=' .. package_name .. '.' .. test_name .. ' -out:' .. bin_dir .. '/' .. test_name
      managed_terminal(command)
    end)
  else
    print('No test command configured for this file type: ' .. filetype)
  end
end

-- For AsciiDoc files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'asciidoc',
  callback = function()
    vim.keymap.set('n', '<leader>bf', build_run_file, { desc = 'Make Asciidoc optimized PDF and view it' })
    vim.keymap.set('n', '<leader>bt', ':AsciiDocPreview<CR>', { desc = 'Preview Asciidoc file' })
  end,
})

-- For Odin files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'odin',
  callback = function()
    vim.keymap.set('n', '<leader>br', build_run, { desc = 'Build and run project based on file type' })
    vim.keymap.set('n', '<leader>bf', build_run_file, { desc = 'Build file as self-contained package' })
    vim.keymap.set('n', '<leader>bt', test_run, { desc = 'Test project based on file type' })
    vim.keymap.set('n', '<leader>bs', test_specific_case, { desc = 'Test specific Odin test case' })
  end,
})

-- For c files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c',
  callback = function()
    vim.keymap.set('n', '<leader>bf', build_run_file, { desc = 'build file useing gcc -ascii' })
  end,
})
return {}

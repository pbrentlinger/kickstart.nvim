local M = {}

local function run_command(cmd, callback)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  callback(result)
end

local function open_terminal(cmd)
  vim.api.nvim_command('split | terminal')
  local term_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(term_buf, 'SF_CLI')
  vim.fn.termopen(cmd)
  vim.api.nvim_set_current_win(term_buf)
end

-- -----------------------------
-- SF CLI Commands
-- -----------------------------
function M.get_current_org()
  run_command("sfdx force:org:display --json", function(output)
    local org_info = vim.fn.json_decode(output)
    vim.api.nvim_echo({ { "Current Default Org: " .. (org_info.result.username or "N/A"), "Normal" } }, false, {})
  end)
end

function M.set_default_org()
  run_command("sfdx force:org:list --json", function(output)
    local orgs = vim.fn.json_decode(output).result.nonScratchOrgs
    local org_names = {}
    for _, org in ipairs(orgs) do
      table.insert(org_names, org.alias or org.username)
    end
    require('telescope.pickers').new({}, {
      prompt_title = "Select Default Org",
      finder = require('telescope.finders').new_table { results = org_names },
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '<CR>', function()
          local selection = require('telescope.actions.state').get_selected_entry()
          require('telescope.actions').close(prompt_bufnr)
          run_command("sfdx force:config:set defaultusername=" .. selection.value, function()
            vim.api.nvim_echo({ { "Default Org set to: " .. selection.value, "Normal" } }, false, {})
          end)
        end)
        return true
      end,
    }):find()
  end)
end

function M.deploy_current_file()
  local file = vim.fn.expand("%:p")
  run_command("sfdx force:source:deploy -p " .. file, function(output)
    vim.api.nvim_echo({ { output, "Normal" } }, false, {})
  end)
end

function M.retrieve_current_file()
  local file = vim.fn.expand("%:p")
  run_command("sfdx force:source:retrieve -p " .. file, function(output)
    vim.api.nvim_echo({ { output, "Normal" } }, false, {})
  end)
end

function M.retrieve_all_files()
  local dir = vim.fn.expand("%:p:h")
  run_command("sfdx force:source:retrieve -p " .. dir, function(output)
    vim.api.nvim_echo({ { output, "Normal" } }, false, {})
  end)
end

function M.run_all_tests()
  local file = vim.fn.expand("%:p")
  run_command("sfdx force:apex:test:run --classnames " .. file, function(output)
    vim.api.nvim_echo({ { output, "Normal" } }, false, {})
  end)
end

function M.run_selected_test()
  local file = vim.fn.expand("%:p")
  run_command("sfdx force:apex:test:report --json", function(output)
    local tests = vim.fn.json_decode(output).result.tests
    local test_names = {}
    for _, test in ipairs(tests) do
      table.insert(test_names, test.FullName)
    end
    require('telescope.pickers').new({}, {
      prompt_title = "Select Test to Run",
      finder = require('telescope.finders').new_table { results = test_names },
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '<CR>', function()
          local selection = require('telescope.actions.state').get_selected_entry()
          require('telescope.actions').close(prompt_bufnr)
          run_command("sfdx force:apex:test:run --classnames " .. selection.value, function(output)
            vim.api.nvim_echo({ { output, "Normal" } }, false, {})
          end)
        end)
        return true
      end,
    }):find()
  end)
end

function M.settings()
  -- Key mappings
  vim.api.nvim_set_keymap('n', '<leader>F', '<Nop>', { noremap = true, silent = true, desc = 'SF Plugin' })
  vim.api.nvim_set_keymap('n', '<leader>Fo', '<cmd>lua require("sfplugin").get_current_org()<CR>',
    { noremap = true, silent = true, desc = 'Get current org' })
  vim.api.nvim_set_keymap('n', '<leader>Fs', '<cmd>lua require("sfplugin").set_default_org()<CR>',
    { noremap = true, silent = true, desc = 'Set default org' })
  vim.api.nvim_set_keymap('n', '<leader>Fd', '<cmd>lua require("sfplugin").deploy_current_file()<CR>',
    { noremap = true, silent = true, desc = 'Deploy current file to org' })
  vim.api.nvim_set_keymap('n', '<leader>Fr', '<cmd>lua require("sfplugin").retrieve_current_file()<CR>',
    { noremap = true, silent = true, desc = 'Retrieve current file from org' })
  vim.api.nvim_set_keymap('n', '<leader>Fa', '<cmd>lua require("sfplugin").retrieve_all_files()<CR>',
    { noremap = true, silent = true, desc = 'Retrieve all files from org' })
  vim.api.nvim_set_keymap('n', '<leader>Ft', '<cmd>lua require("sfplugin").run_all_tests()<CR>',
    { noremap = true, silent = true, desc = 'Run all tests in file' })
  vim.api.nvim_set_keymap('n', '<leader>Fts', '<cmd>lua require("sfplugin").run_selected_test()<CR>',
    { noremap = true, silent = true, desc = 'Run selected test' })
end

return M

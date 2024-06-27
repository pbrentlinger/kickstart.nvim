local M = {}

local function run_command(cmd, callback)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  callback(result)
end

SF_CLI_Buf = nil

-- Function to run shell commands in the SF_CLI buffer
local function open_terminal(cmd)
  if SF_CLI_Buf == nil or not vim.api.nvim_buf_is_valid(SF_CLI_Buf) then
    -- Create a new buffer and store the ID in SF_CLI_Buf
    SF_CLI_Buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_set_current_buf(SF_CLI_Buf)
  else
    vim.api.nvim_set_current_buf(SF_CLI_Buf)
    -- Reset the modified flag before running termopen again
    vim.api.nvim_set_option_value("modified", false, { buf = SF_CLI_Buf })
  end
  -- Run the command in SF_CLI_Buf since it is the current buffer
  vim.fn.termopen(cmd)
end


-- -----------------------------
-- SF CLI Commands
-- -----------------------------
function M.get_current_org()
  local cmd = "sfdx force:org:display --json"
  local jq_filter =
  [[ | jq -r '.result | {alias, instanceUrl, username} | to_entries | map("\(.key): \(.value)") | .[]']]
  open_terminal(cmd .. jq_filter)
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
          open_terminal("sfdx force:config:set defaultusername=" .. selection.value)
        end)
        return true
      end,
    }):find()
  end)
end

function M.deploy_current_file()
  local file = vim.fn.expand("%:p")
  open_terminal("sfdx force:source:deploy -p " .. file)
end

function M.retrieve_current_file()
  local file = vim.fn.expand("%:p")
  open_terminal("sfdx force:source:retrieve -p " .. file)
end

function M.retrieve_all_files()
  local dir = vim.fn.expand("%:p:h")
  open_terminal("sfdx force:source:retrieve -p " .. dir)
end

function M.run_all_tests()
  local file = vim.fn.expand("%:p")
  open_terminal("sfdx force:apex:test:run --classnames " .. file)
end

function M.run_selected_test()
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
          open_terminal("sfdx force:apex:test:run --classnames " .. selection.value)
        end)
        return true
      end,
    }):find()
  end)
end

function M.settings()
  local wk = require("which-key")

  -- Register the key mappings with descriptions
  wk.register({
    F = {
      name = "SF Plugin",
      o = { '<cmd>lua require("sfplugin").get_current_org()<CR>', "Get current org" },
      s = { '<cmd>lua require("sfplugin").set_default_org()<CR>', "Set default org" },
      d = { '<cmd>lua require("sfplugin").deploy_current_file()<CR>', "Deploy current file to org" },
      r = { '<cmd>lua require("sfplugin").retrieve_current_file()<CR>', "Retrieve current file from org" },
      a = { '<cmd>lua require("sfplugin").retrieve_all_files()<CR>', "Retrieve all files from org" },
      t = {
        name = "Run Tests",
        a = { '<cmd>lua require("sfplugin").run_all_tests()<CR>', "Run all tests in file" },
        s = { '<cmd>lua require("sfplugin").run_selected_test()<CR>', "Run selected test" },
      },
    },
  }, { prefix = "<leader>" })
end

return M

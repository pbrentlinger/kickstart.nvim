local M = {}

local function run_command(cmd, callback)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  callback(result)
end

SF_CLI_Buf = nil

-- Function to run shell commands in the SF_CLI buffer with an optional callback
local function open_terminal(cmd, on_exit)
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
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code, _)
      if exit_code == 0 and on_exit then
        on_exit()
      end
    end
  })
end


-- =============================
-- SF CLI Commands
-- =============================
local function query_orgs(jq_filter)
  local cmd = "sfdx force:org:display --json"
  open_terminal(cmd .. jq_filter)
end


function M.get_current_org()
  local jq_filter =
  [[ | jq -r '.result | {alias, instanceUrl, username} | to_entries | map("\(.key): \(.value)") | .[]']]
  query_orgs(jq_filter)
end

-- Function to fetch and set the default org alias global var
local function fetch_default_org()
  local jq_filter = [[ | jq -r '.result.alias']]
  local cmd = "sfdx force:org:display --json" .. jq_filter
  run_command(cmd, function(result)
    -- Trim any leading/trailing whitespace or newline characters
    local trimmed_result = result:gsub("^%s+", ""):gsub("%s+$", "")
    -- Check if the result is "null" and treat it as Lua nil
    if trimmed_result == "null" then
      Default_org = nil
    else
      -- Set the global variable
      Default_org = trimmed_result
    end
  end)
end
fetch_default_org()

-- Function to determine lualine color
local function org_color()
  if not Default_org then
    return { bg = nil }
  end
  local org = Default_org:lower()
  if org:find("prod") then
    return { bg = "#FF4B4B" } -- red
  elseif org:find("staging") then
    return { bg = "#FFD20F" } -- orange
  elseif org:find("qa") then
    return { bg = "#F9FF9A" } -- yellow
  else
    return { bg = nil }       -- default
  end
end

-- lualine setup
local function setup_lualine()
  if Default_org then
    require('lualine').setup {
      sections = {
        lualine_c = {
          {
            function()
              local filename = vim.fn.expand('%:t')
              local org_info = Default_org or 'Not Set'
              return filename .. ' | SF-Org:' .. org_info
            end,
            color = org_color,
          },
        },
      },
    }
  else
    require('lualine').setup {
      sections = {
        lualine_c = {
          { function()
            local filename = vim.fn.expand('%:t')
            return filename
          end,
          },
        },
      },
    }
  end
end
setup_lualine()

function M.set_target_org()
  run_command("sfdx force:org:list --json", function(output)
    local orgs = vim.fn.json_decode(output).result.nonScratchOrgs
    local org_names = {}
    for _, org in ipairs(orgs) do
      table.insert(org_names, org.alias or org.username)
    end

    require('telescope.pickers').new({}, {
      prompt_title = "Select Default Org - Current Org: " .. Default_org,
      finder = require('telescope.finders').new_table { results = org_names },
      sorter = require('telescope.config').values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '<CR>', function()
          local selection = require('telescope.actions.state').get_selected_entry()
          require('telescope.actions').close(prompt_bufnr)
          -- open_terminal("sfdx force:config:set defaultusername=" .. selection.value)
          open_terminal("sf config set target-org " .. selection.value, function()
            fetch_default_org()
            require('lualine').refresh()
          end)
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

function M.run_all_tests_in_file()
  local file = vim.fn.expand("%:p")
  local class_name = vim.fn.fnamemodify(file, ":t:r")
  open_terminal("sfdx force:apex:test:run --synchronous --code-coverage --class-names " .. class_name)
end

function M.run_selected_test()
  local file = vim.fn.expand("%:p")
  local tests = {}
  for line in io.lines(file) do
    if line:match("^@isTest") then
      local test_name = line:match("([a-zA-Z0-9_]+)\\(\\)* { *$")
      vim.print(test_name)
      if test_name then
        table.insert(tests, test_name)
      end
    end
  end
  require('telescope.pickers').new({}, {
    prompt_title = "Select Test to Run",
    finder = require('telescope.finders').new_table { results = tests },
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        open_terminal("sfdx force:apex:test:run --synchronous --tests " .. selection.value)
      end)
      return true
    end,
  }):find()
end

function M.settings()
  local wk = require("which-key")

  -- Register the key mappings with descriptions
  wk.register({
    F = {
      name = "SF Plugin",
      o = {
        name = "Org Commands",
        g = { '<cmd>lua require("sfplugin").get_current_org()<CR>', "(G)et current org" },
        t = { '<cmd>lua require("sfplugin").set_target_org()<CR>', "Set (t)arget org" },
        -- s = { '<cmd>lua require("sfplugin").create_scratch_org()<CR>', "Create (s)cratch org" },
      },
      d = { '<cmd>lua require("sfplugin").deploy_current_file()<CR>', "Deploy current file to org" },
      r = { '<cmd>lua require("sfplugin").retrieve_current_file()<CR>', "Retrieve current file from org" },
      a = { '<cmd>lua require("sfplugin").retrieve_all_files()<CR>', "Retrieve all files from org" },
      t = {
        name = "Run Tests",
        f = { '<cmd>lua require("sfplugin").run_all_tests_in_file()<CR>', "Run all tests in file" },
        s = { '<cmd>lua require("sfplugin").run_selected_test()<CR>', "Run selected test" },
      },
    },
  }, { prefix = "<leader>" })
end

return M

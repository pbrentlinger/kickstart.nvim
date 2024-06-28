-- local org_commands = {}
--
-- local function query_orgs(jq_filter)
--   local cmd = "sfdx force:org:display --json"
--   open_terminal(cmd .. jq_filter)
-- end
--
--
-- function org_commands.get_current_org()
--   local jq_filter =
--   [[ | jq -r '.result | {alias, instanceUrl, username} | to_entries | map("\(.key): \(.value)") | .[]']]
--   query_orgs(jq_filter)
-- end
--
-- return org_commands
local M = {}

local function sayMyName()
  print('Hrunkner')
end

function M.sayHello()
  print('Why hello there')
  sayMyName()
end

return M

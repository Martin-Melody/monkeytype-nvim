local M = {}
local config = require("monkeytype.config")
local test = require("monkeytype.test")

function M.setup()
	local keymaps = config.config.keymaps or {}

	-- Set up each keymap defined in the configuration
	for action, map in pairs(keymaps) do
		if action == "start_test" then
			vim.keymap.set(map.mode, map.lhs, test.start_test, { desc = map.desc })
		end
	end
end

return M

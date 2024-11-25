local M = {}
local config = require("monkeytype.config")
local test = require("monkeytype.test")

function M.setup()
	local keymaps = config.config.keymaps
	vim.keymap.set(keymaps.start_test.mode, keymaps.start_test.lhs, test.start_test, { desc = keymaps.start_test.desc })
end

return M

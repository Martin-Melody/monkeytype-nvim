local M = {}

-- Load other modules
local config = require("monkeytype.config")
local keymaps = require("monkeytype.keymaps")

function M.setup(user_config)
	-- Load user configuration
	config.setup(user_config)

	-- Set up keymaps
	keymaps.setup()
end

return M

local M = {}

-- Load modules
local config = require("monkeytype.config")
local keymaps = require("monkeytype.keymaps")

function M.setup(user_config)
	-- Set up configuration
	config.setup(user_config)

	-- Set up default keymaps
	keymaps.setup()
end

return M

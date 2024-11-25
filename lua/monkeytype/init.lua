local M = {}

-- Load modules
local config = require("monkeytype.config")
local test = require("monkeytype.test")

function M.setup(user_config)
	config.setup(user_config)
end

function M.start()
	test.start_test()
end

return M

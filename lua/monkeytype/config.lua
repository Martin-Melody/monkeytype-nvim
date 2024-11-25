local M = {}

M.defaults = {
	keymaps = {
		start_test = { mode = "n", lhs = "<leader>mt", desc = "Start Monkeytype Test" },
	},
	test_duration = 60,
	quotes_file = debug.getinfo(1).source:match("@?(.*/)") .. "quotes.json",
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

return M

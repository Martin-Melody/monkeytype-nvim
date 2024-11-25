local M = {}

M.defaults = {
	keymaps = {
		start_test = { mode = "n", lhs = "<leader>mt", desc = "Start Monkeytype Test" },
	},
	test_duration = 60,
	-- Path to the user quotes file
	user_quotes_file = vim.fn.expand("~/.config/nvim/monkeytype_quotes.json"),
	-- Path to the plugin's default quotes file
	default_quotes_file = debug.getinfo(1).source:match("@?(.*/)") .. "quotes.json",
}

function M.setup(user_config)
	-- Merge user-provided configuration with defaults
	M.config = vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

return M

local M = {}

M.config = {
	quotes_file = vim.fn.stdpath("data") .. "/monkeytype-nvim/quotes.json",
	test_duration = 60, -- Typing test duration in seconds
	keymaps = { -- Default keymaps
		start_test = { mode = "n", lhs = "<leader>tt", desc = "Start Typing Test" },
		show_stats = { mode = "n", lhs = "<leader>ts", desc = "Show Typing Stats" },
	},
}

-- Path to the default quotes file
M.default_quotes_file = debug.getinfo(1).source:match("@?(.*/)") .. "quotes.json"

-- Setup function
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
	M.set_keymaps()
end

-- Function to set keymaps
function M.set_keymaps()
	for action, map in pairs(M.config.keymaps) do
		if M[action] then -- Only set keymaps for existing functions
			vim.keymap.set(map.mode, map.lhs, M[action], { desc = map.desc })
		end
	end
end

function M.load_quotes()
	local quotes_file = M.config.quotes_file

	-- Check if the user's quotes file exists
	local user_quotes_file = io.open(vim.fn.expand(quotes_file), "r")
	if user_quotes_file then
		local content = user_quotes_file:read("*a")
		user_quotes_file:close()
		return vim.json.decode(content)
	end

	-- Fallback to the default quotes file
	vim.notify("User quotes file not found. Using default quotes.", vim.log.levels.WARN)
	local default_file = io.open(M.default_quotes_file, "r")
	if not default_file then
		vim.notify("Default quotes file is missing. Please reinstall the plugin.", vim.log.levels.ERROR)
		return {}
	end

	local default_content = default_file:read("*a")
	default_file:close()
	return vim.json.decode(default_content)
end

function M.start_test()
	local quotes = load_quotes()
	if #quotes == 0 then
		vim.notify("No quotes available!", vim.log.levels.ERROR)
		return
	end

	local quote = quotes[math.random(#quotes)]
	vim.cmd("new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.wo.wrap = true

	vim.api.nvim_buf_set_lines(0, 0, -1, false, { quote.text })
	vim.cmd("startinsert")

	local start_time = os.time()
	local timer = vim.loop.new_timer()
	timer:start(
		M.config.test_duration * 1000,
		0,
		vim.schedule_wrap(function()
			local input = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
			local elapsed = os.difftime(os.time(), start_time)

			local words = #vim.split(input, "%s+")
			local correct_chars = 0
			for i = 1, #quote.text do
				if quote.text:sub(i, i) == input:sub(i, i) then
					correct_chars = correct_chars + 1
				end
			end

			local wpm = math.floor(words / (elapsed / 60))
			local accuracy = math.floor((correct_chars / #quote.text) * 100)

			vim.notify(string.format("WPM: %d | Accuracy: %d%%", wpm, accuracy), vim.log.levels.INFO)
			vim.cmd("stopinsert | q!")
			timer:stop()
			timer:close()
		end)
	)
end

return M

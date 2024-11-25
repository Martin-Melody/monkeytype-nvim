-- Path to the default quotes file
M.default_quotes_file = debug.getinfo(1).source:match("@?(.*/)") .. "quotes.json"

-- Setup function
function M.setup(user_config)
	-- Deep merge user configuration with default configuration
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
	-- Set up keymaps
	M.set_keymaps()
end

-- Function to set keymaps
function M.set_keymaps()
	for action, map in pairs(M.config.keymaps) do
		if M[action] then -- Only set keymaps for existing functions
			vim.keymap.set(map.mode, map.lhs, function()
				M[action]()
			end, { desc = map.desc })
		end
	end
end

-- Function to load quotes
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

-- Function to start the typing test
function M.start_test()
	local quotes = M.load_quotes()
	if #quotes == 0 then
		vim.notify("No quotes available!", vim.log.levels.ERROR)
		return
	end

	local quote = quotes[math.random(#quotes)]
	vim.cmd("new")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "wipe"
	vim.wo.wrap = true
	vim.wo.relativenumber = false
	vim.wo.number = false

	-- Set the quote text
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { quote.text })

	-- Highlight groups
	vim.cmd("highlight TypingCorrect guifg=green gui=bold")
	vim.cmd("highlight TypingIncorrect guifg=red gui=bold")

	-- State management
	local cursor_pos = 0
	local correct_chars = 0
	local start_time = os.time()

	-- Attach a key handler to capture typing
	vim.api.nvim_buf_attach(0, false, {
		on_lines = function()
			return true
		end, -- Prevent line editing
		on_key = function(_, key)
			-- Get current character in the quote
			local expected_char = quote.text:sub(cursor_pos + 1, cursor_pos + 1)

			if key == expected_char then
				-- Correct character
				correct_chars = correct_chars + 1
				vim.api.nvim_buf_add_highlight(0, -1, "TypingCorrect", 0, cursor_pos, cursor_pos + 1)
			else
				-- Incorrect character
				vim.api.nvim_buf_add_highlight(0, -1, "TypingIncorrect", 0, cursor_pos, cursor_pos + 1)
			end

			-- Move cursor forward
			cursor_pos = cursor_pos + 1

			-- End test if all characters are typed
			if cursor_pos == #quote.text then
				local elapsed = os.difftime(os.time(), start_time)
				local wpm = math.floor((#vim.split(quote.text, "%s+") / (elapsed / 60)))
				local accuracy = math.floor((correct_chars / #quote.text) * 100)

				vim.notify(string.format("WPM: %d | Accuracy: %d%%", wpm, accuracy), vim.log.levels.INFO)
				vim.cmd("stopinsert | q!")
			end
		end,
	})

	-- Start insert mode
	vim.cmd("startinsert")
end

return M

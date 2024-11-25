local M = {}
local config = require("monkeytype.config")
local utils = require("monkeytype.utils")

-- Function to load quotes
function M.load_quotes()
	local user_file = config.config.user_quotes_file
	local default_file = config.config.default_quotes_file

	-- Check if the user's quotes file exists
	local content = utils.read_file(user_file)
	if content then
		vim.notify("Using user's quotes file: " .. user_file, vim.log.levels.INFO)
		return vim.json.decode(content)
	end

	-- Fallback to the plugin's default quotes file
	content = utils.read_file(default_file)
	if content then
		vim.notify("Using default quotes file: " .. default_file, vim.log.levels.INFO)
		return vim.json.decode(content)
	end

	vim.notify("No quotes file found! Please ensure a quotes file is available.", vim.log.levels.ERROR)
	return {}
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

	-- Set the quote as placeholder text
	local placeholder = { quote.text }
	vim.api.nvim_buf_set_lines(0, 0, -1, false, placeholder)

	-- Highlight groups
	vim.cmd("highlight TypingCorrect guifg=green gui=bold")
	vim.cmd("highlight TypingIncorrect guifg=red gui=bold")
	vim.cmd("highlight TypingPlaceholder guifg=gray gui=italic")

	-- Apply placeholder highlight
	vim.api.nvim_buf_add_highlight(0, -1, "TypingPlaceholder", 0, 0, -1)

	-- State management
	local user_input = {}
	local cursor_pos = 0
	local correct_chars = 0
	local start_time = os.time()

	-- Function to handle input
	local function handle_input(key)
		-- Get the expected character at the current position
		local expected_char = quote.text:sub(cursor_pos + 1, cursor_pos + 1)

		-- Replace the placeholder with the user's input
		if #key > 0 then
			user_input[cursor_pos + 1] = key
			vim.api.nvim_buf_set_text(0, 0, cursor_pos, 0, cursor_pos + 1, { key })
		end

		-- Highlight correct/incorrect characters
		if key == expected_char then
			correct_chars = correct_chars + 1
			vim.api.nvim_buf_add_highlight(0, -1, "TypingCorrect", 0, cursor_pos, cursor_pos + 1)
		else
			vim.api.nvim_buf_add_highlight(0, -1, "TypingIncorrect", 0, cursor_pos, cursor_pos + 1)
		end

		-- Move cursor forward
		cursor_pos = cursor_pos + 1

		-- End the test if all characters are typed
		if cursor_pos == #quote.text then
			local elapsed = os.difftime(os.time(), start_time)
			local wpm = math.floor((#vim.split(quote.text, "%s+") / (elapsed / 60)))
			local accuracy = math.floor((correct_chars / #quote.text) * 100)

			vim.notify(string.format("WPM: %d | Accuracy: %d%%", wpm, accuracy), vim.log.levels.INFO)
			vim.cmd("stopinsert | q!")
		end
	end

	-- Map all keys to handle_input in insert mode
	vim.api.nvim_create_autocmd("InsertCharPre", {
		buffer = 0,
		callback = function(args)
			handle_input(args.char)
		end,
	})

	-- Start insert mode
	vim.cmd("startinsert")
end

return M

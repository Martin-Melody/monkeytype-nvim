local M = {}
local config = require("monkeytype.config")
local utils = require("monkeytype.utils")

function M.start_test()
	-- Ensure the paths passed to load_quotes are strings
	local user_file = config.config.user_quotes_file
	local default_file = config.config.default_quotes_file

	-- Load quotes from user file or default file
	local quotes = utils.load_quotes(user_file, default_file)
	if #quotes == 0 then
		vim.notify("No quotes available!", vim.log.levels.ERROR)
		return
	end

	-- Select a random quote
	local quote = quotes[math.random(#quotes)].text

	-- Create a floating window for the typing test
	local buf = vim.api.nvim_create_buf(false, true)
	local width = vim.o.columns
	local height = vim.o.lines
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(width * 0.8),
		height = math.floor(height * 0.3),
		row = math.floor(height * 0.35),
		col = math.floor(width * 0.1),
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Display the quote in the buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { quote })

	-- State variables
	local cursor_pos = 0
	local correct_chars = 0
	local start_time = os.time()

	-- Highlights
	vim.cmd("highlight TypingCorrect guifg=green gui=bold")
	vim.cmd("highlight TypingIncorrect guifg=red gui=bold")

	-- Handle typing
	local function handle_input(key)
		local expected_char = quote:sub(cursor_pos + 1, cursor_pos + 1)

		if key == expected_char then
			correct_chars = correct_chars + 1
			vim.api.nvim_buf_add_highlight(buf, -1, "TypingCorrect", 0, cursor_pos, cursor_pos + 1)
		else
			vim.api.nvim_buf_add_highlight(buf, -1, "TypingIncorrect", 0, cursor_pos, cursor_pos + 1)
		end

		cursor_pos = cursor_pos + 1

		-- End the test when the quote is fully typed
		if cursor_pos >= #quote then
			local elapsed = os.difftime(os.time(), start_time)
			local wpm = math.floor((#vim.split(quote, "%s+") / (elapsed / 60)))
			local accuracy = math.floor((correct_chars / #quote) * 100)

			vim.api.nvim_win_close(win, true)
			vim.notify(string.format("WPM: %d | Accuracy: %d%%", wpm, accuracy), vim.log.levels.INFO)
		end
	end

	-- Attach InsertCharPre event
	vim.api.nvim_create_autocmd("InsertCharPre", {
		buffer = buf,
		callback = function(args)
			handle_input(args.char)
		end,
	})

	-- Start insert mode
	vim.cmd("startinsert")
end

return M

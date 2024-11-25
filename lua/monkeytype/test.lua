local M = {}
local config = require("monkeytype.config")
local utils = require("monkeytype.utils")

function M.load_quotes()
	local quotes_file = config.config.quotes_file

	-- Load quotes from the configured file
	local content = utils.read_file(quotes_file)
	if content then
		return vim.json.decode(content)
	else
		vim.notify("Quotes file not found. Using default quotes.", vim.log.levels.WARN)
		return {}
	end
end

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

	-- Display the quote text
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
			-- Get the current character in the quote
			local expected_char = quote.text:sub(cursor_pos + 1, cursor_pos + 1)

			if key == expected_char then
				correct_chars = correct_chars + 1
				vim.api.nvim_buf_add_highlight(0, -1, "TypingCorrect", 0, cursor_pos, cursor_pos + 1)
			else
				vim.api.nvim_buf_add_highlight(0, -1, "TypingIncorrect", 0, cursor_pos, cursor_pos + 1)
			end

			-- Move the cursor forward
			cursor_pos = cursor_pos + 1

			-- End the test if all characters are typed
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

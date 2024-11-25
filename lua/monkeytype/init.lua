local M = {}

M.config = {
	quotes_file = vim.fn.stdpath("data") .. "/monkeytype-nvim/quotes.json",
	test_duration = 60, -- Typing test duration in seconds
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

local function load_quotes()
	local file = io.open(M.config.quotes_file, "r")
	if not file then
		vim.notify("Quotes file not found!", vim.log.levels.ERROR)
		return {}
	end
	local content = file:read("*a")
	file:close()
	return vim.json.decode(content)
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

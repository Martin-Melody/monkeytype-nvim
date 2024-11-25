local M = {}

-- Function to load quotes
function M.load_quotes(user_file, default_file)
	-- Validate input file paths
	if type(user_file) ~= "string" or type(default_file) ~= "string" then
		error("Expected string file paths for load_quotes function")
	end

	-- Check if the user's file exists and is readable
	if vim.fn.filereadable(user_file) == 1 then
		local content = vim.fn.readfile(user_file)
		return vim.json.decode(table.concat(content, "\n"))
	end

	-- Check if the default file exists and is readable
	if vim.fn.filereadable(default_file) == 1 then
		local content = vim.fn.readfile(default_file)
		return vim.json.decode(table.concat(content, "\n"))
	end

	-- No valid file found
	return {}
end

return M

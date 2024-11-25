local M = {}

function M.load_quotes(user_file, default_file)
	local file_path = vim.fn.expand(user_file)
	if vim.fn.filereadable(file_path) == 1 then
		return vim.json.decode(vim.fn.readfile(file_path, true))
	end

	file_path = vim.fn.expand(default_file)
	if vim.fn.filereadable(file_path) == 1 then
		return vim.json.decode(vim.fn.readfile(file_path, true))
	end

	return {}
end

return M

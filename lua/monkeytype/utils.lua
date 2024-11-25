local M = {}

function M.read_file(path)
	local file = io.open(path, "r")
	if not file then
		print("File not found:", path) -- Debug message
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

return M

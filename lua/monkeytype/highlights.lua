local M = {}

function M.setup()
	vim.cmd("highlight TypingCorrect guifg=green gui=bold")
	vim.cmd("highlight TypingIncorrect guifg=red gui=bold")
end

return M

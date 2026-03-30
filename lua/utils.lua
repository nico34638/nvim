local M = {}

M._root_cwd = vim.fn.getcwd()
M._cwd_history = {}

function M.push_cwd(dir)
	table.insert(M._cwd_history, vim.fn.getcwd())
	vim.fn.chdir(dir)
	vim.notify("cwd → " .. dir, vim.log.levels.INFO)
end

function M.pop_cwd()
	if #M._cwd_history == 0 then
		vim.notify("cwd history is empty", vim.log.levels.WARN)
		return
	end
	local prev = table.remove(M._cwd_history)
	vim.fn.chdir(prev)
	vim.notify("cwd ← " .. prev, vim.log.levels.INFO)
end

function M.telescope(builtin)
	return function()
		require("telescope.builtin")[builtin]()
	end
end

function M.get_or_default(value, default)
	if value ~= nil then
		return value
	else
		return default
	end
end

return M

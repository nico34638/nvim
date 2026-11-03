local M = {}

function M.setup()
	-- Signs
	local signs = { Error = "", Warn = "", Hint = "", Info = "" }
	local text, numhl = {}, {}
	for type, icon in pairs(signs) do
		local severity = vim.diagnostic.severity[type:upper()]
		text[severity] = icon
		numhl[severity] = "DiagnosticSign" .. type
	end
	vim.diagnostic.config({ signs = { text = text, numhl = numhl } })
end

function M.on_attach(client, bufnr)
	-- Highlight references - skip for slow/chatty LSPs (e.g. tofu-ls)
	local slow_clients = { tofu_ls = true }
	if client.server_capabilities.documentHighlightProvider and not slow_clients[client.name] then
		vim.api.nvim_create_augroup("lsp_document_highlight", {
			clear = false,
		})
		vim.api.nvim_clear_autocmds({
			group = "lsp_document_highlight",
			buffer = bufnr,
		})
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = "lsp_document_highlight",
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			group = "lsp_document_highlight",
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
	end
end

return M

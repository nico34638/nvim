return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "saghen/blink.cmp" },
		{
			"kosayoda/nvim-lightbulb",
			opts = {
				sign = { enabled = false },
				virtual_text = {
					enabled = true,
					text = "󰌵",
				},
				autocmd = { enabled = true },
			},
		},
		{
			"j-hui/fidget.nvim",
			tag = "legacy",
			opts = {
				text = {
					spinner = "dots",
					done = "",
				},
			},
		},
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("plugins.lsp.ui").setup()

		vim.diagnostic.config({ severity_sort = true })


		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("custom_lsp", {}),
			callback = function(args)
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				require("plugins.lsp.keymaps").on_attach(args.buf)
				require("plugins.lsp.ui").on_attach(client, args.buf)
			end,
		})

		local servers = {
			lua_ls = {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			},
			clangd = {
				capabilities = {
					textDocument = { completion = { completionItem = { snippetSupport = false } } },
				},
			},
			pyright = {},
			texlab = {},
			nil_ls = {},
			rust_analyzer = {},
			hls = {},
			gopls = {},
			phpactor = {},
			helm_ls = {},
			ts_ls = {},
			terraformls = {},
		}

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		for server, config in pairs(servers) do
			vim.lsp.config(server, config)
			vim.lsp.enable(server)
		end
	end,
}

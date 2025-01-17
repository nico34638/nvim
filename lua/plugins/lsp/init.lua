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

		local function on_attach(client, bufnr)
			require("plugins.lsp.keymaps").on_attach(bufnr)
			require("plugins.lsp.ui").on_attach(client, bufnr)
		end

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

		local lspconfig = require("lspconfig")
		for server, config in pairs(servers) do
			lspconfig[server].setup(vim.tbl_deep_extend("force", {
				on_attach = on_attach,
				capabilities = vim.deepcopy(capabilities),
			}, config))
		end
	end,
}

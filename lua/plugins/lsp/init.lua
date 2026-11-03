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
			opts = {
				progress = {
					display = { done_ttl = 2 },
				},
			},
		},
	},
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("plugins.lsp.ui").setup()

		vim.diagnostic.config({ severity_sort = true })

		vim.lsp.log.set_level("WARN")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("custom_lsp", { clear = true }),
			callback = function(args)
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				require("plugins.lsp.keymaps").on_attach(args.buf)
				require("plugins.lsp.ui").on_attach(client, args.buf)
				vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
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
			puppet = {},
			-- OpenTofu fork of terraform-ls: understands registry.opentofu.org providers,
			-- so provider schemas (and thus go-to-definition in resource/data/provider blocks) work.
			-- Also free of terraform-ls#2108 (negative semantic token deltas hanging nvim).
			tofu_ls = {
				-- The server writes its debug log to stderr, which nvim records at ERROR level
				-- in lsp.log regardless of vim.lsp.log level (~1 GB). Send it elsewhere.
				cmd = { "tofu-ls", "serve", "-log-file=/dev/null" },
				filetypes = { "terraform", "terraform-vars" },
				-- Limit root to the init'd module, not the whole monorepo
				root_markers = { ".terraform", ".terraform.lock.hcl" },
				-- On macOS nvim watches one handle per directory: on the monorepo (~2800 dirs)
				-- that hits EMFILE. Buffers still sync via didChange/didSave; run :lsp restart
				-- after out-of-editor changes (git checkout, tofu init).
				capabilities = {
					workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
				},
			},
		}

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		for server, config in pairs(servers) do
			config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
			vim.lsp.config(server, config)
			vim.lsp.enable(server)
		end
	end,
}

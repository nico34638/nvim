return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"saghen/blink.cmp",
		dependencies = { "L3MON4D3/LuaSnip" },
		event = "InsertEnter",
		version = "*",
		opts = {
			snippets = { preset = "luasnip" },
			keymap = {
				preset = "enter",
				["<C-Space>"] = { "show" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
			appearance = { use_nvim_cmp_as_default = false },
			signature = { enabled = true },
			completion = {
				list = {
					selection = { preselect = false, auto_insert = true },
				},
				accept = {
					auto_brackets = { enabled = true },
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "<leader>s", desc = "start incremental selection" },
		},
		opts = {
			highlight = { enable = true },
			ensure_installed = { "c", "lua", "vim", "vimdoc", "terraform" },
			auto_install = true,
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader>s",
					node_incremental = "<Space>",
					scope_incremental = false,
					node_decremental = "<BS>",
				},
			},
		},
		config = function(_, opts)
			require("nvim-ts-autotag").setup()
			require("nvim-treesitter").setup(opts)
			-- Force treesitter highlight on all buffers with a known parser
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},
	{
		"mhartington/formatter.nvim",
		event = "BufWrite",
		keys = {
			{
				"<leader>ot",
				function()
					vim.g.autoformat = not vim.g.autoformat
					vim.notify(
						"Auto format " .. (vim.g.autoformat and "enabled" or "disabled"),
						vim.log.levels.INFO,
						{ title = "Formatter" }
					)
				end,
				desc = "toggle",
			},
			{
				"<leader>ob",
				function()
					local get_or_default = require("utils").get_or_default
					vim.b.autoformat = not get_or_default(vim.b.autoformat, vim.g.autoformat)
					vim.notify(
						"Buffer Auto format " .. (vim.b.autoformat and "enabled" or "disabled"),
						vim.log.levels.INFO,
						{ title = "Formatter" }
					)
				end,
				desc = "buffer toggle",
			},
			{ "<leader>of", "<Cmd>silent! Format<CR>", desc = "format" },
		},
		config = function()
			vim.g.autoformat = true

			local formatter = require("formatter")
			formatter.setup({
				filetype = {
					lua = { require("formatter.filetypes.lua").stylua },
					c = { require("formatter.filetypes.c").clangformat },
					cpp = { require("formatter.filetypes.cpp").clangformat },
					javascript = { require("formatter.filetypes.javascript").prettier },
					typescript = { require("formatter.filetypes.typescript").prettier },
					javascriptreact = { require("formatter.filetypes.javascriptreact").prettier },
					typescriptreact = { require("formatter.filetypes.typescriptreact").prettier },
					json = { require("formatter.filetypes.json").prettier },
					yaml = { require("formatter.filetypes.yaml").prettier },
					python = { require("formatter.filetypes.python").black },
					-- rust = { require("formatter.filetypes.rust").rustfmt },
					nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
					go = { require("formatter.filetypes.go").gofmt },
					terraform = {
						function()
							return { exe = "tofu", args = { "fmt", "-" }, stdin = true }
						end,
					},
					["terraform-vars"] = {
						function()
							return { exe = "tofu", args = { "fmt", "-" }, stdin = true }
						end,
					},
				},
			})

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("my_format_write", { clear = true }),
				pattern = "*",
				callback = function()
					local get_or_default = require("utils").get_or_default
					if get_or_default(vim.b.autoformat, vim.g.autoformat) then
						vim.cmd("silent! FormatWrite")
					end
				end,
			})
		end,
	},
	{
		"github/copilot.vim",
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = { "github/copilot.vim", "nvim-lua/plenary.nvim" },
		cmd = { "CopilotChat", "CopilotChatOpen" },
		keys = {
			{ "<leader>cc", "<Cmd>CopilotChatToggle<CR>", desc = "toggle chat", mode = { "n", "x" } },
			{
				"<leader>ce",
				function()
					local input = vim.fn.input("Quick chat: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
					end
				end,
				desc = "quick chat",
			},
			{
				"<leader>ca",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "prompt actions",
				mode = { "n", "x" },
			},
			{
				"<leader>cf",
				function()
					require("telescope.builtin").find_files({
						prompt_title = "Add file to Copilot context",
						attach_mappings = function(prompt_bufnr)
							require("telescope.actions").select_default:replace(function()
								local entry = require("telescope.actions.state").get_selected_entry()
								require("telescope.actions").close(prompt_bufnr)
								local path = entry.path or entry[1]
								local input = vim.fn.input("Question: ")
								if input ~= "" then
									require("CopilotChat").ask("#file:" .. path .. "\n" .. input)
								end
							end)
							return true
						end,
					})
				end,
				desc = "add file to context",
			},
			{
				"<leader>cd",
				function()
					require("telescope.builtin").find_files({
						prompt_title = "Add folder to Copilot context",
						find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
						attach_mappings = function(prompt_bufnr)
							require("telescope.actions").select_default:replace(function()
								local entry = require("telescope.actions.state").get_selected_entry()
								require("telescope.actions").close(prompt_bufnr)
								local dir = entry.path or (vim.fn.getcwd() .. "/" .. entry[1])
								local files = vim.fn.globpath(dir, "*", false, true)
								local refs = {}
								for _, f in ipairs(files) do
									if vim.fn.isdirectory(f) == 0 then
										table.insert(refs, "#file:" .. f)
									end
								end
								if #refs == 0 then
									vim.notify("No files found in " .. dir, vim.log.levels.WARN)
									return
								end
								local input = vim.fn.input("Question: ")
								if input ~= "" then
									require("CopilotChat").ask(table.concat(refs, "\n") .. "\n" .. input)
								end
							end)
							return true
						end,
					})
				end,
				desc = "add folder to context",
			},
		},
		opts = {
			window = { layout = "vertical", width = 0.35 },
			mappings = {
				reset = { normal = "<C-r>", insert = "<C-r>" },
			},
		},
	},
}

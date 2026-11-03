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
		branch = "main",
		build = ":TSUpdate",
		-- The main branch does not support lazy-loading
		lazy = false,
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		-- Incremental selection is native since 0.12: `an` / `in` in visual mode, `[n` / `]n`
		config = function()
			require("nvim-ts-autotag").setup()

			local ts = require("nvim-treesitter")
			-- No-op when already installed
			ts.install({ "c", "lua", "vim", "vimdoc", "terraform", "yaml" })

			local function attach(buf, lang)
				if not pcall(vim.treesitter.start, buf, lang) then
					return false
				end
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				return true
			end

			-- The main branch has no highlight/indent/auto_install modules: done by hand per buffer
			local no_ts_ft = { gitcommit = true, gitrebase = true, help = true }
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("my_treesitter", { clear = true }),
				callback = function(args)
					local buf, ft = args.buf, vim.bo[args.buf].filetype
					if no_ts_ft[ft] then
						return
					end
					local lang = vim.treesitter.language.get_lang(ft)
					if not lang or attach(buf, lang) then
						return
					end
					-- auto_install: parser missing but available upstream
					if vim.tbl_contains(ts.get_available(), lang) then
						ts.install(lang):await(function()
							vim.schedule(function()
								if vim.api.nvim_buf_is_valid(buf) then
									attach(buf, lang)
								end
							end)
						end)
					end
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
  "pwntester/octo.nvim",
  cmd = "Octo",
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = "telescope",
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  keys = {
    {
      "<leader>gi",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>gp",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>gd",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>gn",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>gs",
      function()
        require("octo.utils").create_base_search_command { include_current_repo = true }
      end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    -- OR "ibhagwan/fzf-lua",
    -- OR "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons", -- optional if file_panel.icons is a function
  },
}
}

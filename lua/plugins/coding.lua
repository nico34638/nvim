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
		keys = {
			{ "<leader>s", desc = "start incremental selection" },
		},
		opts = {
			ensure_installed = { "c", "lua", "vim", "vimdoc" },
			auto_install = true,
			highlight = { enable = true },
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
			require("nvim-treesitter.configs").setup(opts)
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
                    rust = { require("formatter.filetypes.rust").rustfmt },
                    nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
                    go = { require("formatter.filetypes.go").gofmt },
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
}

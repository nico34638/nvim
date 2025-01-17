return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{
					mode = { "n" },
					{ "<leader>f", group = "file/find" },
					{ "<leader>o", group = "format" },
					{ "<leader>t", group = "tree" },
					{ "<leader>d", group = "debugger" },
					{ "<leader>l", group = "lsp" },
					{ "<leader>p", group = "pdf" },
				},
			},
			icons = { mappings = false },
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-tree/nvim-web-devicons" },
		},
		cmd = "Telescope",
		keys = function()
			local telescope = require("utils").telescope

			return {
				{ "ff", telescope("find_files"), desc = "files" },
				{ "fr", telescope("live_grep"), desc = "live grep" },
				{ "fg", telescope("git_files"), desc = "git files" },
				{ "<leader>ff", telescope("find_files"), desc = "files" },
				{ "<leader>fg", telescope("git_files"), desc = "git files" },
				{ "<leader>fr", telescope("live_grep"), desc = "grep" },
				{ "<leader>fb", telescope("buffers"), desc = "buffers" },
				{ "<leader>fc", telescope("colorscheme"), desc = "colorscheme" },
				{ "<leader>fh", telescope("oldfiles"), desc = "history" },
			}
		end,
		config = function()
			local telescope = require("telescope")
			telescope.setup()
			telescope.load_extension("fzf")
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
		keys = {
			{ "<leader>tt", "<Cmd>NvimTreeToggle<CR>", desc = "toggle" },
			{ "<leader>tf", "<Cmd>NvimTreeFocus<CR>", desc = "focus" },
			{ "<leader>tr", "<Cmd>NvimTreeRefresh<CR>", desc = "refresh" },
			{ "<leader>to", "<Cmd>NvimTreeFindFile<CR>", desc = "find opened file" },
		},
		opts = {
			actions = {
				open_file = { quit_on_open = true },
			},
			git = { ignore = true },
			renderer = {
				highlight_git = true,
				icons = {
					show = {
						git = false,
						folder = true,
						file = true,
						folder_arrow = true,
					},
				},
			},
		},
	},
}

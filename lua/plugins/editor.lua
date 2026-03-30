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
				{
					"<leader>fw",
					function()
						local utils = require("utils")
						require("telescope.builtin").find_files({
							prompt_title = "Change cwd (root: " .. utils._root_cwd .. ")",
							cwd = utils._root_cwd,
							find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
							attach_mappings = function(prompt_bufnr)
								require("telescope.actions").select_default:replace(function()
									local entry = require("telescope.actions.state").get_selected_entry()
									require("telescope.actions").close(prompt_bufnr)
									local dir = entry.path or (utils._root_cwd .. "/" .. entry[1])
									utils.push_cwd(dir)
								end)
								return true
							end,
						})
					end,
					desc = "change cwd",
				},
				{
					"<leader>f.",
					function()
						require("utils").push_cwd(vim.fn.expand("%:p:h"))
					end,
					desc = "cwd to current file",
				},
				{
					"<leader>fW",
					function()
						require("utils").pop_cwd()
					end,
					desc = "cwd back",
				},
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

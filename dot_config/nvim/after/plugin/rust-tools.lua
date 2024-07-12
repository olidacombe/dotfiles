local rt = require("rust-tools")

local codelldb_adapter = require("config.dap.lldb").adapter_components()

rt.setup({
	dap = {
		adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_adapter.exe, codelldb_adapter.lib),
	},
	server = {
		on_attach = function(client, bufnr)
			require("od.lsp").on_attach(client, bufnr)

			local status_ok, which_key = pcall(require, "which-key")
			if not status_ok then
				return
			end

			local opts = {
				mode = "n", -- NORMAL mode
				prefix = "<leader>",
				buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
				silent = true, -- use `silent` when creating keymaps
				noremap = true, -- use `noremap` when creating keymaps
				nowait = true, -- use `nowait` when creating keymaps
			}

			vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })

			local mappings = {
				{ "r", group = "+Rust" },
				{ "rj", "<cmd>lua require('rust-tools').join_lines.join_lines()<CR>", desc = "Join Lines" },
				{ "rr", "<cmd>RustRunnables<Cr>", desc = "Runnables" },
				{ "rt", "<cmd>lua _CARGO_TEST()<cr>", desc = "Cargo Test" },
				{ "rm", "<cmd>RustExpandMacro<Cr>", desc = "Expand Macro" },
				{ "rc", "<cmd>RustOpenCargo<Cr>", desc = "Open Cargo" },
				{ "rp", "<cmd>RustParentModule<Cr>", desc = "Parent Module" },
				{ "rd", "<cmd>RustOpenExternalDocs<Cr>", desc = "Docs" },
				-- d = { TODO fall back to this if [my PR](https://github.com/simrat39/rust-tools.nvim/pull/431) gets canned
				--     function()
				--         require("rust-tools").utils.request(
				--             0,
				--             "experimental/externalDocs",
				--             vim.lsp.util.make_position_params(),
				--             function(_, url)
				--                 if url then
				--                     -- vim.fn["netrw#BrowseX"](url, 0)
				--                     require("lazy.util").open(url)
				--                 end
				--             end
				--         )
				--     end,
				--     "Docs",
				-- },
				{ "rD", "<cmd>RustDebuggables<Cr>", desc = "Debuggables" },
				{ "rv", "<cmd>RustViewCrateGraph<Cr>", desc = "View Crate Graph" },
				{
					"rR",
					"<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
					desc = "Reload Workspace",
				},
				{
					"t",
					group = "+Rust Crates",
				},
				{ "to", "<cmd>lua require('crates').show_popup()<CR>", "Show popup" },
				{ "tr", "<cmd>lua require('crates').reload()<CR>", "Reload" },
				{ "tv", "<cmd>lua require('crates').show_versions_popup()<CR>", "Show Versions" },
				{ "tf", "<cmd>lua require('crates').show_features_popup()<CR>", "Show Features" },
				{ "td", "<cmd>lua require('crates').show_dependencies_popup()<CR>", "Show Dependencies Popup" },
				{ "tu", "<cmd>lua require('crates').update_crate()<CR>", "Update Crate" },
				{ "ta", "<cmd>lua require('crates').update_all_crates()<CR>", "Update All Crates" },
				{ "tU", "<cmd>lua require('crates').upgrade_crate<CR>", "Upgrade Crate" },
				{ "tA", "<cmd>lua require('crates').upgrade_all_crates(true)<CR>", "Upgrade All Crates" },
				{ "tH", "<cmd>lua require('crates').open_homepage()<CR>", "Open Homepage" },
				{ "tR", "<cmd>lua require('crates').open_repository()<CR>", "Open Repository" },
				{ "tD", "<cmd>lua require('crates').open_documentation()<CR>", "Open Documentation" },
				{ "tC", "<cmd>lua require('crates').open_crates_io()<CR>", "Open Crate.io" },
			}

			which_key.register(mappings, opts)
		end,
	},

	tools = {
		open_url = require("lazy.util").open,
	},
})

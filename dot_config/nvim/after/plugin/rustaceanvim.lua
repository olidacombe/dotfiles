local lsp_on_attach = require('od.lsp').on_attach
local whichkey = require('which-key')

vim.g.rustaceanvim = {
    server = {
        on_attach = function(client, bufnr)
            lsp_on_attach(client, bufnr)

            -- local bufnr = vim.api.nvim_get_current_buf()
            -- vim.keymap.set(
            --     "n",
            --     "<leader>vca",
            --     function()
            --         vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
            --         -- or vim.lsp.buf.codeAction() if you don't want grouping.
            --     end,
            --     { silent = true, buffer = bufnr }
            -- )
            vim.keymap.set(
                "n",
                "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
                function()
                    vim.cmd.RustLsp({ 'hover', 'actions' })
                end,
                { silent = true, buffer = bufnr }
            )
            whichkey.add({
                { "<leader>r",  group = "rust" },
                { "<leader>rd", function() vim.cmd.RustLsp("openDocs") end,    { desc = "docs" } },
                { "<leader>x",  group = "eXpand" },
                { "<leader>xm", function() vim.cmd.RustLsp("expandMacro") end, { desc = "macro" } },
            })
        end
    },
    tools = {
        test_executor = "background"
    }
}

-- old rust-tools stuff
-- local rt = require("rust-tools")
--
-- local codelldb_adapter = require("config.dap.lldb").adapter_components()
--
-- rt.setup({
--     dap = {
--         adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_adapter.exe, codelldb_adapter.lib),
--     },
--     server = {
--         on_attach = function(client, bufnr)
--             require("od.lsp").on_attach(client, bufnr)
--
--             local status_ok, which_key = pcall(require, "which-key")
--             if not status_ok then
--                 return
--             end
--
--             local opts = {
--                 buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
--                 silent = true, -- use `silent` when creating keymaps
--                 noremap = true, -- use `noremap` when creating keymaps
--                 nowait = true, -- use `nowait` when creating keymaps
--             }
--
--             vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
--
--             local mappings = {
--                 { "<leader>r",  group = "+Rust" },
--                 { "<leader>rj", "<cmd>lua require('rust-tools').join_lines.join_lines()<CR>", desc = "Join Lines" },
--                 { "<leader>rr", "<cmd>RustRunnables<Cr>",                                     desc = "Runnables" },
--                 { "<leader>rt", "<cmd>lua _CARGO_TEST()<cr>",                                 desc = "Cargo Test" },
--                 { "<leader>rm", "<cmd>RustExpandMacro<Cr>",                                   desc = "Expand Macro" },
--                 { "<leader>rc", "<cmd>RustOpenCargo<Cr>",                                     desc = "Open Cargo" },
--                 { "<leader>rp", "<cmd>RustParentModule<Cr>",                                  desc = "Parent Module" },
--                 { "<leader>rd", "<cmd>RustOpenExternalDocs<Cr>",                              desc = "Docs" },
--                 -- d = { TODO fall back to this if [my PR](https://github.com/simrat39/rust-tools.nvim/pull/431) gets canned
--                 --     function()
--                 --         require("rust-tools").utils.request(
--                 --             0,
--                 --             "experimental/externalDocs",
--                 --             vim.lsp.util.make_position_params(),
--                 --             function(_, url)
--                 --                 if url then
--                 --                     -- vim.fn["netrw#BrowseX"](url, 0)
--                 --                     require("lazy.util").open(url)
--                 --                 end
--                 --             end
--                 --         )
--                 --     end,
--                 --     "Docs",
--                 -- },
--                 { "<leader>rD", "<cmd>RustDebuggables<Cr>",                                   desc = "Debuggables" },
--                 {
--                     "<leader>rv",
--                     "<cmd>RustViewCrateGraph<Cr>",
--                     desc = "View Crate Graph",
--                 },
--                 {
--                     "<leader>rR",
--                     "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
--                     desc = "Reload Workspace",
--                 },
--                 {
--                     "<leader>t",
--                     group = "+Rust Crates",
--                 },
--                 { "<leader>to", "<cmd>lua require('crates').show_popup()<CR>",          desc = "Show popup" },
--                 { "<leader>tr", "<cmd>lua require('crates').reload()<CR>",              desc = "Reload" },
--                 { "<leader>tv", "<cmd>lua require('crates').show_versions_popup()<CR>", desc = "Show Versions" },
--                 { "<leader>tf", "<cmd>lua require('crates').show_features_popup()<CR>", desc = "Show Features" },
--                 {
--                     "<leader>td",
--                     "<cmd>lua require('crates').show_dependencies_popup()<CR>",
--                     desc = "Show Dependencies Popup",
--                 },
--                 { "<leader>tu", "<cmd>lua require('crates').update_crate()<CR>", desc = "Update Crate" },
--                 {
--                     "<leader>ta",
--                     "<cmd>lua require('crates').update_all_crates()<CR>",
--                     desc = "Update All Crates",
--                 },
--                 { "<leader>tU", "<cmd>lua require('crates').upgrade_crate<CR>",  desc = "Upgrade Crate" },
--                 {
--                     "<leader>tA",
--                     "<cmd>lua require('crates').upgrade_all_crates(true)<CR>",
--                     desc = "Upgrade All Crates",
--                 },
--                 { "<leader>tH", "<cmd>lua require('crates').open_homepage()<CR>",   desc = "Open Homepage" },
--                 { "<leader>tR", "<cmd>lua require('crates').open_repository()<CR>", desc = "Open Repository" },
--                 {
--                     "<leader>tD",
--                     "<cmd>lua require('crates').open_documentation()<CR>",
--                     desc = "Open Documentation",
--                 },
--                 { "<leader>tC", "<cmd>lua require('crates').open_crates_io()<CR>", desc = "Open Crate.io" },
--             }
--
--             which_key.add(mappings, opts)
--         end,
--     },
--
--     tools = {
--         open_url = require("lazy.util").open,
--     },
-- })

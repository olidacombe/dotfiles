local register_normal = require("od.which-key").register_normal

require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
        }),
        require("neotest-jest"),
        require("neotest-go"),
        require("neotest-plenary"),
        require("neotest-rust"),
        require("neotest-vim-test")({
            ignore_file_types = { "lua", "python", "rust", "vim", },
        }),
    },
})

register_normal({
    t = {
        name = "Test / Tab",
        a = { "<cmd>lua require('neotest').run.attach()<cr>", "Attach" },
        c = { "<cmd>tabc<CR>", "Tab Close" },
        f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Run File" },
        F = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Debug File" },
        l = { "<cmd>lua require('neotest').run.run_last()<cr>", "Run Last" },
        L = { "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", "Debug Last" },
        n = { "<cmd>lua require('neotest').run.run()<cr>", "Run Nearest" },
        N = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Debug Nearest" },
        o = { "<cmd>lua require('neotest').output.open({ enter = true })<cr>", "Output" },
        S = { "<cmd>lua require('neotest').run.stop()<cr>", "Stop" },
        s = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Summary" },
    },
})

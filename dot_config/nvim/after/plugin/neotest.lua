local register_normal = require("od.which-key").register_normal

require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = { justMyCode = false },
        }),
        -- require("neotest-jest"),
        require("neotest-go"),
        require("neotest-plenary"),
        require("rustaceanvim.neotest"),
        require("neotest-vim-test")({
            ignore_file_types = { "lua", "python", "rust", "vim" },
        }),
    },
})

register_normal({
    { "t",  group = "Test / Tab" },
    { "ta", "<cmd>lua require('neotest').run.attach()<cr>",                                    desc = "Attach" },
    { "tc", "<cmd>tabc<CR>",                                                                   desc = "Tab Close" },
    { "tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>",                     desc = "Run File" },
    { "tF", "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", desc = "Debug File" },
    { "tl", "<cmd>lua require('neotest').run.run_last()<cr>",                                  desc = "Run Last" },
    { "tL", "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>",              desc = "Debug Last" },
    { "tn", "<cmd>lua require('neotest').run.run()<cr>",                                       desc = "Run Nearest" },
    { "tN", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",                     desc = "Debug Nearest" },
    { "to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>",                   desc = "Output" },
    { "tS", "<cmd>lua require('neotest').run.stop()<cr>",                                      desc = "Stop" },
    { "ts", "<cmd>lua require('neotest').summary.toggle()<cr>",                                desc = "Summary" },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local opts = {
    dev = {
        -- This is where you need to put working copies of plugins
        -- where you set `dev = true`
        path = "~/od",
    },
}

local plugins = {
    --
    --  @@@@@@   @@@@@@@
    -- @@@@@@@@  @@@@@@@@
    -- @@!  @@@  @@!  @@@
    -- !@!  @!@  !@!  @!@
    -- @!@  !@!  @!@  !@!
    -- !@!  !!!  !@!  !!!
    -- !!:  !!!  !!:  !!!
    -- :!:  !:!  :!:  !:!
    -- ::::: ::   :::: ::
    --  : :  :   :: :  :
    --
    -- Commentalist
    {
        "olidacombe/commentalist.nvim",
        dependencies = {
            { "numToStr/Comment.nvim" },
        },
        -- dev = true,
    },
    -- Jirascope
    {
        "olidacombe/jirascope",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
        -- dev = true,
    },
    -- Makemapper
    {
        "olidacombe/makemapper.nvim",
        dependencies = "nvim-treesitter/nvim-treesitter",
        -- dev = true,
    },
    -- Terrabastard
    {
        "olidacombe/terrabastard.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" },
        },
        -- dev = true,
    },

    -- Mini
    { "echasnovski/mini.nvim", version = false },

    -- DiffView
    {
        "sindrets/diffview.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-tree/nvim-web-devicons" },
        },
    },

    -- direnv
    "direnv/direnv.vim",

    -- editorconfig.org
    "editorconfig/editorconfig-vim",

    -- tree-sitter-just
    "IndianBoy42/tree-sitter-just",

    -- monorepo
    {
        "imNel/monorepo.nvim",
        config = function()
            require("monorepo").setup({
                silent = true,                      -- Supresses vim.notify messages
                autoload_telescope = false,         -- do this in after/telescope
                data_path = vim.fn.stdpath("data"), -- Path that monorepo.json gets saved to
            })
        end,
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },

    -- Neodev
    "folke/neodev.nvim",

    -- Copilot
    { "github/copilot.vim",    lazy = false },

    -- Gitlinker
    {
        "ruifm/gitlinker.nvim",
        dependencies = "nvim-lua/plenary.nvim",
    },

    -- Dressing - pretty up the inputs
    "stevearc/dressing.nvim",

    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- ____ ___  ____ _    _ ____ _  _
    -- |__| |__] |  | |    | [__  |__|
    -- |  | |__] |__| |___ | ___] |  |
    --
    "tpope/vim-abolish",

    -- Fugitive
    "tpope/vim-fugitive",

    -- GitSigns
    "lewis6991/gitsigns.nvim",

    -- =======================================================================
    -- =======================     ==========  ===============================
    -- ======================  ===  =========  ===============================
    -- =====================  ===============  ===============================
    -- =====================  =========   ===  ===   ===  =  ==  =   ====   ==
    -- =====================  ========     ==  ==     ==  =  ==    =  ==  =  =
    -- =====================  ========  =  ==  ==  =  ==  =  ==  ========  ===
    -- =====================  ========  =  ==  ==  =  ==  =  ==  =========  ==
    -- ======================  ===  ==  =  ==  ==  =  ==  =  ==  =======  =  =
    -- =======================     ====   ===  ===   ====    ==  ========   ==
    -- =======================================================================

    -- Catpuccin Colourscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd.colorscheme("catppuccin")
            require("od.colours").overrides()
        end,
    },

    -- Base16
    "Soares/base16.nvim",

    -- Gruvbox Colourscheme
    "ellisonleao/gruvbox.nvim",

    -- Kanagawa Colourscheme
    { "rebelot/kanagawa.nvim" },

    -- Nordic Colourscheme
    {
        "AlexvZyl/nordic.nvim",
    },

    -- Neotest
    "nvim-neotest/neotest-plenary",
    {
        "nvim-neotest/neotest",
        dependencies = {
            "antoinemadec/FixCursorHold.nvim",
            "haydenmeade/neotest-jest",
            "nvim-lua/plenary.nvim",
            "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-plenary",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-vim-test",
            "nvim-neotest/nvim-nio",
            "nvim-treesitter/nvim-treesitter",
            -- "rouge8/neotest-rust",
            -- temp(1) until https://github.com/rouge8/neotest-rust/pull/19
            { "MarkEmmons/neotest-rust", branch = "feature/dap-support" },
        },
    },

    -- Debugging
    -- https://alpha2phi.medium.com/neovim-for-beginners-debugging-using-dap-44626a767f57 was handy
    {
        "mfussenegger/nvim-dap",
        -- opt = true,
        -- event = "BufReadPre",
        -- module = { "dap" },
        -- wants = { "nvim-dap-virtual-text", "nvim-dap-ui", "nvim-dap-python", "which-key.nvim" },
        dependencies = {
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            -- "mfussenegger/nvim-dap-python",
            "nvim-telescope/telescope-dap.nvim",
            -- { "leoluz/nvim-dap-go", module = "dap-go" },
            -- { "jbyuki/one-small-step-for-vimkind", module = "osv" },
        },
    },

    -- Harpoon
    "theprimeagen/harpoon",

    -- Hop
    {
        "phaazon/hop.nvim",
        branch = "v2",
    },

    -- LSP status UI
    {
        "j-hui/fidget.nvim",
        -- TODO update to main and fix for new options
        branch = "legacy",
    },

    -- UFO nice folding
    { "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },

    -- [LSP](https://github.com/VonHeikemen/lsp-zero.nvim)
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-emoji" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },

            -- Snippets
            { "L3MON4D3/LuaSnip" },
            { "rafamadriz/friendly-snippets" },
        },
    },

    -- LUALine
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
    },

    -- Rose Pine colour scheme
    {
        "rose-pine/neovim",
        as = "rose-pine",
    },

    {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
    },

    {
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        lazy = false,   -- This plugin is already lazy
    },

    {
        "saecki/crates.nvim",
        tag = "v0.3.0",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },

    -- Telescope for fuzzy finding
    {
        "nvim-telescope/telescope.nvim", --tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        branch = "0.1.x",                -- got me past https://github.com/nvim-telescope/telescope.nvim/issues/2192
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build =
        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },

    -- Tmux pane navigation integration
    "christoomey/vim-tmux-navigator",

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    { "nvim-treesitter/playground" },

    -- Undotree
    "mbbill/undotree",

    -- nvim-tree
    {
        "nvim-tree/nvim-tree.lua",
        -- dependencies = {
        --   'nvim-tree/nvim-web-devicons', -- optional, for file icons
        -- },
        version = "*",
        lazy = false,
    },

    -- TokyoNight Colourscheme
    "folke/tokyonight.nvim",

    -- WhichKey
    "folke/which-key.nvim",

    -- wilder.nvim
    { "gelguy/wilder.nvim",        build = ":UpdateRemotePlugins" },

    -- Install tools via Mason which aren't LSP servers
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- Icon picker
    {
        "ziontee113/icon-picker.nvim",
        dependencies = { "stevearc/dressing.nvim", "nvim-telescope/telescope.nvim" },
    },
}

return require("lazy").setup(plugins, opts)

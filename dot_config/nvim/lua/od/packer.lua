vim.cmd.packadd("packer.nvim")

return require('packer').startup(function(use)
    -- Comment.nvim
    use("numToStr/Comment.nvim")

    -- Commentalist local dev
    use({
        "~/od/commentalist.nvim/",
        requires = "numToStr/Comment.nvim",
    })

    -- DiffView
    use { 'sindrets/diffview.nvim',
        requires = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-tree/nvim-web-devicons' },
        }
    }

    -- editorconfig.org
    use('editorconfig/editorconfig-vim')

    -- Neodev
    use 'folke/neodev.nvim'

    -- ____ ___  ____ _    _ ____ _  _
    -- |__| |__] |  | |    | [__  |__|
    -- |  | |__] |__| |___ | ___] |  |
    --
    use('tpope/vim-abolish')

    -- Fugitive
    use('tpope/vim-fugitive')

    -- GitSigns
    use('lewis6991/gitsigns.nvim')

    -- Surround
    use({ 'kylechui/nvim-surround', tag = "*" })

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

    -- Gruvbox Colourscheme
    use('ellisonleao/gruvbox.nvim')

    -- Kanagawa Colourscheme
    use('rebelot/kanagawa.nvim')

    -- Nordic Colourscheme
    use('AlexvZyl/nordic.nvim')

    -- Neotest
    use("nvim-neotest/neotest-plenary")
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-go",
            "haydenmeade/neotest-jest",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-plenary",
            "rouge8/neotest-rust",
            "nvim-neotest/neotest-vim-test",
        }
    }

    -- Harpoon
    use('theprimeagen/harpoon')

    -- Hop
    use {
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
        end
    }

    -- LSP status UI
    use('j-hui/fidget.nvim')

    -- UFO nice folding
    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

    -- [LSP](https://github.com/VonHeikemen/lsp-zero.nvim)
    use {
        'VonHeikemen/lsp-zero.nvim',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    }

    -- LUALine
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Rose Pine colour scheme
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
    })

    use {
        "SmiteshP/nvim-navic",
        requires = "neovim/nvim-lspconfig"
    }

    -- Telescope for fuzzy finding
    use {
        'nvim-telescope/telescope.nvim', --tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        branch = '0.1.x', -- got me past https://github.com/nvim-telescope/telescope.nvim/issues/2192
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- Tmux pane navigation integration
    use('christoomey/vim-tmux-navigator')

    -- Treesitter
    use('nvim-treesitter/nvim-treesitter', { run = 'TSUpdate' })
    use('nvim-treesitter/playground')

    -- Undotree
    use('mbbill/undotree')

    -- nvim-tree
    use {
        'nvim-tree/nvim-tree.lua',
        -- requires = {
        --   'nvim-tree/nvim-web-devicons', -- optional, for file icons
        -- },
        tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    -- TokyoNight Colourscheme
    use('folke/tokyonight.nvim')

    -- WhichKey
    use('folke/which-key.nvim')

    -- wilder.nvim
    use('gelguy/wilder.nvim')

end)

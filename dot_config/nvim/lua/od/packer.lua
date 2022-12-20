vim.cmd.packadd("packer.nvim")

return require('packer').startup(function(use)

    -- DiffView
    use { 'sindrets/diffview.nvim',
        requires = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-tree/nvim-web-devicons' },
        }
    }

    -- editorconfig.org
    use('editorconfig/editorconfig-vim')

    -- Fugitive
    use('tpope/vim-fugitive')

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

    -- NERD Commenter
    use 'preservim/nerdcommenter'

    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Rose Pine colour scheme
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd.colorscheme('rose-pine')
        end
    })

    -- Telescope for fuzzy finding
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- Tmux pane navigation integration
    use('christoomey/vim-tmux-navigator')

    -- Treesitter
    use('nvim-treesitter/nvim-treesitter', { run = 'TSUpdate' })
    use('nvim-treesitter/playground')

    -- Undotree
    use('mbbill/undotree')

    -- vim-test
    use('vim-test/vim-test')

end)

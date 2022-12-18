vim.cmd.packadd("packer.nvim")

return require('packer').startup(function(use)
  -- Fugitive
  use('tpope/vim-fugitive')

  -- Harpoon
  use('theprimeagen/harpoon')

  -- [LSP](https://github.com/VonHeikemen/lsp-zero.nvim)
  use {
	  'VonHeikemen/lsp-zero.nvim',
	  requires = {
		  -- LSP Support
		  {'neovim/nvim-lspconfig'},
		  {'williamboman/mason.nvim'},
		  {'williamboman/mason-lspconfig.nvim'},

		  -- Autocompletion
		  {'hrsh7th/nvim-cmp'},
		  {'hrsh7th/cmp-buffer'},
		  {'hrsh7th/cmp-path'},
		  {'saadparwaiz1/cmp_luasnip'},
		  {'hrsh7th/cmp-nvim-lsp'},
		  {'hrsh7th/cmp-nvim-lua'},

		  -- Snippets
		  {'L3MON4D3/LuaSnip'},
		  {'rafamadriz/friendly-snippets'},
	  }
  }

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
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Treesitter
  use('nvim-treesitter/nvim-treesitter', {run = 'TSUpdate'})
  use('nvim-treesitter/playground')

  -- Undotree
  use('mbbill/undotree')

end)

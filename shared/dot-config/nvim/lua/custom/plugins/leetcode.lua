return {
  {
    'kawre/leetcode.nvim',
    event = 'VeryLazy',
    build = ':TSUpdate html', -- if you have `nvim-treesitter` installed
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      -- 'nvim-telescope/telescope.nvim',
      -- "ibhagwan/fzf-lua",
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      -- configuration goes here
      lang = 'golang',
      image_support = true,
    },
  },
}

return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = {
        multi_window = false,
      },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          autohide = true,
        },
      },
    },
    keys = {
      {
        'ss',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'sf',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
    },
  },
}

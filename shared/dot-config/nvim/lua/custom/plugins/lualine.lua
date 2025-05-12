return {
  {
    'SmiteshP/nvim-navic',
    event = 'VeryLazy',
    opts = {
      separator = ' ',
      highlight = true,
      lazy_update_context = true,
      lsp = {
        auto_attach = true,
        preference = { 'gopls' },
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = {
      options = {
        { theme = 'seoul256' },
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
          },
          {
            'navic',
          },
        },
        -- lualine_x = {
        --   {
        --     require('noice').api.statusline.mode.get,
        --     cond = require('noice').api.statusline.mode.has,
        --     color = { fg = '#ff9e64' },
        --   },
        -- },
      },
    },
  },
}

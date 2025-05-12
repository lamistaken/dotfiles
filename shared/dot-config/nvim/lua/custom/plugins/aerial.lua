return {
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    opts = {
      attach_mode = 'global',
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      show_guides = true,
      layout = {
        max_width = { 60, 0.2 },
        width = nil,
        min_width = 10,
        default_direction = 'prefer_left',

        resize_to_content = true,
        win_opts = {
          winhl = 'Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB',
          signcolumn = 'yes',
          statuscolumn = ' ',
        },
      },
      filter_kind = false,
      guides = {
        mid_item = '├╴',
        last_item = '└╴',
        nested_top = '│ ',
        whitespace = '  ',
      },
    },
    keys = {
      { '<leader>cs', '<cmd>AerialToggle left<cr>', desc = 'Aerial (Symbols)' },
    },
  },
}

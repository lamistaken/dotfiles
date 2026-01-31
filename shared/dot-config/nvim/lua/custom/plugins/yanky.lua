return {
  {
    'gbprod/yanky.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      { '<leader>yy', '"+yy', mode = { 'n', 'v', 'x' }, desc = 'Yank line to clipboard' },
      -- { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank text' },
      -- { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked text after cursor' },
      -- { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked text before cursor' },
      {
        '<leader>yf',
        function()
          local filepath = vim.fn.expand '%:.'
          vim.fn.setreg('+', filepath)
        end,
        desc = 'Yank relative file path to clipboard',
      },
      {
        '<leader>yF',
        function()
          local filepath = vim.fn.expand '%:p'
          vim.fn.setreg('+', filepath)
        end,
        desc = 'Yank absolute file path to clipboard',
      },
    },
  },
}

return {
  {
    'gbprod/yanky.nvim',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      { '<leader>yy', '"+yy', mode = { 'n', 'v', 'x' }, desc = 'Yank line to clipboard' },
      { '<leader>yp', '<Plug>(YankyPutAfter)', mode = { 'n', 'v', 'x' }, desc = 'Put Text After Cursor' },
      { '<leader>yP', '<Plug>(YankyPutBefore)', mode = { 'n', 'v', 'x' }, desc = 'Put Text Before Cursor' },
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

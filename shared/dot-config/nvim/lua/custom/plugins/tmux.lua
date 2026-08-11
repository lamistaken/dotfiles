-- vim.g.tmux_navigator_disable_when_zoomed = 1
-- vim.g.tmux_navigator_no_wrap = 1

return {
  -- {
  --   'alexghergh/nvim-tmux-navigation',
  --   config = function()
  --     require('nvim-tmux-navigation').setup {
  --       keybindings = {
  --         left = '<C-h>',
  --         down = '<C-j>',
  --         up = '<C-k>',
  --         right = '<C-l>',
  --         last_active = '<C-\\>',
  --         next = '<C-Space>',
  --       },
  --     }
  --
  --     -- Terminal mode keymaps (for sidekick/terminal buffers)
  --     vim.keymap.set('t', '<C-h>', [[<C-\><C-n>:lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<CR>]], { silent = true })
  --     vim.keymap.set('t', '<C-j>', [[<C-\><C-n>:lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<CR>]], { silent = true })
  --     vim.keymap.set('t', '<C-k>', [[<C-\><C-n>:lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<CR>]], { silent = true })
  --     vim.keymap.set('t', '<C-l>', [[<C-\><C-n>:lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<CR>]], { silent = true })
  --   end,
  -- },
}

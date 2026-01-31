return {
  {
    'NickvanDyke/opencode.nvim',
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { 'folke/snacks.nvim' },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        provider = {
          enabled = 'tmux',
        },
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      vim.keymap.set({ 'n', 'x' }, '<leader>at', function()
        require('opencode').prompt('@this ' .. '\n')
        require('sidekick.cli').focus()
      end, { desc = 'Ask opencode' })

      vim.keymap.set({ 'n' }, '<leader>ab', function()
        require('opencode').prompt('@buffer ' .. '\n')
        require('sidekick.cli').focus()
      end, { desc = 'Send buffer to opencode' })

      vim.keymap.set({ 'n', 'x' }, 'go', function()
        return require('opencode').operator '@this '
      end, { expr = true, desc = 'Add range to opencode' })

      vim.keymap.set('n', 'goo', function()
        return require('opencode').operator '@this ' .. '_'
      end, { expr = true, desc = 'Add line to opencode' })

      -- vim.keymap.set('n', '<S-C-u>', function()
      --   require('opencode').command 'session.half.page.up'
      -- end, { desc = 'opencode half page up' })
      --
      -- vim.keymap.set('n', '<S-C-d>', function()
      --   require('opencode').command 'session.half.page.down'
      -- end, { desc = 'opencode half page down' })
    end,
  },
}

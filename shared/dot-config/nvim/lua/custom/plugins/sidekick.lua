return {
  {
    'folke/sidekick.nvim',
    opts = {
      -- add any options here
      nes = {
        enabled = false,
      },
      cli = {
        mux = {
          backend = 'tmux',
          enabled = true,
        },
        tools = {
          opencode = {
            cmd = { 'opencode', '--port' },
          },
        },
      },
    },
    keys = {
      {
        '<c-.>',
        function()
          require('sidekick.cli').focus()
        end,
        mode = { 'n', 'x', 'i', 't' },
        desc = 'Sidekick Switch Focus',
      },
    },
  },
}

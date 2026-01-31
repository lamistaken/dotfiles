local desired_layout = 'right'

local function show_in_layout(layout)
  desired_layout = layout
  local Terminal = require 'sidekick.cli.terminal'
  local found = false
  for _, t in pairs(Terminal.terminals) do
    found = true
    if t:is_open() then
      t:hide()
    else
      t.opts.layout = layout
      t:focus()
    end
  end
  if not found then
    require('sidekick.cli').focus()
  end
end

return {
  {
    'folke/sidekick.nvim',
    opts = {
      -- add any options here
      nes = {
        enabled = false,
      },
      cli = {
        win = {
          config = function(terminal)
            terminal.opts.layout = desired_layout
          end,
          keys = {
            prompt = false,
          },
        },
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
          show_in_layout 'right'
        end,
        mode = { 'n', 'x', 'i', 't' },
        desc = 'Sidekick Split (right)',
      },
      {
        '<c-;>',
        function()
          show_in_layout 'float'
        end,
        mode = { 'n', 'x', 'i', 't' },
        desc = 'Sidekick Float',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'n', 'x' },
        desc = 'Send This',
      },
      {
        '<leader>ab',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        mode = { 'n' },
        desc = 'Send Buffer',
      },
    },
  },
}

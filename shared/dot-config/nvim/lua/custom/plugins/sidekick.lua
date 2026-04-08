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
    init = function()
      vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
        callback = function()
          if vim.bo.filetype == 'sidekick_terminal' and vim.bo.buftype == 'terminal' then
            vim.cmd('startinsert')
          end
        end,
      })
    end,
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
            -- Disable sidekick's built-in nav keymaps so that
            -- nvim-tmux-navigation's terminal mode maps handle C-hjkl
            -- (allows crossing into tmux panes, not just neovim windows)
            nav_left = false,
            nav_down = false,
            nav_up = false,
            nav_right = false,
          },
        },
        mux = {
          backend = 'tmux',
          enabled = true,
        },
        tools = {
          aider = nil,
          gemini = nil,
          -- opencode = {
          --   cmd = { 'opencode', '--port' },
          --   is_proc = 'opencode --port',
          -- },
          opencode_sbx = {
            cmd = { 'sb', '--no-pull', '--agent', 'opencode', '--workspace', vim.fn.getcwd(), 'repos', 'local' },
            is_proc = 'sandbox exec.*opencode$',
          },
          claude = {
            cmd = { 'sb', '--no-pull', '--agent', 'claude', '--workspace', vim.fn.getcwd(), 'repos', 'local', '--', '--model', 'opusplan' },
            is_proc = 'sandbox exec.*claude$',
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
        '<leader>ac',
        function()
          require('sidekick.cli').close()
        end,
        mode = { 'n' },
        desc = 'Select AI',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        mode = { 'n' },
        desc = 'Select AI',
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
      {
        '<C-M-u>',
        function()
          local Terminal = require 'sidekick.cli.terminal'
          for _, t in pairs(Terminal.terminals) do
            if t:is_open() then
              if t.tool.name == 'claude' then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-u>]], true, false, true), 'n', false)
              else
                vim.api.nvim_chan_send(t.job, '\x1b\x15')
              end
              return
            end
          end
        end,
        mode = { 't' },
        desc = 'Scroll up (terminal)',
      },
      {
        '<C-M-d>',
        function()
          local Terminal = require 'sidekick.cli.terminal'
          for _, t in pairs(Terminal.terminals) do
            if t:is_open() then
              if t.tool.name == 'claude' then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n><C-d>]], true, false, true), 'n', false)
              else
                vim.api.nvim_chan_send(t.job, '\x1b\x04')
              end
              return
            end
          end
        end,
        mode = { 't' },
        desc = 'Scroll down (terminal)',
      },
    },
  },
}

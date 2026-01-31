return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<Leader>gd', '<cmd>DiffviewFileHistory --base=LOCAL %<CR>', desc = 'Diff File' },
      { '<Leader>gv', '<cmd>DiffviewOpen<CR>', desc = 'Diff View' },
    },
    opts = function()
      local actions = require 'diffview.actions'
      vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
        group = vim.api.nvim_create_augroup('rafi_diffview', {}),
        pattern = 'diffview:///panels/*',
        callback = function()
          vim.opt_local.cursorline = true
          vim.opt_local.winhighlight = 'CursorLine:WildMenu'
        end,
      })

      vim.opt.fillchars:append { diff = '╱' }
      vim.api.nvim_set_hl(0, 'CustomDiffChangeOld', { bg = '#25171C' })
      vim.api.nvim_set_hl(0, 'CustomDiffChangeNew', { bg = '#12261E' })

      return {

        hooks = {
          diff_buf_win_enter = function(bufnr, winid, ctx)
            if ctx.layout_name:match '^diff2' then
              if ctx.symbol == 'a' then
                vim.opt_local.winhl = table.concat({
                  'DiffText:DiffviewDiffDelete',
                  'DiffAdd:DiffviewDiffAddAsDelete',
                  'DiffDelete:DiffviewDiffDelete',
                  'DiffChange:CustomDiffChangeOld',
                }, ',')
              elseif ctx.symbol == 'b' then
                vim.opt_local.winhl = table.concat({
                  'DiffDelete:DiffviewDiffDelete',
                  'DiffChange:CustomDiffChangeNew',
                }, ',')
              end
            end
          end,
        },
        enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
        default_args = {
          DiffviewOpen = { '--imply-local' },
        },
        file_panel = {
          win_config = {
            width = 40,
          },
        },
        keymaps = {
          view = {
            { 'n', 'q', actions.close },
            { 'n', '<Tab>', actions.select_next_entry },
            { 'n', '<S-Tab>', actions.select_prev_entry },
            { 'n', '<LocalLeader>e', actions.toggle_files },
          },
          file_panel = {
            { 'n', 'q', actions.close },
            { 'n', 'h', actions.prev_entry },
            { 'n', 'o', actions.focus_entry },
            { 'n', 'gf', actions.goto_file },
            { 'n', 'sg', actions.goto_file_split },
            { 'n', 'st', actions.goto_file_tab },
            { 'n', '<C-r>', actions.refresh_files },
            { 'n', '<LocalLeader>e', actions.toggle_files },
          },
          file_history_panel = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>' },
            { 'n', 'o', actions.focus_entry },
            { 'n', 'O', actions.open_in_diffview },
          },
        },
      }
    end,
  },
  {
    'almo7aya/openingh.nvim',
    cmd = {
      'OpenInGHRepo',
      'OpenInGHFile',
      'OpenInGHFileLines',
    },
    keys = {
      { '<leader>gr', '<cmd>:OpenInGHRepo<cr>', desc = 'Open in GitHub' },
      { '<leader>gf', '<cmd>:OpenInGHFile<cr>', desc = 'Open File in GitHub' },
      { '<leader>gl', '<cmd>:OpenInGHFileLines<cr>', desc = 'Open File Lines in GitHub' },
    },
  },
  {
    'rafikdraoui/jj-diffconflicts',
  },
  {
    'julienvincent/hunk.nvim',
    cmd = { 'DiffEditor' },
    config = function()
      require('hunk').setup()
    end,
  },
  {
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
    opts = {
      explorer = {
        view_mode = 'tree',
        file_filter = {
          ignore = { '**/*.png', '**/samples-server' },
        },
      },
      keymaps = {
        view = {
          next_file = '<tab>',
          prev_file = '<s-tab>',
          open_in_prev_tab = 'gf',
        },
      },
    },
    config = function(_, opts)
      require('codediff').setup(opts)

      -- Fix: codediff leaks scrollbind to windows outside the diff tab.
      -- When entering a non-codediff tab, reset scrollbind on all its windows.
      -- This handles both closing the diff and navigating away (e.g. gf).
      vim.api.nvim_create_autocmd('TabEnter', {
        callback = function()
          vim.schedule(function()
            local tab = vim.api.nvim_get_current_tabpage()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              if vim.w[win].codediff_restore then
                return
              end
            end
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              vim.wo[win].scrollbind = false
            end
          end)
        end,
      })
    end,
  },
  {
    'nicolasgb/jj.nvim',
    branch = 'main',
    dependencies = {
      'folke/snacks.nvim', -- Optional, only needed if you use pickers
      'esmuellert/codediff.nvim',
      'sindrets/diffview.nvim',
    },
    config = function()
      require('jj').setup {
        diff = {
          backend = 'codediff',
        },
      }
    end,
    cmd = { 'Jdiff' },
    keys = {
      {
        '<leader>jj',
        '<cmd>J<cr>',
        desc = 'Jujutsu Overview',
      },
      {
        '<leader>ja',
        '<cmd>J annotate_line<cr>',
        desc = 'Jujutsu Annotate Line',
      },
      {
        '<leader>jA',
        '<cmd>J annotate<cr>',
        desc = 'Jujutsu Annotate File',
      },
      {
        '<leader>jl',
        '<cmd>J log<cr>',
        desc = 'Jujutsu Log',
      },
      {
        '<leader>jd',
        function()
          require('snacks.input').input({ prompt = 'From revision', default = 'trunk()' }, function(value)
            require('jj.diff').diff_revisions { left = value, right = '@' }
          end)
        end,
        desc = 'Jujutsu Diff',
      },
      {
        '<leader>jf',
        function()
          require('jj.picker').file_history()
        end,
        desc = 'Jujutsu File History',
      },
    },
  },
}

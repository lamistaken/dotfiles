return {
  -- Lazy
  {
    'dlyongemallo/diffview-plus.nvim',
    version = '*',
    -- optional: lazy-load on command
    cmd = {
      'DiffviewOpen',
      'DiffviewToggle',
      'DiffviewFileHistory',
      'DiffviewDiffFiles',
      'DiffviewLog',
    },
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
      diff = {
        compute_moves = true,
      },
      explorer = {
        view_mode = 'tree',
        file_filter = {
          ignore = { '**/*.png', '**/samples-server', '.jj/**' },
        },
      },
      keymaps = {
        view = {
          next_file = '<tab>',
          prev_file = '<s-tab>',
          open_in_prev_tab = '<Plug>(CodeDiffOpenPrevTab)',
        },
      },
    },
    config = function(_, opts)
      require('codediff').setup(opts)

      -- Custom gf: close jj log window (winfixbuf terminal) before delegating
      -- to codediff's built-in open_in_prev_tab handler.
      vim.api.nvim_create_autocmd('BufWinEnter', {
        callback = function(ev)
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
              return
            end
            local ok, lifecycle = pcall(require, 'codediff.ui.lifecycle')
            if not ok then
              return
            end
            local tabpage = vim.api.nvim_get_current_tabpage()
            if not lifecycle.get_session(tabpage) then
              return
            end

            vim.keymap.set('n', 'gf', function()
              local ok, terminal = pcall(require, 'jj.ui.terminal')
              if ok and terminal.state and terminal.state.buf and vim.api.nvim_buf_is_valid(terminal.state.buf) then
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  if vim.api.nvim_win_get_buf(win) == terminal.state.buf then
                    vim.api.nvim_win_close(win, true)
                  end
                end
              end
              local keys = vim.api.nvim_replace_termcodes('<Plug>(CodeDiffOpenPrevTab)', true, true, true)
              vim.api.nvim_feedkeys(keys, 'm', false)
            end, { buffer = ev.buf, desc = 'Open in prev tab (close jj log first)' })
          end)
        end,
      })

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
          backend = 'diffbandit',
        },
      }

      local jjdiff = require 'jj.diff'
      local jjutils = require 'jj.utils'

      -- diffbandit's jj branch detects .jj and runs a native jj backend that
      -- accepts revsets directly, so we only route jj.nvim's diff hooks to it.
      -- The diffbandit API returns (nil, err) instead of notifying.
      local function report(ok, err)
        if not ok and err then
          vim.notify('diffbandit: ' .. tostring(err), vim.log.levels.WARN)
        end
      end

      local function compare(opts)
        report(require('diffbandit').git_compare(opts.left, opts.right, { direct = true }))
      end

      jjdiff.register_backend('diffbandit', {
        -- `D` on a single revision -> show what that commit changed
        show_revision = function(opts)
          local db = require 'diffbandit'
          -- Working-copy revision: diff @- -> live @ so the right pane holds
          -- editable files (LSP works). Otherwise show the commit read-only.
          if jjutils.get_commit_id(opts.rev) == jjutils.get_current_commit_id() then
            report(db.git { mode = 'all', base = opts.rev .. '-' })
          else
            report(db.git_commit(opts.rev))
          end
        end,

        -- `D` on a multi-selection / history -> compare the endpoints directly
        diff_revisions = compare,
        diff_history_revisions = compare,
      })
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
  {
    'oug-t/difi.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>df', ':Difi<CR>', desc = 'Toggle Difi' },
    },
  },
  {
    'CoreyKaylor/diffbandit.nvim',
    branch = 'jj',
    config = function()
      require('diffbandit').setup {
        diff = {
          ignore_whitespace = false,
        },
        navigation = {
          snap_key = 'gs',
        },
        merge = {
          keys = {
            snap = 'gs',
          },
        },
        actions = {
          keys = {
            toggle_stage = false,
          },
          staged_indicator = {
            unstaged = '',
            staged = '',
          },
        },
      }

      local review_group = vim.api.nvim_create_augroup('DiffBanditReview', { clear = true })

      -- gf on the diff pane + window-option normalization for foreign windows.
      vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
        group = review_group,
        callback = function()
          local ok, state = pcall(require, 'diffbandit.state')
          if not ok then
            return
          end
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_get_current_buf()

          local here = state.sessions[vim.api.nvim_get_current_tabpage()]

          -- Auto-snap toggle on either content pane. While enabled (nil == on by
          -- default) the CursorHold autocmd below snaps the opposite pane to the
          -- focused cursor once it goes idle; gS flips the per-session flag. We
          -- deliberately do NOT map <C-d>/<C-u> here so neoscroll's smooth
          -- scrolling stays intact.
          if here and ((buf == here.left_buf and win == here.left_win) or (buf == here.right_buf and win == here.right_win)) then
            vim.keymap.set('n', 'gS', function()
              here._auto_snap = not (here._auto_snap ~= false)
              vim.notify('DiffBandit auto-snap ' .. (here._auto_snap and 'ON' or 'OFF'))
              if here._auto_snap then
                pcall(function()
                  here:snap_to_cursor()
                end)
              end
            end, { buffer = buf, desc = 'DiffBandit: toggle auto-snap' })
          end

          -- gf keymap on the diff's own right pane (open real file in new tab).
          if here and buf == here.right_buf and win == here.right_win then
            vim.keymap.set('n', 'gf', function()
              local path = here.right and here.right.path
              if not path or path == '' then
                return
              end
              -- diffbandit created this buffer (bufadd) when the file wasn't
              -- already open, so its dispose would delete it on `q` — taking this
              -- gf tab down too. Adopt it (clear the created flag) so
              -- cleanup_created_buffer's guard skips it; the review tab still
              -- closes normally via tabclose, this buffer just survives.
              if here.right and here.right.editable then
                here.right.editable.created_by_diffbandit = false
              end
              local line = vim.api.nvim_win_get_cursor(here.right_win)[1]
              vim.cmd('tabedit ' .. vim.fn.fnameescape(path))
              pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
            end, { buffer = buf, desc = 'DiffBandit: open file in new tab' })
            return
          end

          -- Foreign window showing a live diffbandit right buffer: restore the
          -- window-local options diffbandit stripped on its source window (maps
          -- and paint are handled by the suspend/resume autocmds above).
          for _, session in pairs(state.sessions) do
            if buf == session.right_buf and win ~= session.right_win then
              for _, opt in ipairs { 'number', 'relativenumber', 'signcolumn', 'foldcolumn', 'cursorline', 'list', 'wrap' } do
                vim.wo[win][opt] = vim.go[opt]
              end
              if (vim.wo[win].winhighlight or ''):find 'DiffBandit' then
                vim.wo[win].winhighlight = ''
              end
              break
            end
          end
        end,
      })

      -- Auto-snap: when enabled (default on; toggled per session with gS), snap
      -- the opposite pane to the focused cursor after it goes idle
      vim.api.nvim_create_autocmd('CursorHold', {
        group = review_group,
        callback = function()
          local ok, state = pcall(require, 'diffbandit.state')
          if not ok then
            return
          end
          local s = state.sessions[vim.api.nvim_get_current_tabpage()]
          if not s or s.disposed or s._auto_snap == false then
            return
          end
          if s.syncing_scroll or s.rendering_viewport then
            return
          end
          local win = vim.api.nvim_get_current_win()
          if win ~= s.left_win and win ~= s.right_win then
            return
          end
          pcall(function()
            s:snap_to_cursor()
          end)
        end,
      })
    end,
  },
}

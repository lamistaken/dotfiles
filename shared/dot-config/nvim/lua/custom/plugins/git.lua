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

      -- Files jj considers changed for a revset range, as git pathspecs.
      -- Restricts diffbandit to jj's view, dropping submodule/worktree noise.
      local function jj_paths(args)
        local cmd = { 'jj', 'diff', '-T', 'path ++ "\\n"' }
        vim.list_extend(cmd, args)
        local files = vim.tbl_filter(function(f)
          return f ~= ''
        end, vim.fn.systemlist(cmd))
        if vim.v.shell_error ~= 0 then
          return nil
        end
        return files
      end

      jjdiff.register_backend('diffbandit', {
        -- `D` on a single revision -> show what that commit changed
        show_revision = function(opts)
          local commit_id = jjutils.get_commit_id(opts.rev)
          if not commit_id then
            return
          end
          local files = jj_paths { '-r', opts.rev }
          if not files or #files == 0 then
            vim.notify('diffbandit: no jj changes for ' .. opts.rev, vim.log.levels.WARN)
            return
          end
          -- Working-copy revision: diff base..worktree so the right pane holds
          -- live files (LSP works). Otherwise show the commit read-only.
          if commit_id == jjutils.get_current_commit_id() then
            local base = jjutils.get_commit_id(opts.rev .. '-')
            if base then
              require('diffbandit').git {
                mode = 'all',
                base = base,
                pathspecs = files,
                include_untracked = false,
              }
              return
            end
          end
          require('diffbandit').git_commit(commit_id, { pathspecs = files })
        end,

        -- `D` on a multi-selection -> compare the two endpoints directly
        diff_revisions = function(opts)
          local left = jjutils.get_commit_id(opts.left)
          local right = jjutils.get_commit_id(opts.right)
          if not (left and right) then
            return
          end
          local files = jj_paths { '--from', opts.left, '--to', opts.right }
          if not files or #files == 0 then
            vim.notify('diffbandit: no jj changes for ' .. opts.left .. '..' .. opts.right, vim.log.levels.WARN)
            return
          end
          require('diffbandit').git_compare(left, right, { direct = true, pathspecs = files })
        end,

        -- History variant -> same endpoints, direct compare
        diff_history_revisions = function(opts)
          local left = jjutils.get_commit_id(opts.left)
          local right = jjutils.get_commit_id(opts.right)
          if not (left and right) then
            return
          end
          local files = jj_paths { '--from', opts.left, '--to', opts.right }
          if not files or #files == 0 then
            vim.notify('diffbandit: no jj changes for ' .. opts.left .. '..' .. opts.right, vim.log.levels.WARN)
            return
          end
          require('diffbandit').git_compare(left, right, { direct = true, pathspecs = files })
        end,
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
      -- Context-aware: Syncs with CLI target (e.g. main) or defaults to HEAD
      { '<leader>df', ':Difi<CR>', desc = 'Toggle Difi' },
    },
  },
  {
    'CoreyKaylor/diffbandit.nvim',
    config = function()
      require('diffbandit').setup {
        diff = {
          ignore_whitespace = false,
        },
        navigation = {
          initial_focus = 'right',
          align_on_jump = true,
          align_strategy = 'change_top',
          document_keys = {
            top = '[d',
            bottom = ']d',
          },
          snap_key = ']s',
        },
        git = {
          default_mode = 'all',
          include_untracked = true,
          find_renames = true,
          file_keys = {
            next = '<Tab>',
            prev = '<S-Tab>',
          },
          panel = {
            width = 42,
            commit_height = 10,
            preview_on_cursor = false,
            keys = {
              toggle_stage = false,
              focus_diff = '<CR>',
              focus_panel = 'C',
              focus_commit = false,
              file_actions = false,
              toggle_amend = false,
              refresh = 'R',
              close = 'q',
            },
            staged_indicator = {
              unstaged = '',
              partial = '',
              staged = '',
            },
          },
        },
        merge = {
          result_initial_content = 'base',
          auto_apply_non_conflicting = false,
          resolve_on_write = true,
          line_endings = {
            warn = true,
          },
          keys = {
            next_conflict = ']c',
            prev_conflict = '[c',
            accept_local = '>>',
            accept_remote = '<<',
            accept_both = 'gb',
            apply_non_conflicting = 'gA',
            focus_panel = 'C',
            snap = ']s',
            toggle_panel = 'gzp',
            toggle_local = 'gzh',
            toggle_remote = 'gzl',
            show_all = 'gza',
            close = 'q',
          },
        },
        folder = {
          gutter_width = 7,
          columns = {
            size = true,
            modified = true,
          },
          compare = {
            mode = 'digest',
            backend = 'auto',
            batch_size = 64,
            max_concurrency = 2,
            debounce_ms = 50,
          },
          filters = {
            include = {},
            exclude = {},
          },
          keys = {
            open = '<CR>',
            alternate_open = 'o',
            toggle_expand = '<Space>',
            alternate_toggle_expand = 'za',
            expand_all = 'zR',
            collapse_all = 'zM',
            next_diff = ']c',
            prev_diff = '[c',
            refresh = 'R',
            filter = 's',
            close = 'q',
          },
        },
        ui = {
          -- Connector core width. Defaults fix the gutter at 9 columns
          -- (min == max). Raise connector_max_width to allow once-per-document
          -- pressure expansion; set both equal for a different fixed width.
          connector_width = 9,
          connector_max_width = 9,
          scroll_debounce_ms = 16,
          split_blend = 0.3,
          overview = {
            enabled = true,
            width = 1,
            cursor = true,
          },
          status = {
            enabled = false,
            icons = 'auto',
          },
          theme = {
            auto_refresh = true,
            semantic_blend = 0.3,
            change_emphasis_strength = 0.16,
            min_background_delta = 0.08,
            colors = {
              add = nil,
              delete = nil,
              change = nil,
              change_emphasis = nil,
            },
            highlights = {},
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

      vim.api.nvim_create_user_command('DiffBanditReview', function(o)
        local base, target = o.fargs[1], o.fargs[2] or '@'
        local files = vim.tbl_filter(function(f)
          return f ~= ''
        end, vim.fn.systemlist { 'jj', 'diff', '--from', base, '--to', target, '-T', 'path ++ "\\n"' })
        if vim.v.shell_error ~= 0 or #files == 0 then
          vim.notify('DiffBanditReview: no jj changes (' .. base .. '..' .. target .. ')', vim.log.levels.WARN)
          return
        end
        require('diffbandit').git { mode = 'all', base = base, pathspecs = files, include_untracked = false }
      end, { nargs = '+' })

      local review_group = vim.api.nvim_create_augroup('DiffBanditReviewTab', { clear = true })

      -- Suspend: while a diff tab is unfocused, strip its buffer-local maps and
      -- diff paint from the shared real buffer. During TabLeave the current
      -- tabpage is still the one being left, so this fires exactly when leaving a
      -- diff tab (including via gf's :tabedit).
      vim.api.nvim_create_autocmd('TabLeave', {
        group = review_group,
        callback = function()
          local ok, state = pcall(require, 'diffbandit.state')
          if not ok then
            return
          end
          local s = state.sessions[vim.api.nvim_get_current_tabpage()]
          if not s or s.disposed then
            return
          end
          pcall(function()
            s:clear_keymaps()
          end)
          pcall(function()
            s:clear_buffer_paint_namespaces(s.right_buf)
          end)
        end,
      })

      -- Resume: reinstall maps and repaint the diff when its tab regains focus.
      vim.api.nvim_create_autocmd('TabEnter', {
        group = review_group,
        callback = function()
          vim.schedule(function()
            local ok, state = pcall(require, 'diffbandit.state')
            if not ok then
              return
            end
            local s = state.sessions[vim.api.nvim_get_current_tabpage()]
            if not s or s.disposed then
              return
            end
            pcall(function()
              s:setup_keymaps()
            end)
            pcall(function()
              s:request_viewport_rerender()
            end)
          end)
        end,
      })

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
          -- default) the CursorMoved autocmd below keeps the opposite pane aligned
          -- to the focused cursor; ]S flips the per-session flag. We deliberately
          -- do NOT map <C-d>/<C-u> here so neoscroll's smooth scrolling stays
          -- intact — snapping rides its per-line CursorMoved steps instead.
          if here and ((buf == here.left_buf and win == here.left_win) or (buf == here.right_buf and win == here.right_win)) then
            vim.keymap.set('n', ']S', function()
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

      -- Auto-snap: when enabled (default on; toggled per session with ]S), snap
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

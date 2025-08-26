return {
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        formatters = {
          file = {
            truncate = 120,
          },
        },
      },
      notifier = {
        top_down = false,
      },
      dim = {},
      image = {},
    },
    keys = {
      {
        '<leader>n',
        function()
          local snacks = require 'snacks'
          snacks.notifier.show_history()
        end,
        desc = 'Show Notifications',
      },
      {
        '<leader>sn',
        function()
          local snacks = require 'snacks'
          return snacks.picker {
            items = {
              {
                file = 'explainError',
                text = 'explainError',
                additional = 'current',
                idx = 1,
                score = 0,
                count = 2,
              },
              {
                file = 'renderDiagnostic',
                text = 'renderDiagnostic',
                additional = 'current',
                idx = 2,
                score = 0,
                count = 2,
              },
              {
                file = 'openDocs',
                text = 'openDocs',
                additional = '',
                idx = 3,
                score = 0,
                count = 1,
              },
            },
            matcher = {
              sort_empty = true,
              ignorecase = true,
            },
            preview = false,
            layout = { preset = 'select' },
            confirm = function(picker, item)
              picker:close()

              local params = { item.file }
              if item.additional ~= '' then
                table.insert(params, item.additional)
              end

              for i = 1, item.count do
                vim.cmd.RustLsp(params)
              end
            end,
          }
        end,
        desc = 'Buffers',
      },
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'LazyGit',
      },
      {
        '<leader>,',
        function()
          require('snacks').picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>:',
        function()
          require('snacks').picker.command_history()
        end,
        desc = 'Command History',
      },
      {
        '<leader><space>',
        function()
          require('snacks').picker.smart { hidden = true, filter = { cwd = true } }
        end,
        desc = 'Find Files',
      },
      {
        '<leader>sR',
        function()
          require('snacks').picker.recent { hidden = true, filter = { cwd = true } }
        end,
        desc = 'Recent',
      },
      {
        '<leader>gc',
        function()
          require('snacks').picker.git_log()
        end,
        desc = 'Git Log',
      },
      {
        '<leader>gs',
        function()
          require('snacks').picker.git_status()
        end,
        desc = 'Git Status',
      },
      {
        '<leader>s/',
        function()
          require('snacks').picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>sB',
        function()
          require('snacks').picker.grep_buffers()
        end,
        desc = 'Grep Open Buffers',
      },
      {
        '<leader>sg',
        function()
          require('snacks').picker.grep { hidden = true }
        end,
        desc = 'Grep',
      },
      {
        '<leader>sw',
        function()
          require('snacks').picker.grep_word { hidden = true }
        end,
        desc = 'Visual selection or word',
        mode = { 'n', 'x' },
      },
      {
        '<leader>s"',
        function()
          require('snacks').picker.registers()
        end,
        desc = 'Registers',
      },
      {
        '<leader>sc',
        function()
          require('snacks').picker.commands()
        end,
        desc = 'Commands',
      },
      {
        '<leader>sd',
        function()
          require('snacks').picker.diagnostics()
        end,
        desc = 'Diagnostics',
      },
      {
        '<leader>sh',
        function()
          require('snacks').picker.help()
        end,
        desc = 'Help Pages',
      },
      {
        '<leader>sH',
        function()
          require('snacks').picker.highlights()
        end,
        desc = 'Highlights',
      },
      {
        '<leader>sj',
        function()
          require('snacks').picker.jumps()
        end,
        desc = 'Jumps',
      },
      {
        '<leader>sk',
        function()
          require('snacks').picker.keymaps()
        end,
        desc = 'Keymaps',
      },
      {
        '<leader>sl',
        function()
          require('snacks').picker.loclist()
        end,
        desc = 'Location List',
      },
      {
        '<leader>sM',
        function()
          require('snacks').picker.man()
        end,
        desc = 'Man Pages',
      },
      {
        '<leader>sm',
        function()
          require('snacks').picker.marks()
        end,
        desc = 'Marks',
      },
      {
        '<leader>sr',
        function()
          require('snacks').picker.resume()
        end,
        desc = 'Resume',
      },
      {
        '<leader>sq',
        function()
          require('snacks').picker.qflist()
        end,
        desc = 'Quickfix List',
      },
      {
        '<leader>uC',
        function()
          require('snacks').picker.colorschemes()
        end,
        desc = 'Colorschemes',
      },
      {
        'grd',
        function()
          require('snacks').picker.lsp_definitions()
        end,
        desc = '[G]oto [D]eclaration',
      },
      {
        'grr',
        function()
          require('snacks').picker.lsp_references()
        end,
        nowait = true,
        desc = '[G]oto [R]eferences',
      },
      {
        'gri',
        function()
          require('snacks').picker.lsp_implementations()
        end,
        desc = '[G]oto [I]mplementation',
      },
      {
        'grt',
        function()
          require('snacks').picker.lsp_type_definitions()
        end,
        desc = '[G]oto [T]ype Definition',
      },
      {
        'gO',
        function()
          require('snacks').picker.lsp_symbols()
        end,
        desc = 'LSP Document Symbols',
      },
      {
        'gW',
        function()
          require('snacks').picker.lsp_workspace_symbols()
        end,
        desc = 'LSP Workspace Symbols',
      },
      {
        '<leader>sz',
        function()
          local snacks = require 'snacks'
          snacks.picker.zoxide {
            confirm = function(picker, item)
              picker:close()
              snacks.picker.files { hidden = true, cwd = item.file }
            end,
          }
        end,
        desc = 'Zoxide',
      },
      {
        '<leader>sp',
        function()
          require('snacks').picker.pickers()
        end,
        desc = 'Pickers',
      },
      {
        '<leader>sp',
        function()
          require('snacks').picker.pickers()
        end,
        desc = 'Pickers',
      },
    },
    init = function()
      local Snacks = require 'snacks'

      -- Toggle diagnostics
      Snacks.toggle({
        name = 'Diagnostics',
        get = vim.diagnostic.is_enabled,
        set = function(state)
          vim.diagnostic.enable(state)
        end,
      }):map '<leader>td'

      -- Toggle the profiler
      Snacks.toggle.profiler():map '<leader>pp'

      -- Toggle the profiler highlights
      Snacks.toggle.profiler_highlights():map '<leader>ph'

      -- Toggle spell check (harper)
      Snacks.toggle({
        name = 'Harper LS',
        color = {
          enabled = 'azure',
          disabled = 'orange',
        },
        get = function()
          local buf = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients { bufnr = buf, name = 'harper_ls' }
          if clients == nil or #clients == 0 then
            return false
          end
          return vim.lsp.buf_is_attached(buf, clients[1].id)
        end,
        set = function(state)
          local buf = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_clients { name = 'harper_ls' }
          if #clients == 0 then
            return
          end

          if state then
            vim.lsp.buf_attach_client(buf, clients[1].id)
          else
            vim.lsp.buf_detach_client(buf, clients[1].id)
          end
        end,
      }):map '<leader>tg'

      Snacks.toggle({
        name = 'Inlay Hints',
        get = vim.lsp.inlay_hint.is_enabled,
        set = function(state)
          vim.lsp.inlay_hint.enable(state)
        end,
      }):map '<leader>th'
    end,
  },
}

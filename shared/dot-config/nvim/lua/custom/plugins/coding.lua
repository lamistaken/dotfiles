-- Keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>gra', vim.lsp.buf.code_action, { remap = false, desc = '[G]oto [C]ode [A]ctions' })
vim.keymap.set('n', '<leader>grn', vim.lsp.buf.rename, { remap = false, desc = '[R]e[n]ame' })

-- Used for scrollable kind scoring function.
local idx = 1
local sf_size = 4

local M = {
  {
    'saghen/blink.cmp',
    version = '*',
    build = 'cargo build --release',
    opts_extend = {
      'sources.completion.enabled_providers',
      'sources.compat',
      'sources.default',
    },
    dependencies = {
      'rafamadriz/friendly-snippets',
      -- add blink.compat to dependencies
      {
        'saghen/blink.compat',
        optional = true, -- make optional so it's only enabled if any extras need it
        opts = {},
        version = '*',
      },
    },
    event = 'InsertEnter',
    opts = {
      fuzzy = {
        sorts = {
          -- Scrollable kind scoring function <C-.> to scroll.
          function(a, b)
            if a.kind == nil or b.kind == nil or a.kind == b.kind then
              return
            end

            if idx == 1 then
              -- Prioritize nothing.
              return
            end

            if idx == 2 then
              -- Prioritize methods and functions.
              return a.kind == 2 or a.kind == 3
            end

            if idx == 3 then
              -- Prioritize fields
              return a.kind == 5
            end

            if idx == 4 then
              -- Prioritize fields, variables, and struct.
              return a.kind == 6 or a.kind == 22
            end
          end,
          -- defaults
          'score',
          'sort_text',
        },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          border = 'single',
          draw = {
            treesitter = { 'lsp' },
            columns = {
              { 'kind_icon', 'kind' },
              { 'label', 'label_description', gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = 'single' },
        },
        ghost_text = {
          enabled = false,
          -- show_with_menu = false,
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
      },
      signature = { enabled = false },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          markdown = {
            name = 'RenderMarkdown',
            module = 'render-markdown.integ.blink',
            fallbacks = { 'lsp' },
          },
        },
      },
      keymap = {
        preset = 'default',
        ['<C-space>'] = {
          function()
            idx = 1
          end,
          'show',
          'show_documentation',
          'hide_documentation',
        },
        ['<C-y>'] = {
          function()
            idx = 1
          end,
          'select_and_accept',
        },
        ['<C-.>'] = {
          function(cmp)
            cmp.cancel {
              callback = function()
                idx = idx + 1
                if idx > sf_size then
                  idx = 1
                end
                cmp.show()
              end,
            }
          end,
        },
        ['<M-l>'] = {
          function()
            require('copilot.suggestion').accept()
          end,
        },
        ['<M-[>'] = {
          function()
            require('copilot.suggestion').next()
          end,
        },
        ['<M-]>'] = {
          function()
            require('copilot.suggestion').prev()
          end,
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    dependencies = {},
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true }
        end,
        mode = '',
        desc = 'Format buffer',
      },
      {
        '<leader>tf',
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          require('noice').redirect(function()
            print('Autoformat Enabled: ' .. tostring(vim.g.disable_autoformat))
          end, { view = 'notify' })
        end,
        desc = 'Toggle autoformat',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'gofumpt', 'goimports' },
        sql = { 'sqlfluff' },
        sh = { 'shfmt' },
        yaml = { 'yamlfmt' },
        json = { 'jq' },
        hcl = { 'packer_fmt' },
        terraform = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
        tf = { 'terraform_fmt' },
        proto = { 'buf' },
        rust = { 'rustfmt' },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
    },
  },
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'delve', 'gomodifytags', 'impl' } },
  },
  -- This doesn't seem to be working with none-ls :(
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('refactoring').setup()
    end,
  },
  {
    'nvimtools/none-ls.nvim',
    dependencies = { 'ThePrimeagen/refactoring.nvim' },
    opts = function(_, opts)
      local nls = require 'null-ls'
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.gomodifytags,
        nls.builtins.code_actions.impl,
      })
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = 'make install_jsregexp',
  },
  { 'onsails/lspkind.nvim' },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'williamboman/mason.nvim',
      },
      {
        'leoluz/nvim-dap-go',
        opts = {},
        config = function()
          require('dap-go').setup {
            dap_configurations = {
              {
                type = 'go',
                name = 'Attach remote',
                mode = 'remote',
                request = 'attach',
              },
            },
            -- delve configurations
            delve = {
              -- the path to the executable dlv which will be used for debugging.
              -- by default, this is the "dlv" executable on your PATH.
              path = 'dlv',
              -- time to wait for delve to initialize the debug session.
              -- default to 20 seconds
              initialize_timeout_sec = 20,
              -- a string that defines the port to start delve debugger.
              -- default to string "${port}" which instructs nvim-dap
              -- to start the process in a random available port.
              -- if you set a port in your debug configuration, its value will be
              -- assigned dynamically.
              port = '60451',
              -- additional args to pass to dlv
              args = {},
              -- the build flags that are passed to delve.
              -- defaults to empty string, but can be used to provide flags
              -- such as "-tags=unit" to make sure the test suite is
              -- compiled during debugging, for example.
              -- passing build flags using args is ineffective, as those are
              -- ignored by delve in dap mode.
              -- avaliable ui interactive function to prompt for arguments get_arguments
              build_flags = {},
              -- whether the dlv process to be created detached or not. there is
              -- an issue on delve versions < 1.24.0 for Windows where this needs to be
              -- set to false, otherwise the dlv server creation will fail.
              -- avaliable ui interactive function to prompt for build flags: get_build_flags
              detached = vim.fn.has 'win32' == 0,
              -- the current working directory to run dlv from, if other than
              -- the current working directory.
              cwd = nil,
            },
            -- options related to running closest test
            tests = {
              -- enables verbosity when running the test.
              verbose = false,
            },
          }
        end,
      },
    },
    keys = {
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Breakpoint Condition',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle Breakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Run/Continue',
      },
      {
        '<leader>dC',
        function()
          require('dap').run_to_cursor()
        end,
        desc = 'Run to Cursor',
      },
      {
        '<leader>dg',
        function()
          require('dap').goto_()
        end,
        desc = 'Go to Line (No Execute)',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step Into',
      },
      {
        '<leader>dj',
        function()
          require('dap').down()
        end,
        desc = 'Down',
      },
      {
        '<leader>dk',
        function()
          require('dap').up()
        end,
        desc = 'Up',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = 'Run Last',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        desc = 'Step Out',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_over()
        end,
        desc = 'Step Over',
      },
      {
        '<leader>dP',
        function()
          require('dap').pause()
        end,
        desc = 'Pause',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
      {
        '<leader>ds',
        function()
          require('dap').session()
        end,
        desc = 'Session',
      },
      {
        '<leader>dt',
        function()
          require('dap').terminate()
        end,
        desc = 'Terminate',
      },
      {
        '<leader>dw',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'Widgets',
      },
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'nvim-neotest/nvim-nio' },
    keys = {
      {
        '<leader>du',
        function()
          require('dapui').toggle {}
        end,
        desc = 'Dap UI',
      },
      {
        '<leader>de',
        function()
          require('dapui').eval()
        end,
        desc = 'Eval',
        mode = { 'n', 'v' },
      },
    },
    opts = {},
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup(opts)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close {}
      end
    end,
  },
}

-- Toggle diagnostic using L and show on save.
local diag_shown = false
vim.keymap.set('n', 'L', function()
  if diag_shown then
    diag_shown = false
    vim.diagnostic.show(nil, nil, nil, { virtual_lines = false })
  else
    diag_shown = true
    vim.diagnostic.show(nil, nil, nil, { virtual_lines = true })
  end
end, { remap = false, desc = 'Show diagnostic' })

return M

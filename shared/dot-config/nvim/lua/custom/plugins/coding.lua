-- Keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>gra', vim.lsp.buf.code_action, { remap = false, desc = '[G]oto [C]ode [A]ctions' })
vim.keymap.set('n', '<leader>grn', vim.lsp.buf.rename, { remap = false, desc = '[R]e[n]ame' })

-- Used for scrollable kind scoring function.
local idx = 1
local sf_size = 4

local M = {
  {
    'neovim/nvim-lspconfig',
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {},
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
  },
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

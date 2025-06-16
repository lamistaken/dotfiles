return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    lazy = false,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'diff',
          'go',
          'hcl',
          'html',
          'json',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'ron',
          'rust',
          'terraform',
          'vim',
          'vimdoc',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      }
    end,
    opts = {},
  },
  {
    'Wansmer/treesj',
    event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
    cmd = { 'TSJToggle' },
    keys = { { 'st', '<cmd>TSJToggle<cr>', desc = 'Split Join Toggle' } },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup {
        use_default_keymaps = false,
      }
    end,
  },
  {
    'gsuuon/tshjkl.nvim',
    opts = {
      -- false to highlight only. Note that enabling this will hide the highlighting of child nodes
      select_current_node = true,
      keymaps = {
        toggle = '<leader>tm',
      },
      marks = {
        parent = {
          virt_text = { { 'h', 'ModeMsg' } },
          virt_text_pos = 'overlay',
        },
        child = {
          virt_text = { { 'l', 'ModeMsg' } },
          virt_text_pos = 'overlay',
        },
        prev = {
          virt_text = { { 'k', 'ModeMsg' } },
          virt_text_pos = 'overlay',
        },
        next = {
          virt_text = { { 'j', 'ModeMsg' } },
          virt_text_pos = 'overlay',
        },
      },
      binds = function(bind, tshjkl)
        bind('<Esc>', function()
          tshjkl.exit(true)
        end)

        bind('q', function()
          tshjkl.exit(true)
        end)

        bind('t', function()
          print(tshjkl.current_node():type())
        end)
      end,
    },
  },
}

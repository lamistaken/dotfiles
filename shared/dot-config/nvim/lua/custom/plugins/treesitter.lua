return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- dependencies = { { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' } },
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      -- ensure basic parser are installed
      local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(parsers)

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then
          return
        end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- enables treesitter based folds
        -- for more info on folds see `:help folds`
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldmethod = 'expr'
        vim.wo.foldlevel = 99
        vim.o.foldlevelstart = 99

        -- enables treesitter based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            -- enable the parser if it is installed
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
            require('nvim-treesitter').install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          else
            -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
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

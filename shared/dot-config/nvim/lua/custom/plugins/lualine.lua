local jj_prefix = ''
local jj_remainder = nil
local jj_running = false

local function parse_jj_output(output)
  output = output:gsub('%s+$', '')

  if output:sub(1, 2) == 'b:' then
    -- Bookmark: entire name is bright, no muted part
    jj_prefix = output:sub(3)
    jj_remainder = nil
  elseif output:sub(1, 2) == 'c:' then
    -- Change ID: parse shortest|full
    local rest = output:sub(3)
    local shortest, full = rest:match '([^|]*)|(.*)'
    if shortest and full then
      jj_prefix = shortest
      jj_remainder = full:sub(#shortest + 1)
    else
      jj_prefix = rest
      jj_remainder = nil
    end
  else
    jj_prefix = ''
    jj_remainder = nil
  end
end

-- Refresh the jj indicator asynchronously so a slow `jj log` (large repos snapshot
-- the whole working copy on every invocation) never blocks Neovim's UI thread.
local function refresh_jj_status()
  if jj_running then
    return
  end
  jj_running = true

  vim.system({
    'jj',
    'log',
    '-r',
    '@',
    '--no-graph',
    '-T',
    'if(bookmarks, "b:" ++ bookmarks.join(","), "c:" ++ change_id.shortest() ++ "|" ++ change_id.short(8))',
  }, { text = true }, function(obj)
    vim.schedule(function()
      jj_running = false
      if obj.code == 0 then
        parse_jj_output(obj.stdout or '')
      else
        jj_prefix = ''
        jj_remainder = nil
      end
      pcall(function()
        require('lualine').refresh()
      end)
    end)
  end)
end

return {
  {
    'SmiteshP/nvim-navic',
    event = 'VeryLazy',
    opts = {
      separator = ' ',
      highlight = true,
      lazy_update_context = true,
      lsp = {
        auto_attach = true,
        preference = { 'gopls' },
      },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    config = function(_, opts)
      -- Debounce so rapid buffer churn coalesces into a single background refresh.
      local schedule_refresh = require('snacks').util.debounce(refresh_jj_status, { ms = 750 })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
        callback = schedule_refresh,
      })
      refresh_jj_status()
      require('lualine').setup(opts)
    end,
    opts = {
      options = {
        { theme = 'seoul256' },
      },
      sections = {
        lualine_b = {
          {
            function()
              return jj_prefix
            end,
            cond = function()
              return jj_prefix ~= ''
            end,
            padding = { left = 1, right = 0 },
            separator = '',
          },
          {
            function()
              return jj_remainder or ''
            end,
            cond = function()
              return jj_remainder ~= nil and jj_remainder ~= ''
            end,
            color = function()
              local comment_hl = vim.api.nvim_get_hl(0, { name = 'Comment' })
              local fg = comment_hl.fg and string.format('#%06x', comment_hl.fg) or nil
              return { fg = fg }
            end,
            padding = { left = 0, right = 1 },
            separator = '',
          },
          'diff',
          'diagnostic',
        },
        lualine_c = {
          {
            'filename',
            path = 1,
          },
          {
            'navic',
          },
        },
        -- lualine_x = {
        --   {
        --     require('noice').api.statusline.mode.get,
        --     cond = require('noice').api.statusline.mode.has,
        --     color = { fg = '#ff9e64' },
        --   },
        -- },
      },
    },
  },
}

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    ui = { enable = false },
    picker = {
      name = 'snacks.pick',
    },
    workspaces = {
      {
        name = 'work',
        path = '~/vaults/work',
      },
      {
        name = 'personal',
        path = '~/vaults/personal',
      },
    },
  },
  keys = {
    {
      '<leader>ot',
      '<cmd>Obsidian today<cr>',
      desc = 'Obsidian Today',
    },
    {
      '<leader>od',
      '<cmd>Obsidian dailies<cr>',
      desc = 'Obsidian Dailies',
    },
    {
      '<leader>os',
      '<cmd>Obsidian quick_switch<cr>',
      desc = 'Obsidian Switch',
    },
    {
      '<leader>og',
      '<cmd>Obsidian search<cr>',
      desc = 'Obsidian Grep',
    },
    {
      '<leader>on',
      '<cmd>Obsidian new<cr>',
      desc = 'Obsidian New',
    },
  },
}

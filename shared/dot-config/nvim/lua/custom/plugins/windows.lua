return {
  {
    'anuvyklack/windows.nvim',
    event = 'VeryLazy',
    cmd = {
      'WindowsMaximize',
      'WindowsMaximizeVertically',
      'WindowsMaximizeHorizontally',
      'WindowsEqualize',
      'WindowsEnableAutowidth',
      'WindowsDisableAutowidth',
      'WindowsToggleAutowidth',
    },
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    keys = {
      {
        '<C-w>z',
        '<cmd>WindowsMaximize<CR>',
        mode = 'n',
        desc = 'Toggle Maximize Window',
      },
    },
    opts = {
      ignore = {
        filetype = { 'DiffviewFiles', 'oil' },
        buftype = { 'acwrite', 'nofile' },
      },
    },
  },
}

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    event = 'BufEnter *.md',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
      -- {
      --   '3rd/image.nvim',
      --   lazy = true,
      --   opts = {
      --     rocks = {
      --       hererocks = true, -- recommended if you do not have global installation of Lua 5.1.
      --     },
      --     integrations = {
      --       markdown = {
      --         only_render_image_at_cursor = true,
      --       },
      --     },
      --     -- tmux_show_only_in_active_window = true,
      --     window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      --     -- window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'snacks_notif', 'scrollview', 'scrollview_sign', 'oil', 'telescope' },
      --     kitty_method = 'normal',
      --   },
      -- },
    }, -- if you prefer nvim-web-devicons
    opts = {},
  },
}

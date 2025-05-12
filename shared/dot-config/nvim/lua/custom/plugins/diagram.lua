return {
  {
    'iamcco/markdown-preview.nvim',
    commit = '2a22bb00acae88aa7b5d8b829acd2f63cb688d83',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
}

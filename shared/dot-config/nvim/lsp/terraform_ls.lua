---@type vim.lsp.Config
return {
  cmd = { 'terraform-ls', 'serve' },
  root_markers = { '.git' },
  filetypes = { 'terraform', 'hcl' },
}

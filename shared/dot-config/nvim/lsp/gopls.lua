---@type vim.lsp.Config
return {
  cmd = { "gopls" },
  root_markers = { "go.work", "go.mod", ".git" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    buildFlags = { '-tags=integration' },
    gofumpt = true,
    codelenses = {
      gc_details = true,
      generate = true,
      regenerate_cgo = true,
      run_govulncheck = true,
      test = true,
      tidy = true,
      upgrade_dependency = true,
      vendor = true,
    },
    hints = {
      assignVariableTypes = true,
      compositeLiteralFields = true,
      compositeLiteralTypes = true,
      constantValues = false,
      functionTypeParameters = true,
      parameterNames = false,
      rangeVariableTypes = true,
    },
    analyses = {
      fieldalignment = false,
      nilness = true,
      unusedparams = true,
      unusedwrite = true,
      useany = true,
    },
    usePlaceholders = false,
    completeUnimported = true,
    staticcheck = true,
    directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
    semanticTokens = true,
  }
}

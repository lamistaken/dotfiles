return {
  settings = {
    ['harper-ls'] = {
      linters = {
        SpellCheck = false, -- codebook handles spelling
        SentenceCapitalization = false, -- noisy in code comments
        LongSentences = false,
        Spaces = false, -- aligned comments
      },
    },
  },
}

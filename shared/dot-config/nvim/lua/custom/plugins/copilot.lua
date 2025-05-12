return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    enabled = false,
    dependencies = { 'folke/snacks.nvim' },
    event = 'VeryLazy',
    build = ':Copilot auth',
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        chat_autocomplete = false,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = false,
          prev = false,
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
    init = function()
      local Snacks = require 'snacks'

      -- Toggle copilot
      Snacks.toggle({
        name = 'Copilot Completion',
        color = {
          enabled = 'azure',
          disabled = 'orange',
        },
        get = function()
          return not require('copilot.client').is_disabled()
        end,
        set = function(state)
          if state then
            require('copilot.command').enable()
          else
            require('copilot.command').disable()
          end
        end,
      }):map '<leader>ta'
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    cmd = 'CopilotChat',
    opts = function()
      local user = vim.env.USER or 'User'
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        auto_insert_mode = false,
        show_help = true,
        question_header = '  ' .. user .. ' ',
        answer_header = '  Copilot ',
        window = {
          width = 0.4,
        },
        model = 'claude-3.7-sonnet',
        selection = function(source)
          local select = require 'CopilotChat.select'
          return select.visual(source) or select.buffer(source)
        end,
        chat_autocomplete = false,
        prompts = {
          BaseReviewAndOptimize = {
            prompt = [[
  Your task is to review the provided code snippet, focusing specifically on its readability and maintainability.
  Identify any issues related to:
  - Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
  - The presence of unnecessary comments, or the lack of necessary ones.
  - Overly complex expressions that could benefit from simplification.
  - High nesting levels that make the code difficult to follow.
  - The use of excessively long names for variables or functions.
  - Any inconsistencies in naming, formatting, or overall coding style.
  - Repetitive code patterns that could be more efficiently handled through abstraction or optimization.
  - For SQL make sure to identify any redundancy and inefficiency in the queries.

  Your feedback must be concise, directly addressing each identified issue with:
  - The specific line number(s) where the issue is found.
  - A clear description of the problem.
  - A concrete suggestion for how to improve or correct the issue.

  Format your feedback as follows:
  line=<line_number>: <issue_description>

  If the issue is related to a range of lines, use the following format:
  line=<start_line>-<end_line>: <issue_description>

  If you find multiple issues on the same line, list each issue separately within the same feedback statement, using a semicolon to separate them.

  At the end of your review, add this: "**`To clear buffer highlights, please ask a different question.`**".

  Example feedback:
  line=3: The variable name 'x' is unclear. Comment next to variable declaration is unnecessary.
  line=8: Expression is overly complex. Break down the expression into simpler components.
  line=10: Using camel case here is unconventional for lua. Use snake case instead.
  line=11-15: Excessive nesting makes the code hard to follow. Consider refactoring to reduce nesting levels.

  If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.

  Afterwards, optimize the selected code to improve performance and readability.

  1. Return *ONLY* the complete modified code.

  2. *DO NOT* include any explanations, comments, or line numbers in your response.

  3. Ensure the returned code is complete and can be directly used as a replacement for the original code.

  4. Preserve the original structure, indentation, and formatting of the code as much as possible.

  5. *DO NOT* omit any parts of the code, even if they are unchanged.

  6. Maintain the *SAME INDENTATION* in the returned code as in the source code

  7. *ONLY* return the new code snippets to be updated, *DO NOT* return the entire file content.

  8. If the response do not fits in a single message, split the response into multiple messages.

  9. Directly above every returned code snippet, add `[file:<file_name>](<file_path>) line:<start_line>-<end_line>`. Example: `[file:copilot.lua](nvim/.config/nvim/lua/config/copilot.lua) line:1-98`. This is markdown link syntax, so make sure to follow it.

  10. When fixing code pay close attention to diagnostics as well. When fixing diagnostics, include diagnostic content in your response.

  Remember that Your response SHOULD CONTAIN ONLY THE MODIFIED CODE to be used as DIRECT REPLACEMENT to the original file.

  ]],
          },
          ReviewAndOptimize = {
            prompt = '> /BaseReviewAndOptimize\n\nWrite an explanation for the selected code as paragraphs of text.',
          },
        },
      }
    end,
    keys = {
      { '<c-s>', '<CR>', ft = 'copilot-chat', desc = 'Submit Prompt', remap = true },
      {
        '<leader>aa',
        function()
          return require('CopilotChat').toggle()
        end,
        desc = 'Toggle (CopilotChat)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ax',
        function()
          return require('CopilotChat').reset()
        end,
        desc = 'Clear (CopilotChat)',
        mode = { 'n', 'v' },
      },
      {
        '<leader>aq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat - Quick chat',
      },
      {
        '<leader>ar',
        '<cmd>CopilotChatReviewAndOptimize<cr>',
        desc = 'Review & Optimize (CopilotChat)',
        mode = { 'n', 'v' },
      },
    },
    config = function(_, opts)
      local chat = require 'CopilotChat'

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-chat',
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
}

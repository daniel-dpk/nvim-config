return {
  {
    name = 'calc',
    dir = vim.fn.stdpath('config') .. '/local/calc',
    lazy = false,
    config = function()
      local calc = require('calc')
      calc.setup({ output = 'below' })

      vim.keymap.set('n', '<LocalLeader>mb', function()
        calc.evaluate_line({ output = 'below' })
      end, { desc = '[M]ath evaluate [B]elow' })

      vim.keymap.set('n', '<LocalLeader>mr', function()
        calc.evaluate_line({ output = 'replace' })
      end, { desc = '[M]ath evaluate [R]eplace' })

      vim.keymap.set('n', '<LocalLeader>ma', function()
        calc.evaluate_line({ output = 'append' })
      end, { desc = '[M]ath evaluate [A]ppend' })

      vim.keymap.set('x', '<LocalLeader>mb', function()
        calc.evaluate_visual({ output = 'below' })
      end, { desc = '[M]ath evaluate [B]elow' })
      vim.keymap.set('x', '<LocalLeader>mr', function()
        calc.evaluate_visual({ output = 'replace' })
      end, { desc = '[M]ath evaluate [R]eplace' })
      vim.keymap.set('x', '<LocalLeader>ma', function()
        calc.evaluate_visual({ output = 'append' })
      end, { desc = '[M]ath evaluate [A]ppend' })
    end,
  },
}

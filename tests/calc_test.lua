return function(t)
  local calc = require('calc')

  t.test('line replace preserves scientific exponent zeros', function()
    vim.cmd('enew!')
    vim.api.nvim_buf_set_lines(0, 0, -1, true, {
      '(2*pi/1e4)**2 * 0.1**3',
    })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    calc.evaluate_line({ output = 'replace' })

    t.eq({ '3.9478417604357436e-10' },
      vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)
end

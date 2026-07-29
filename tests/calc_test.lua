return function(t)
  local calc = require('calc')

  local function set_buffer(lines)
    vim.cmd('enew!')
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end

  t.test('line replace preserves scientific exponent zeros', function()
    set_buffer({ '(2*pi/1e4)**2 * 0.1**3' })

    calc.evaluate_line({ output = 'replace' })

    t.eq({ '3.9478417604357436e-10' },
      vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('line evaluation executes assignments', function()
    set_buffer({ 'x = 3; x / 2' })

    calc.evaluate_line({ output = 'replace' })

    t.eq({ '1.5' }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('line evaluation uses str and imports math names', function()
    set_buffer({ '"odd" if sqrt(9) == 3 else "even"' })

    calc.evaluate_line({ output = 'replace' })

    t.eq({ 'odd' }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('line evaluation strips the filetype comment', function()
    set_buffer({ '  # sqrt(9)' })
    vim.bo.commentstring = '# %s'

    calc.evaluate_line({ output = 'replace' })

    t.eq({ '  3.0' }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('line evaluation ignores stdout', function()
    set_buffer({ 'print("noise"); 2 + 2' })

    calc.evaluate_line({ output = 'replace' })

    t.eq({ '4' }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('visual below evaluates a dedented multiline block', function()
    set_buffer({
      '  x = 3',
      '  if x % 2 == 0:',
      '    r = "even"',
      '  else:',
      '    r = "odd"',
      '  r',
      'after',
    })
    vim.cmd('normal! V5j')

    calc.evaluate_visual({ output = 'below' })

    t.eq({
      '  x = 3',
      '  if x % 2 == 0:',
      '    r = "even"',
      '  else:',
      '    r = "odd"',
      '  r',
      '  odd',
      'after',
    }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('visual replace replaces a multiline block', function()
    set_buffer({
      '  x = 3',
      '  x / 2',
      'after',
    })
    vim.cmd('normal! Vj')

    calc.evaluate_visual({ output = 'replace' })

    t.eq({ '  1.5', 'after' },
      vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('visual append inserts after the selection end', function()
    set_buffer({
      'x = 3',
      'x / 2',
      'after',
    })
    vim.cmd('normal! Vj')

    calc.evaluate_visual({ output = 'append' })

    t.eq({ 'x = 3', 'x / 2 = 1.5', 'after' },
      vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('block append uses the lower-right corner', function()
    set_buffer({
      'x = 3 tail',
      'x / 2 tail',
    })
    local keys = vim.api.nvim_replace_termcodes('<C-v>j4l', true, false,
      true)
    vim.api.nvim_feedkeys(keys, 'x', false)

    calc.evaluate_visual({ output = 'append' })

    t.eq({ 'x = 3 tail', 'x / 2 = 1.5 tail' },
      vim.api.nvim_buf_get_lines(0, 0, -1, true))
  end)

  t.test('code without a final expression does not change the line',
    function()
      set_buffer({ 'x = 3' })
      local original_notify = vim.notify
      local message
      vim.notify = function(msg) message = msg end

      calc.evaluate_line({ output = 'replace' })

      vim.notify = original_notify
      t.eq({ 'x = 3' }, vim.api.nvim_buf_get_lines(0, 0, -1, true))
      t.eq(true, message:find('did not end with an expression', 1, true)
        ~= nil)
    end)
end

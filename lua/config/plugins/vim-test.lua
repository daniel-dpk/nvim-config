local skip_slow_tests

local function set_pytest_options()
  if skip_slow_tests then
    vim.g['test#python#pytest#options'] = '-m "not slow"'
  else
    vim.g['test#python#pytest#options'] = ''
  end
end

local function toggle_slow_test()
  skip_slow_tests = not skip_slow_tests
  set_pytest_options()
  if skip_slow_tests then
    vim.notify('pytest: skipping slow tests (-m "not slow")')
  else
    vim.notify('pytest: running ALL tests')
  end
end

local function wall_then(cmd)
  return ('<cmd>wall|%s<CR>'):format(cmd)
end

return {
  {
    'vim-test/vim-test',
    init = function()
      vim.g['test#preserve_screen'] = false            -- Clear screen from previous run
      vim.g['test#strategy'] = 'neovim_sticky'
      vim.g['test#neovim_sticky#kill_previous'] = true -- Try to abort previous run
      vim.g['test#neovim_sticky#reopen_window'] = true -- Reopen terminal split if not visible
      vim.g['test#neovim_sticky#use_existing'] = true  -- Use manually opened terminal, if exists
      vim.g['test#neovim#term_position'] = "vert topleft 100"
      -- Skip slow tests by default
      skip_slow_tests = true
      set_pytest_options()
    end,
    config = function()
      vim.keymap.set('n', '<LocalLeader>tt', wall_then('TestNearest'), { desc = '[t]est nearest' })
      vim.keymap.set('n', '<LocalLeader>tf', wall_then('TestFile'),    { desc = 'test [f]ile' })
      vim.keymap.set('n', '<LocalLeader>ta', wall_then('TestSuite'),   { desc = 'test [a]ll (test suite)' })
      vim.keymap.set('n', '<LocalLeader>tl', wall_then('TestLast'),    { desc = 'test [l]ast' })
      vim.keymap.set('n', '<LocalLeader>tg', wall_then('TestVisit'),   { desc = '[g]o to last test' })
      vim.keymap.set('n', '<LocalLeader>ts', toggle_slow_test,         { desc = 'toggle [s]low tests' })
    end,
  },
}

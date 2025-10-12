local skip_slow_tests

local remote_name = nil

---Build the remote pytest command as table
---@param args? table[str]
---@return table[str]
local function remote_pytest_table(args)
  args = args or {}
  local components = { vim.fn.stdpath('config') .. '/bin/remote_pytest' }
  if remote_name and remote_name ~= '' then
    table.insert(components, '--remote')
    table.insert(components, remote_name)
  end
  for _, arg in ipairs(args) do table.insert(components, arg) end
  return components
end

---Build the remote pytest command as string
---@param args? table[str]
---@return string
local function remote_pytest(args)
  local components = remote_pytest_table(args)
  return table.concat(components, ' ')
end

local function set_executable()
  vim.g['test#python#pytest#executable'] = remote_pytest({ '--', 'pytest' })
end

local function choose_remote()
  vim.ui.input(
    {
      prompt = 'Remote name (empty = default): ',
      default = remote_name or '',
    },
    function(val)
      if val == nil then return end
      remote_name = (val ~= '' and val) or nil
      set_executable()
      if remote_name then
        vim.api.nvim_echo({ { 'Remote set to: ' .. remote_name, 'Statement' } }, false, {})
      else
        vim.api.nvim_echo({ { 'Using default remote in .remote-tests.toml', 'Statement' } }, false, {})
      end
    end
  )
end

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

local function prep_and_run(cmd)
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
      vim.g['test#neovim#term_position'] = 'vert topleft 100'

      -- Skip slow tests by default
      skip_slow_tests = true
      set_pytest_options()

      -- Use the pytest wrapper
      set_executable()
    end,
    config = function()
      vim.keymap.set('n', '<LocalLeader>tt', prep_and_run('TestNearest'), { desc = '[t]est nearest' })
      vim.keymap.set('n', '<LocalLeader>tf', prep_and_run('TestFile'),    { desc = 'test [f]ile' })
      vim.keymap.set('n', '<LocalLeader>ta', prep_and_run('TestSuite'),   { desc = 'test [a]ll (test suite)' })
      vim.keymap.set('n', '<LocalLeader>tl', prep_and_run('TestLast'),    { desc = 'test [l]ast' })
      vim.keymap.set('n', '<LocalLeader>tg', prep_and_run('TestVisit'),   { desc = '[g]o to last test' })
      vim.keymap.set('n', '<LocalLeader>ts', toggle_slow_test,            { desc = 'toggle [s]low tests' })

      vim.keymap.set('n', '<LocalLeader>tr', choose_remote, { desc = 'choose [r]emote' })

      vim.keymap.set('n', '<LocalLeader>tS', function()
        vim.api.nvim_command('wall')
        vim.cmd('vert topleft split | vert resize 100 | setlocal winfixwidth | ' ..
          'terminal ' .. remote_pytest() .. ' --sync-only --verbose && exit')
        vim.cmd('horizontal wincmd =')
        vim.cmd('startinsert')
      end, { desc = '[S]ync with remote' })

      vim.keymap.set('n', '<C-S-s>', function()
        vim.api.nvim_command('wall')
        vim.system(remote_pytest_table({ '--sync-only', '--verbose' }),
          { test = true },
          vim.schedule_wrap(function(obj)
            if obj.code == 0 then
              vim.api.nvim_echo({ { 'Sync completed successfully', 'Statement' } }, false, {})
            else
              vim.notify('Sync failed', vim.log.levels.ERROR)
              print(obj.stderr)
            end
          end)
        )
      end, { desc = '[S]ync with remote' })
    end,
  },
}

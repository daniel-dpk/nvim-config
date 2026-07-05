local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h')

vim.opt.runtimepath:prepend(root .. '/local/calc')

package.path = table.concat({
  root .. '/local/calc/lua/?.lua',
  root .. '/local/calc/lua/?/init.lua',
  package.path,
}, ';')

local cases = {}

local t = {}

function t.test(name, fn)
  cases[#cases + 1] = { name = name, fn = fn }
end

function t.eq(expected, actual, message)
  if vim.deep_equal(expected, actual) then return end

  error(('%s\nexpected: %s\nactual:   %s'):format(
    message or 'values differ',
    vim.inspect(expected),
    vim.inspect(actual)
  ), 2)
end

dofile(root .. '/tests/calc_test.lua')(t)

local failures = {}

for _, case in ipairs(cases) do
  local ok, err = xpcall(case.fn, function(msg)
    return debug.traceback(tostring(msg), 2)
  end)

  if ok then
    print('ok - ' .. case.name)
  else
    failures[#failures + 1] = { name = case.name, err = err }
    print('not ok - ' .. case.name)
  end
end

if #failures > 0 then
  for _, failure in ipairs(failures) do
    vim.api.nvim_err_writeln('\n' .. failure.name .. '\n' .. failure.err)
  end
  os.exit(1)
end

print(('ok - %d test(s) passed'):format(#cases))
os.exit(0)

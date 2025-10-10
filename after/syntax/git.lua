-- Only for git filetype, and skip real diff windows
if vim.bo.filetype ~= 'git' or vim.wo.diff then
  return
end

vim.cmd([[
  " Lines that look like custom log output (graph + short hash)
  syntax match    myGitLogLine    "^[\* |\/\\]*[0-9a-f]\{7,}\>\s.*"
  " Pure graph spacer lines
  syntax match    myGitLogLine    "^[\* |\/\\]*$"

  " Pieces within that line
  syntax match    myGitHash       "\<[0-9a-f]\{7,}\>"      contained containedin=myGitLogLine
  syntax match    myGitDate       "\<\d\d\d\d-\d\d-\d\d\>" contained containedin=myGitLogLine
  syntax match    myGitGraph      "^[\* |\/\\]\+"          contained containedin=myGitLogLine
  syntax match    myGitParens     "(.*)"                   contained containedin=myGitLogLine
  syntax match    myGitPointer    "(.* -> .*)"             contained containedin=myGitLogLine

  " Link highlight groups
  highlight default link myGitHash     Identifier
  highlight default link myGitDate     Constant
  highlight default link myGitGraph    Label
  highlight default link myGitPointer  Special
  highlight default link myGitParens   Type
]])

local function tweak_colors()
  --vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#226699' })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = '#444444' })

  -- inactive window background
  --vim.api.nvim_set_hl(0, 'NormalNC', { link = '' }) -- break any links
  --vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#222222' })

  -- optional: make vertical splits visible
  --vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#4a4f5c' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('MyUiContrast', { clear = true }),
  callback = tweak_colors,
})

tweak_colors()

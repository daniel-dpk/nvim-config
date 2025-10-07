return {
  {
    'folke/snacks.nvim',
    --enabled = false,
    --version = 'v2.*',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      input = {
        enabled = true,
        -- This fixes the "cursor stuck to first column" bug. Might be related
        -- to SSH+tmux, not sure though.
        expand = false,
        win = {
          width = 120,
          bo = {
            textwidth = 0, -- auto-wrapping makes it unusable
          },
          keys = {
            i_ctrl_e = { '<c-e>', '<End>', mode = "i", expr = true },
            i_ctrl_a = { '<c-a>', '<Home>', mode = "i", expr = true },
          },
        },
      },
    },
  },
}

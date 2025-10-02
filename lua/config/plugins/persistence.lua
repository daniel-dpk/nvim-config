return {
  "folke/persistence.nvim",
  config = function()
    local p = require("persistence")
    vim.keymap.set("n", "<leader>sl", function() p.load() end, { desc = 'Load session for cwd' })
    vim.keymap.set("n", "<leader>ss", function() p.select() end, { desc = 'Select a session' })
    vim.keymap.set("n", "<leader>sa", function() p.start() end, { desc = 'Activate session tracking' })
    vim.keymap.set("n", "<leader>sd", function() p.stop() end, { desc = 'Stop session saving' })

    -- User commands
    -- :SessionLoad         -> load session for current cwd
    -- :SessionLoad!        -> load last session (most recent), regardless of cwd
    -- :SessionSave / :SessionStart / :SessionStop / :SessionSelect
    --
    -- To resume a session from the command line:
    --  nvim +SessionLoad

    vim.api.nvim_create_user_command("SessionLoad", function(opts)
      p.load({ last = opts.bang or false })
    end, { bang = true, desc = "Load session (cwd by default, ! = last session)" })

    vim.api.nvim_create_user_command("SessionSave", function()
      p.save()
    end, { desc = "Save session now" })

    vim.api.nvim_create_user_command("SessionStart", function()
      p.start()
    end, { desc = "Enable session saving" })

    vim.api.nvim_create_user_command("SessionStop", function()
      p.stop()
    end, { desc = "Disable session saving" })

    vim.api.nvim_create_user_command("SessionSelect", function()
      p.select()
    end, { desc = "Select a session interactively" })

    -- Setup also enables auto-save on VimLeavePre
    p.setup()
  end,
}

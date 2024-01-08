
local sm = require('streamer-mode.streamer-mode')
vim.api.nvim_create_user_command('StreamerMode', function()
  sm:toggle_streamer_mode()
end, { desc = 'Toggles streamer mode on and off.' })

vim.api.nvim_create_user_command('StreamerModeOff', function()
  sm:stop_streamer_mode()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('StreamerModeSecure', function()
  sm.setup({ level = 'secure', default_state = 'on' })
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('StreamerModeEdit', function()
  sm.setup({ level = 'edit', default_state = 'on' })
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('StreamerModeSoft', function()
  sm.setup({ level = 'soft', default_state = 'on' })
end, { desc = 'Starts streamer mode with Soft level enabled.' })

vim.api.nvim_create_user_command('SM', function()
  sm:toggle_streamer_mode()
end, { desc = 'Toggles streamer mode on and off.' })

vim.api.nvim_create_user_command('SMoff', function()
  sm:remove_conceals()
end, { desc = 'Stops streamer mode.' })

vim.api.nvim_create_user_command('SMsecure', function()
  sm.setup({ level = 'secure', default_state = 'on' })
end, { desc = 'Starts streamer mode with Secure level enabled.' })

vim.api.nvim_create_user_command('SMedit', function()
  sm.setup({ level = 'edit', default_state = 'on' })
end, { desc = 'Starts streamer mode with Edit level enabled.' })

vim.api.nvim_create_user_command('SMsoft', function()
  sm.setup({ level = 'soft', default_state = 'on' })
end, { desc = 'Starts streamer mode with Soft level enabled.' })


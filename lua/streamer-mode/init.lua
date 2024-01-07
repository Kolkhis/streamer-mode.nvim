local sm = require('streamer-mode.streamer-mode')
require('streamer-mode.commands')
local normal_level = vim.o.conceallevel
sm.setup({ preset = true })
if sm.default_state == 'on' then
  sm:start_streamer_mode()
else
  vim.o.conceallevel = normal_level
end
return sm

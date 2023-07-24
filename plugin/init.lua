local normal_level = vim.o.conceallevel
local sm = require('streamer-mode')
sm.setup()
if sm.default_state == 'on' then
  sm:start_streamer_mode()
else
  vim.o.conceallevel = normal_level
end

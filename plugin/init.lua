local sm = require('streamer-mode')
sm.setup()
if sm.default_state == 'on' then
  sm:start_streamer_mode()
end

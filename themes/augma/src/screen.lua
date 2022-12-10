local awful = require('awful')

local overlay = require('src.overlay')
local notifications = require('src.notifications')
local launcher = require('src.launcher')

return function (s, config)
  awful.tag(config.tags, s, awful.layout.layouts[1])
  s.overlay = overlay(s, config)
  s.notifications = notifications(s, config)
  s.launcher = launcher(s, config)
end


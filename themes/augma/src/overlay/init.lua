local wibox = require('wibox')

local timebar = require('src.overlay.timebar')
local taskbar = require('src.overlay.taskbar')
local weather = require('src.overlay.weather')

return function (s, config)
  local overlay = wibox({
    screen = s,
    visible = true,

    width = s.geometry.width,
    height = s.geometry.height,
    x = 0,
    y = 0,

    bg = '#0000003f',
  })

  overlay:setup({
    layout = wibox.layout.manual,
    timebar(s, config),
    taskbar(s, config),
    weather(s, config),
  })

  return overlay
end


local ruled = require('ruled')
local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local beautiful = require('beautiful')

local input = require('src.input')


local function clients(config)
  ruled.client.append_rule({
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = input.client_keys,
      buttons = input.client_buttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 8) end,
    }
  })
end


local function notifications(config)
  naughty.config.notify_callback = function(args)
    args.message = '<b>' .. args.title .. '</b> ' .. args.message .. ' '
    return args
  end

  naughty.connect_signal("request::display", function(n)
    return nil
  end)
end


return function (config)
  clients(config)
  notifications(config)
end


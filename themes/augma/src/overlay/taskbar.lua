local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')

return function (s, config)
  local tasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,

    layout = {
      layout = wibox.layout.fixed.horizontal,
      forced_height = 64,
      spacing = 32,
    },

    widget_template = {
      widget = wibox.layout.stack,
      {
        widget = wibox.widget.imagebox,
        image = beautiful.shadowed_circle,
      },
      {
        widget = wibox.container.margin,
        margins = 16,
        {
          widget = wibox.container.background,
          shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 4) end,
          awful.widget.clienticon,
        },
      },
    },
  })

  return {
    point = function (geo, args)
      return {
        x = (args.parent.width - geo.width) / 2,
        y = args.parent.height - geo.height - 24,
      }
    end,
    widget = wibox.container.place,
    halign = 'center',
    {
      layout = wibox.layout.fixed.vertical,
      forced_width = 896,
      {
        widget = wibox.widget.imagebox,
        image = beautiful.taskbar_line,
      },
      {
        widget = wibox.container.place,
        halign = 'center',
        valign = 'center',
        tasklist,
      },
    }
  }
end


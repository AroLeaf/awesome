local wibox = require('wibox')
local beautiful = require('beautiful')

return function (s, config)
  local mic_button = {
    widget = wibox.widget.imagebox,
    image = beautiful.circle_mic,
    forced_width = 64,
    forced_height = 64,
  }

  local ellipses_button = {
    widget = wibox.widget.imagebox,
    image = beautiful.circle_ellipses,
    forced_width = 64,
    forced_height = 64,
  }

  local clock_line = {
    widget = wibox.container.margin,
    margins = {
      top = 32,
    },
    {
      layout = wibox.layout.stack,
      forced_width = 1700,
      {
        widget = wibox.widget.imagebox,
        image = beautiful.timebar_line,
      },
      {
        widget = wibox.container.place,
        halign = 'top',
        valign = 'center',
        {
          widget = wibox.container.background,
          fg = beautiful.fg_overlay,
          {
            widget = wibox.widget.textclock,
            format = '%H:%M',
            font = 'Open Sans Light 20',
            refresh = 10,
          },
        },
      },
    }
  }

  return {
    point = function (geo, args)
      return {
        x = (args.parent.width - geo.width) / 2,
        y = 24,
      }
    end,
    widget = wibox.container.place,
    halign = 'center',
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = 4,
      mic_button,
      clock_line,
      ellipses_button,
    },
  }
end


local gears = require('gears')
local naughty = require('naughty')
local wibox = require('wibox')
local beautiful = require('beautiful')


return function (s, config)
  local notification_list = wibox({
    screen = s,
    visible = false,
    ontop = true,

    width = 288,
    height = 64,
    x = s.geometry.width - 288 - 48,
    y = 128,

    bg = '#00000000',
  })

  notification_list:setup({
    widget = naughty.list.notifications,
    base_layout = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = 4,
    }),

    widget_template = {
      widget = wibox.layout.stack,
      forced_width = 288,
      forced_height = 64,

      -- background
      {
        widget = wibox.widget.imagebox,
        image = beautiful.notification_bg,
      },

      -- content
      {
        widget = wibox.container.margin,
        margins = 4,
        {
          layout = wibox.layout.fixed.horizontal,
          -- icon
          {
            widget = wibox.container.place,
            valign = 'center',
            {
              widget = wibox.container.background,
              forced_height = 32,
              forced_width = 32,
              shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 4) end,
              naughty.widget.icon,
            },
          },
          -- body
          {
            widget = wibox.container.margin,
            margins = {
              left = 12,
              right = 24,
            },
            {
              widget = wibox.container.place,
              halign = 'left',
              valign = 'center',
              {
                widget = wibox.container.scroll.horizontal,
                id = 'scroll',
                fps = 60,
                speed = 25,
                naughty.widget.message,
              },
            },
          },
        },
      },
    },
  })

  naughty.connect_signal("property::active", function()
    notification_list.height = math.max(#naughty.active * 68 - 4, 1)
    notification_list.visible = #naughty.active > 0
  end)

  return notification_list
end


local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local Desktop = require('lib/desktop')

return function (desktop_file, options)
  options = options or {}

  local icon = Desktop.get_icon(desktop_file) -- or beautiful.icon_fallback

  local app = wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg_normal .. '3f',
    shape = gears.shape.circle,
    {
      widget = wibox.container.margin,
      margins = 8,
      {
        widget = wibox.container.constraint,
        width = 48,
        height = 48,
        strategy = 'exact',
        {
          widget = wibox.widget.imagebox,
          image = icon,
        },
      },
    },
  })

  function app:focus()
    self.bg = beautiful.bg_focus
  end

  function app:unfocus()
    self.bg = beautiful.bg_normal .. '3f'
  end

  app.desktop_file = desktop_file

  app:connect_signal('mouse::enter', function ()
    if (options.hover_callback) then options.hover_callback(app) end
    app:focus()
  end)

  app:connect_signal('mouse::leave', function ()
    app:unfocus()
  end)

  app:connect_signal('button::press', function (self, lx, ly, button)
    if (button == 1 and options.click_callback) then options.click_callback(app) end
  end)

  return app
end

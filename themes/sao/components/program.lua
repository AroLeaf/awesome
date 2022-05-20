local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')

return function (program, hover)
  local program = wibox.widget({
    widget = wibox.container.background,
    bg = hover and beautiful.bg_hover or beautiful.bg_normal,
    fg = hover and beautiful.fg_hover or beautiful.fg_normal,
    {
      widget = wibox.container.margin,
      margins = 8,
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = 8,
        {
          widget = wibox.widget.imagebox,
          image = focus and program.icon.focus or program.icon.normal or program.icon,
          forced_width = 24,
          forced_height = 24,
        },
        {
          widget = wibox.widget.textbox,
          text = program.name,
        },
      },
    },
  })
  
  return program
end


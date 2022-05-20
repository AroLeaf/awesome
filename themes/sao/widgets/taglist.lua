local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

return function (s, config)
  local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ config.modkey }, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ config.modkey }, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
  )

  local taglist = awful.widget.taglist({
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    style = {
      spacing = beautiful.menu_spacing,
      shape   = gears.shape[beautiful.menu_shape],
    },
    layout = wibox.layout.fixed.vertical,
    widget_template = {
      widget = wibox.container.background,
      shape_border_width = beautiful.menu_margin / 4,
      shape = gears.shape[beautiful.menu_shape],
      forced_width = 64 - beautiful.menu_spacing,
      forced_height = 64 - beautiful.menu_spacing,
      create_callback = function(self, t) self.shape_border_color = t.selected and beautiful.bg_focus or beautiful.bg_normal end,
      update_callback = function(self, t) self.shape_border_color = t.selected and beautiful.bg_focus or beautiful.bg_normal end,
      {
        widget = wibox.container.margin,
        margins = beautiful.menu_margin,
        {
          widget = wibox.container.background,
          id = 'background_role',
          fg = beautiful.fg_focus,
          shape = gears.shape[beautiful.menu_shape],
          shape_border_color = beautiful.fg_normal,
          shape_border_width = beautiful.menu_margin,
          {
            widget = wibox.container.place,
            {
              layout = wibox.layout.fixed.horizontal,
              {
                id     = 'text_role',
                widget = wibox.widget.textbox,
              },
            },
          },
        },
      },
    },
  })
  
  return awful.popup({
    widget = {
      {
        taglist,
        widget = wibox.container.margin,
        left = 32,
      },
      valign = 'center',
      halign = 'left',
      fill_vertical = true,
      fill_horizontal = true,
      widget  = wibox.container.place
    },
    ontop = false,
    bg = '#0000007f',
    placement = awful.placement.left,
    visible = true,
  })
end


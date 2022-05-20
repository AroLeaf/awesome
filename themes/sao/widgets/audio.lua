local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local pamixer = require('lib/pamixer')

return function (s, config)
  local icon = beautiful.icon_not_found

  local mute = wibox.widget({
    widget = wibox.widget.imagebox,
    image = pamixer.muted() and icon.normal or icon.focus,
    forced_width = 20,
    forced_height = 20,
  })
  
  mute:buttons(gears.table.join(
    awful.button({}, 1, function ()
      if (pamixer.muted()) 
        then pamixer.unmute() 
        else pamixer.mute()
      end
    end)
  ))

  local slider = wibox.widget({
    widget = wibox.widget.slider,
    value = pamixer.get(),
    forced_height = 16,
  })
  
  local number = wibox.widget({
    widget = wibox.widget.textbox,
    placement = awful.placement.center_horizontal,
    text = tostring(pamixer.get())..'%',
  })
  
  slider:connect_signal('property::value', function () pamixer.set(slider.value) end)
  
  pamixer.connect_signal('volume', function (volume)
    slider.value = volume
    number.text = tostring(volume)..'%'
  end)
  
  pamixer.connect_signal('mute', function (muted)
    mute.image = muted and icon.normal or icon.focus
  end)

  local audio = awful.popup({
    widget = {
      widget = wibox.container.background,
      bg = beautiful.bg_normal,
      forced_width = 384,
      {
        widget = wibox.container.margin,
        margins = 16,
        {
          widget = wibox.layout.fixed.vertical,
          spacing = 8,
          {
            widget = wibox.widget.textbox,
            placement = awful.placement.center_horizontal,
            text = 'Main Output',
          },
          {
            layout = wibox.layout.align.horizontal,
            mute,
            {
              widget = wibox.container.margin,
              left = 8,
              right = 8,
              slider,
            },
            number,
          },
        },
      },
    },
    ontop = true,
    placement = function (c) awful.placement.left(c, { offset = { x = 304, y = 0 } }) end,
    visible = false,
  })
  
  function audio:show(close_callback)
    self.close_callback = close_callback
    self.keygrabber:start()
    self.visible = true
  end
  
  function audio:close()
    self.visible = false
    self.keygrabber:stop()
    self.close_callback(true)
  end
  
  local function close()
    audio:close()
  end
  
  audio.keygrabber = awful.keygrabber({
    keybindings = {
      {{}, 'Escape', close },
      {{}, 'Left', close },
      {{}, 'XF86AudioRaiseVolume', function () pamixer.inc(5) end },
      {{}, 'XF86AudioLowerVolume', function () pamixer.dec(5) end },
      {{}, 'XF86AudioMute', function () if (pamixer.muted()) then pamixer.unmute() else pamixer.mute() end end }
    },
  })
  
  return {
    name = 'Audio Settings',
    icon = beautiful.icon_not_found,
    run = function (close_callback) audio:show(close_callback) end
  }
end


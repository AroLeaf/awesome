local awful = require('awful')
local wibox = require('wibox')
local naughty = require('naughty')
local menubar = require('menubar')
local beautiful = require('beautiful')

if awesome.startup_errors then
  naughty.notification({
    preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = awesome.startup_errors,
  })
end

local __dirname = debug.getinfo(1).source:match('@?(.*/)')

local input = require('src.input')
local each_screen = require('src.screen')
local rules = require('src.rules')
local pactl = require('lib.pactl')

return function ()
  local theme = require('theme')
  beautiful.init(theme)

  awful.layout.append_default_layouts({
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating,
  })

  local config = require('config')
  menubar.utils.terminal = config.terminal
  awful.util.shell = config.shell
  input.setup(config)
  rules(config)
  awful.screen.connect_for_each_screen(function (s) each_screen(s, config) end)

  pactl.init()

  screen.connect_signal('request::wallpaper', function(s)
    awful.wallpaper {
      screen = s,
      widget = {
        widget = wibox.container.place,
        halign = 'center',
        valign = 'center',
        {
          widget    = wibox.widget.imagebox,
          image     = beautiful.wallpaper,
          upscale   = true,
          downscale = true,
        },
      }
    }
  end)
  
  client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
  end)
end


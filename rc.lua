local awful = require('awful')
local gears = require('gears')
local menubar = require("menubar")
local gfs = require('gears.filesystem')
local beautiful = require('beautiful')

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

local __dirname = gfs.get_configuration_dir()

-- allow modules in ./lib to load properly
package.path = __dirname..'lib/?.lua;'..package.path

local get_config = require('lib/config')
local fs = require('lib/fs')

-- load theme
local themes = fs.scan(__dirname..'themes')

local config = get_config(__dirname..'config.json', {
  theme = gfs.dir_readable(__dirname..'themes/default') and 'default' or themes[1],
  modkey = 'Mod4',
  terminal = 'xterm',
  editor = os.getenv('EDITOR') or 'nano',
  num_tags = 9,
})

local theme = require('themes/'..config.theme..'/rc')


awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.fair,
  awful.layout.suit.max,
}

theme.init({
  themes = themes,
  config = config,
})


-- input bindings
local globalkeys = theme.global_keys and theme.global_keys(config) or {}

for index = 1, config.num_tags do
  local tagkeys = theme.tag_keys and theme.tag_keys(config, index) or {}
  globalkeys = gears.table.join(globalkeys, tagkeys)
end

local clientkeys = theme.client_keys and theme.client_keys(config) or {}

local globalbuttons = gears.table.join(
  theme.global_buttons and theme.global_buttons(config) or {}
)

local clientbuttons = theme.client_buttons and theme.client_buttons(config) or {}

root.keys(globalkeys)
root.buttons(globalbuttons)


-- rules
awful.rules.rules = gears.table.join(
  theme.client_rules and theme.client_rules(config) or {},
  {{
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }}
)


local function set_wallpaper(s)
  if theme.wallpaper then
    theme.wallpaper(s)
  elseif beautiful.wallpaper then
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end


-- set up screens
awful.screen.connect_for_each_screen(function(s)
  set_wallpaper(s)

  -- tags
  local tag_names = {}
  for i = 1, config.num_tags do
    tag_names[i] = tostring(i)
  end
  awful.tag(tag_names, s, awful.layout.layouts[1])
end)

screen.connect_signal('property::geometry', set_wallpaper)


menubar.utils.terminal = config.terminal


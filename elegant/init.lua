local awful = require('awful')
local gears = require('gears')
local menubar = require("menubar")
local gfs = require('gears.filesystem')
local beautiful = require('beautiful')

local get_config = require('elegant.config')
local fs = require('elegant.fs')


local function input(config, theme)
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
  
  return {
    clientkeys = clientkeys,
    clientbuttons = clientbuttons,
  }
end


local function rules(config, theme, input)
  return gears.table.join(
    theme.client_rules and theme.client_rules(config) or {},
    {{
      rule = {},
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = input.clientkeys,
        buttons = input.clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
    }}
  )
end


local function screens(config, theme)
  local function set_wallpaper(s)
    if theme.wallpaper then
      theme.wallpaper(s)
    elseif beautiful.wallpaper then
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
  end
  
  awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    local tag_names = {}
    for i = 1, config.num_tags do
      tag_names[i] = tostring(i)
    end
    awful.tag(tag_names, s, awful.layout.layouts[1])
  end)
  
  screen.connect_signal('property::geometry', set_wallpaper)
end


local function load()
  local dir = gfs.get_configuration_dir()
  
  local themes = fs.scan(dir..'themes')

  local config = get_config(dir..'config', {
    theme = gfs.dir_readable(dir..'themes/default') and 'default' or themes[1],
    modkey = 'Mod4',
    terminal = 'xterm',
    editor = os.getenv('EDITOR') or 'nano',
    num_tags = 9,
  })
  
  menubar.utils.terminal = config.terminal
  
  local theme = require('themes/'..config.theme..'/rc')
  
  theme.init({
    themes = themes,
    config = config,
  })
  
  local client_input = input(config, theme)
  awful.rules.rules = rules(config, theme, client_input)
  screens(config, theme)
end

return { load = load }


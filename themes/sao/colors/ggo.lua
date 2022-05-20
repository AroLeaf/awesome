local gears = require('gears')

local __dirname = debug.getinfo(1).source:match('@?(.*/)');
local icons = require('util/icons')

local theme = {}

theme.font                = 'HomenajeMod 14'

theme.bg_normal           = '#303030'
theme.bg_focus            = '#4274a4'
theme.bg_urgent           = '#ff0000'
theme.bg_minimize         = theme.bg_focus
theme.bg_systray          = theme.bg_normal
theme.bg_hover            = '#404040'
theme.bg_selection        = theme.bg_focus..'7f'

theme.fg_normal           = '#c8c8c8'
theme.fg_focus            = '#fbfbfb'
theme.fg_hover            = theme.fg_focus
theme.fg_cursor           = theme.bg_focus
theme.fg_urgent           = theme.fg_focus
theme.fg_minimize         = theme.fg_focus

theme.useless_gap         = 8
theme.border_width        = 0
theme.border_normal       = theme.fg_normal
theme.border_focus        = theme.fg_focus
theme.border_marked       = '#91231c'

theme.slider_bar_height   = 8
theme.slider_bar_color    = theme.bg_hover
theme.slider_bar_shape    = gears.shape.rectangle
theme.slider_handle_width = 12
theme.slider_handle_color = theme.bg_focus
theme.slider_handle_shape = gears.shape.rectangle

theme.taglist_bg_occupied = theme.bg_normal
theme.taglist_bg_empty    = theme.bg_normal
theme.taglist_fg_occupied = theme.fg_normal
theme.taglist_fg_empty    = '#505050'

theme.menu_spacing = 0
theme.menu_margin = 0
theme.menu_shape = 'rectangle'

theme.wallpaper = __dirname..'../assets/ggo/glocken.png'

icons(__dirname..'../assets/ggo/icons/', theme)

return theme


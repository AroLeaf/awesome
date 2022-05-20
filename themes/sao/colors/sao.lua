local gears = require('gears')

local __dirname = debug.getinfo(1).source:match('@?(.*/)');
local icons = require('util/icons')

local theme = {}

theme.font                = 'SAO UI TT 14'

theme.bg_normal           = '#fbfbfb'
theme.bg_focus            = '#eba601'
theme.bg_urgent           = '#ff0000'
theme.bg_minimize         = theme.bg_focus
theme.bg_systray          = theme.bg_normal
theme.bg_hover            = theme.bg_focus
theme.bg_selection        = theme.bg_focus..'7f'

theme.fg_normal           = '#4d4d4d'
theme.fg_focus            = '#fbfbfb'
theme.fg_hover            = theme.fg_focus
theme.fg_cursor           = theme.bg_focus
theme.fg_urgent           = theme.fg_focus

theme.useless_gap         = 8
theme.border_width        = 0
theme.border_normal       = theme.fg_normal
theme.border_focus        = theme.fg_focus

theme.slider_bar_height   = 10
theme.slider_bar_color    = '#d7d7d7'
theme.slider_bar_shape    = gears.shape.rounded_rect
theme.slider_handle_width = 16
theme.slider_handle_color = theme.bg_focus
theme.slider_handle_shape = gears.shape.circle

theme.taglist_bg_occupied = theme.bg_normal
theme.taglist_bg_empty    = theme.bg_normal
theme.taglist_fg_occupied = theme.fg_normal
theme.taglist_fg_empty    = '#c9c9c9'

theme.menu_spacing = 8
theme.menu_margin = 4
theme.menu_shape = 'circle'

theme.wallpaper = __dirname..'../assets/sao/aincrad.png'

icons(__dirname..'../assets/sao/icons/', theme)

return theme


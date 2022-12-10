local __dirname = debug.getinfo(1).source:match('@?(.*/)')

local config = require('config')

local theme = {}

theme.wallpaper = __dirname..'assets/background.png'
theme.font = "Open Sans 11"
theme.useless_gap = 8

theme.bg_overlay = '#00000000'
theme.fg_overlay = '#ffffff'
theme.timebar_line = __dirname..'assets/timebar_line.svg'
theme.taskbar_line = __dirname..'assets/taskbar_line.svg'

theme.shadowed_circle = __dirname..'assets/'..config.color..'/shadowed/circle.svg'
theme.circle_mic =      __dirname..'assets/'..config.color..'/shadowed/circle_mic.svg'
theme.circle_ellipses = __dirname..'assets/'..config.color..'/shadowed/circle_ellipses.svg'
theme.notification_bg = __dirname..'assets/'..config.color..'/shadowed/notification.svg'

theme.weather_icon_dir = __dirname..'assets/weather/'

theme.fallback_icon = theme.shadowed_circle

theme.fg_normal = '#000000'
theme.fg_focus = '#000000'
theme.bg_focus = '#ffa500'
theme.bg_normal = '#ffffff'

theme.fg_cursor = theme.bg_focus
theme.bg_selection = theme.fg_cursor .. '7f'

theme.tasklist_bg_normal = '#ffffff'

return theme


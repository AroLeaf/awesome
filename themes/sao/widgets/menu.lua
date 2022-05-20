local gears = require('gears')
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local launcher = require('widgets/launcher')
local audio = require('widgets/audio')

return function (s, config)
  local change_colors = {
    name = 'Change Colors',
    icon = beautiful.icon_change_colors,
    run = function ()
      config.colors = config.colors == 'sao' and 'ggo' or 'sao'
      config.save_local(config)
      awesome.restart()
    end
  }
  
  local options = {
    launcher(s, config),
    audio(s, config),
    change_colors,
  }

  local items = {
    widget = wibox.container.margin,
    layout = wibox.layout.fixed.vertical,
    spacing = beautiful.menu_spacing / 2,
    forced_width = 192,
  }

  for i = 1, #options do
    items[i] = {
      widget = wibox.container.margin,
      left = i == math.ceil(#options/2) and 4 or 12,
      {
        shape = i == math.ceil(#options/2) and function (cr) gears.shape.transform(gears.shape.infobubble):rotate_at(24, 24, -math.pi/2)(cr, 48, 192, 0, 8, 16) end or gears.shape.rectangle,
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        {
          widget = wibox.container.margin,
          left = i == math.ceil(#options/2) and 24 or 16,
          {
            widget = wibox.container.place,
            forced_height = 48,
            halign = 'left',
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = 8,
              {
                widget = wibox.widget.imagebox,
                image = options[i].icon.normal,
                forced_height = 24,
                forced_width = 24,
              },
              {
                widget = wibox.widget.textbox,
                text = options[i].name,
              },
            },
          }
        }
      }
    }
  end

  local menu = awful.popup({
    widget = items,
    ontop = true,
    bg = '#00000000',
    placement = function (c) awful.placement.left(c, { offset = { x = 96, y = (awful.screen.focused().selected_tag.index - (config.num_tags+1)/2) * 64 + (#options+1)%2*24 } }) end,
    visible = false,
  })
  
  function menu:show(start_at)
    self.y = self.screen.geometry.height/2 - self.height/2 + (self.screen.selected_tag.index - (config.num_tags+1)/2) * 64 + (#options+1)%2*24;
    local keep_taglist = self.screen.taglist.ontop
    
    local selected = start_at or 1
    
    local function update()
      for i = 1, #options do
        local widget = self.widget.children[i].widget
        widget.fg = i == selected and beautiful.fg_focus or beautiful.fg_normal
        widget.bg = i == selected and beautiful.bg_focus or beautiful.bg_normal
        widget.widget.widget.widget.children[1].image = i == selected and options[i].icon.focus or options[i].icon.normal
      end
    end
    
    update()
    
    local grabber
    
    local function up()
      selected = math.max(1, selected - 1)
      update()
    end
    
    local function down()
      selected = math.min(#options, selected + 1)
      update()
    end
    
    local function close()
      grabber:stop()
      self.visible = false
      self.screen.taglist.ontop = keep_taglist
    end
    
    local function on_close(again)
      if (again and not start_at) then grabber:start() else close() end
    end
    
    local function select()
      grabber:stop()
      options[selected].run(on_close)
    end
    
    grabber = awful.keygrabber({
      keybindings = {
        {{}, 'Up', up},
        {{}, 'Down', down},
        {{}, 'Right', select},
        {{}, 'Return', select},
        {{}, 'Escape', close},
        {{}, 'Left', close},
      },
    })
    
    grabber:start()
    self.screen.taglist.ontop = true
    self.visible = true
    if (start_at) then select() end
  end
  
  return menu
end


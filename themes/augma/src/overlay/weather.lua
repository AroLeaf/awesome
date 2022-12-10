local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local OWM = require('lib.openweathermap')

local secrets = require('secrets')

local function get_weather_icon(code)
  local str = tostring(code)

  local function construct (name) return beautiful.weather_icon_dir .. name .. '.svg' end
  local function char(idx) return str:sub(idx,idx) end

  if char(1) == '2' then return construct('thunder') end
  if char(1) == '3' then
    if code < 313 then return construct('rain'..tostring(tonumber(char(3))+1))
    elseif code == 314 then return construct('rain3')
    else return construct('rain2') end
  end
  if char(1) == '5' then
    if char(2) == '1' then return construct('snow')
    else return construct('rain'..tostring(math.min(tonumber(char(3))+1, 4))) end
  end
  if char(1) == '6' then return construct('snow') end
  if char(1) == '7' then return construct('fog') end
  if char(1) == '8' then
    if code == 800 then return construct('sunny')
    elseif code == 804 then return construct('cloudy')
    else return construct('partly_cloudy') end
  end

  -- fallback
  return construct('sunny')
end


return function (s, config)
  local weather_widget = wibox.widget({
    point = {
      x = 96,
      y = 128,
    },

    widget = wibox.container.background,
    shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 8) end,
    {
      layout = wibox.layout.fixed.horizontal,
      -- condition
      {
        widget = wibox.container.background,
        bg = '#df8f007f',
        {
          widget = wibox.container.place,
          halign = 'center',
          {
            widget = wibox.container.margin,
            margins = 16,
            {
              widget = wibox.widget.imagebox,
              id = 'condition',
              image = beautiful.weather_icon_dir..'sunny'..'.svg',
              forced_width = 128,
              forced_height = 96,
            },
          },
        },
      },
      -- temp
      {
        widget = wibox.container.background,
        bg = '#9f6f007f',
        fg = '#ffffff',
        {
          widget = wibox.container.margin,
          margins = 16,
          {
            layout = wibox.layout.fixed.vertical,
            spacing = 8,
            {
              widget = wibox.container.background,
              border_width = 1,
              border_color = '#ffffff',
              shape = function (c, w, h) gears.shape.rounded_rect(c, w, h, 4) end,
              {
                widget = wibox.container.margin,
                margins = {
                  top = 4,
                  bottom = 4,
                  left = 8,
                  right = 8,
                },
                {
                  widget = wibox.widget.textbox,
                  font = 'Open Sans Bold 11',
                  text = config.location or '',
                },
              },
            },
            {
              widget = wibox.container.place,
              valign = 'center',
              {
                widget = wibox.widget.textbox,
                id = 'temperature',
                font = 'Open Sans 32',
                text = '...',
              },
            }
          },
        },
      },
    },
  })

  local owm = OWM(secrets.openweathermap)

  local function update(weather)
    weather_widget:get_children_by_id('temperature')[1].text = tostring(math.floor(weather.main.temp + 0.5)) .. '°'
    weather_widget:get_children_by_id('condition')[1].image = get_weather_icon(weather.weather[1].id)
  end

  owm:geo(config.location).next(function (loc)
    gears.timer({
      timeout = 5 * 60,
      autostart = true,
      call_now = true,
      callback = function () owm:now(loc).next(update) end,
    })
  end)

  return weather_widget
end


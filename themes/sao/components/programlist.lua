local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local program = require('components/program')

return function (options)
  local max = options.max or 12

  local programlist = wibox.widget({
    layout = wibox.layout.fixed.vertical,
    forced_height = 40 * max,
  })

  programlist.selected = 1
  programlist.scroll = 0
  
  function programlist:update(programs)
    self.programs = programs
    self:reset(wibox.layout.fixed.vertical)
    
    if (self.selected > programlist.scroll + max) then programlist.scroll = self.selected - max end
    if (self.selected <= programlist.scroll) then programlist.scroll = self.selected - 1 end
    
    for i, prgm in ipairs(programs) do
      if (i > self.scroll and i <= self.scroll + max) then
        self:add(program(prgm, i == self.selected))
      end
    end
  end
  
  function programlist:length()
    return #self.children
  end

  programlist:update(options.programs)
  
  return programlist
end


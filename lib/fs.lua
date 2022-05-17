local gfs = require('gears.filesystem')

local function write_file(path, data)
  local file = io.open(path, 'w')
  file:write(data)
  file:close()
end

local function read_file(path)
  if (gfs.file_readable(path)) then
    local file = io.open(path, 'r')
    local contents = file:read('a')
    file:close()
    return contents
  else
    return nil
  end
end

local function scan_directory(directory)
  local files = {}
  local list = io.popen('ls -a "'..directory..'"')
  for file in list:lines() do
    if (file ~= '..' and file ~= '.') then table.insert(files, file) end
  end
  list:close()
  return files
end

return {
  read = read_file,
  write = write_file,
  scan = scan_directory,
}


local DataDumper = require "libraries.DataDumper"

local function load(filename)
  local strdata = love.filesystem.read(filename)
  if strdata then
    local f = loadstring(strdata)
    if f then
      setfenv(f, {})
      if pcall(f) then
        local data = f()
        if type(data) == "table" then
          return data
        end
      end
    end
  end
  return nil
end

local function save(filename, data)
  love.filesystem.write(filename, DataDumper(data))
end

local function remove(filename)
  love.filesystem.remove(filename)
end

local function lastModified(filename)
  return love.filesystem.getLastModified(filename)
end

return {
  load = load;
  save = save;
  remove = remove;
  lastModified = lastModified;
}
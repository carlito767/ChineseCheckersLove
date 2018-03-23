--[[
  ****************************************************************************
  Noyau

  Inspiré de : Immediate Mode GUI : https://mollyrocket.com/861
  ****************************************************************************
]]

local LONG_PRESS_BEGIN = 0.2
local LONG_PRESS_END   = 0.6

-- Compteur d'objets
local idCounter = 0

-- Image courante
local hot = nil
local active = nil
local hit = nil
local longPress = nil
local longPressDuration = 0

-- Image suivante
local next = nil

-- Périphérique d'entrée
local x = 0
local y = 0
local select = false

local function start(inputX, inputY, inputSelect)
  x = inputX
  y = inputY
  select = inputSelect

  idCounter = 0
  next = nil
end

local function stop()
  local dt = love.timer.getDelta()

  hot = nil
  hit = nil
  longPress = nil

  if next then
    hot = next
    if select then
      if active ~= next then
        active = next
        longPressDuration = 0
      elseif longPressDuration < LONG_PRESS_END then
        longPressDuration = longPressDuration + dt
        if longPressDuration >= LONG_PRESS_END then
          longPress = next
        end
      end
    elseif active == next and longPressDuration < LONG_PRESS_BEGIN then
      hit = next
    end
  end
  if not select then
    active = nil
  end
end

local function evaluate(object)
  idCounter = idCounter + 1
  local id = idCounter

  -- Image suivante
  if object.x and object.y and object.width and object.height then
    if x >= object.x and y >= object.y and x <= object.x + object.width and y <= object.y + object.height then
      next = id
    end
  end

  -- Image courante
  return {
    hot = (id == hot);
    active = (id == active);
    hit = (id == hit);
    longPress = (id == longPress);
    longPressRatio = (id == active and longPressDuration > LONG_PRESS_BEGIN) and math.min(longPressDuration / LONG_PRESS_END, 1) or 0;
  }
end

--[[
  ****************************************************************************
  Objets
  ****************************************************************************
]]

local Board = require "sources.board"
local RGB   = require "sources.rgb"

-- Ressources
local fontXL = love.graphics.newFont('assets/fonts/Maharani.otf', 34)
local fontL = love.graphics.newFont('assets/fonts/Maharani.otf', 28)
local fontM = love.graphics.newFont('assets/fonts/Maharani.otf', 26)
local fontS = love.graphics.newFont('assets/fonts/Maharani.otf', 20)
local fontTitle = love.graphics.newFont('assets/fonts/BatikGangster.otf', 100)
local fontStandings = love.graphics.newFont('assets/fonts/Maharani.otf', 80)

local function stateValue(eval, activeValue, hotValue, defaultValue)
  if eval.active then
    return activeValue
  elseif eval.hot then
    return hotValue
  else
    return defaultValue
  end
end

--[[ Board ]]--

local radius = 16                 -- rayon d'un pion
local distanceX = radius * 1.25   -- distance entre 2 cases horizontalement
local distanceY = distanceX * 1.7 -- distance entre 2 cases verticalement
local segments = 2 * radius       -- nombre de segments composant les cercles (pion et joueur)

local function screenCoordinates(object, tile)
  local boardWidth  = ((#object.board.matrix[1] - 1) * distanceX) + (2 * radius)
  local boardHeight = ((#object.board.matrix - 1) * distanceY) + (2 * radius)
  local x = (object.width - boardWidth) / 2
  local y = (object.height - boardHeight) / 2
  local dx = radius + ((tile.x - 1) * distanceX)
  local dy = radius + ((tile.y - 1) * distanceY)
  return {
    x = x + dx,
    y = y + dy,
  }
end

local function drawSelection(object, tile)
  local coordinates = screenCoordinates(object, tile)
  love.graphics.setColor(RGB.white)
  love.graphics.setLineWidth(2)
  love.graphics.circle("line", coordinates.x, coordinates.y, radius * 1.15, segments)
  love.graphics.setLineWidth(1)
end

local function drawPlayer(player, x, y, width, height, lineColor)
  local px, py = x + (width / 2), y + (height / 2)
  local radius = (math.min(width, height) * 0.75) / 2
  love.graphics.setColor(player.color)
  love.graphics.circle("fill", px, py, radius, 2 * radius)
  love.graphics.setColor(lineColor or player.color)
  love.graphics.circle("line", px, py, radius, 2 * radius)
end

local function board(object)
  local eval = evaluate(object)

  local currentPlayer = Board.currentPlayer(object.board)

  -- Plateau de jeu
  for _,tile in ipairs(object.board.tiles) do
    local coordinates = screenCoordinates(object, tile)

    -- Case et pion
    if tile.piece then
      love.graphics.setColor(Board.player(object.board, tile.piece).color)
      love.graphics.circle("fill", coordinates.x, coordinates.y, radius, segments)
    end
    love.graphics.setColor(RGB.black)
    love.graphics.circle("line", coordinates.x, coordinates.y, radius, segments)

    -- Identifiant de la case
    if DEVMODE_SHOW_TILES_ID then
      local id = tostring(tile.id)
      local playerColor = tile.piece and Board.player(object.board, tile.piece).color or RGB.black
      local color = { 255 - playerColor[1], 255 - playerColor[2], 255 - playerColor[3] }
      love.graphics.setColor(color)
      love.graphics.setFont(fontS)
      love.graphics.printf(id, coordinates.x - (fontS:getWidth(id) / 2), coordinates.y - (fontS:getHeight(id) / 2), HEIGHT)
    end
  end

  -- Case sélectionnée
  if object.selectedTile then
    local origin = object.board.tiles[object.selectedTile.id]
    drawSelection(object, origin)

    -- Mouvements possibles
    if DEVMODE_SHOW_ALLOWED_MOVES then
      for _,move in ipairs(Board.allowedMoves(object.board, object.selectedTile.id)) do
        local destination = object.board.tiles[move]
        drawSelection(object, destination)
      end
    end
  end

  -- Joueur courant
  if currentPlayer then
    local x, y, width, height = 20, 20, 100, 100
    love.graphics.setColor(RGB.alpha(RGB.black, 50))
    love.graphics.rectangle("fill", x, y, width, height, 10)
    love.graphics.setColor(RGB.alpha(RGB.black, 200))
    love.graphics.rectangle("line", x, y, width, height, 10)
    drawPlayer(currentPlayer, x, y, width, height)
  end

  return eval
end

--[[ Button ]]--

local function button(object)
  local eval = evaluate(object)

  love.graphics.setColor(RGB.alpha(RGB.black, 200))
  love.graphics.rectangle("fill", object.x, object.y, object.width, object.height, 10)
  local borderColor = object.selected and RGB.yellow or stateValue(eval, RGB.yellow, RGB.aqua, RGB.gray)
  love.graphics.setColor(borderColor)
  love.graphics.rectangle("line", object.x, object.y, object.width, object.height, 10)
  local fontColor = object.selected and RGB.yellow or stateValue(eval, RGB.yellow, RGB.aqua, RGB.white)
  love.graphics.setColor(fontColor)
  love.graphics.setFont(fontL)
  local dy = (object.height - (fontL:getHeight())) / 2
  love.graphics.printf(object.text, object.x, object.y + dy, object.width, "center")

  return eval
end

--[[ Checkbox ]]--

local function checkbox(object)
  local eval = evaluate(object)

  local boxSize = math.min(object.width, object.height)
  local color = object.checked and RGB.white or stateValue(eval, RGB.white, RGB.aqua, RGB.gray)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", object.x + (boxSize * 0.2), object.y + (boxSize * 0.2), boxSize * 0.6, boxSize * 0.6)
  if object.checked then
    love.graphics.setLineJoin("bevel")
    love.graphics.line(
      object.x + (boxSize * 0.35), object.y + (boxSize * 0.50),
      object.x + (boxSize * 0.45), object.y + (boxSize * 0.65),
      object.x + (boxSize * 0.70), object.y + (boxSize * 0.30)
    )
  end
  love.graphics.setColor(color)
  love.graphics.setFont(fontL)
  local dy = (object.height - (fontL:getHeight())) / 2
  love.graphics.printf(object.text, object.x + (boxSize * 1.1), object.y + dy, object.width, "left")

  return eval
end

--[[ Image ]]--

local function image(object)
  local eval = evaluate(object)

  love.graphics.setColor(object.color or RGB.white)
  love.graphics.draw(object.image)

  return eval
end

--[[ Image Button ]]--

local function imageButton(object)
  local eval = evaluate(object)

  love.graphics.setColor(RGB.alpha(RGB.black, 200))
  love.graphics.rectangle("fill", object.x, object.y, object.width, object.height, 10)
  local borderColor = stateValue(eval, RGB.yellow, RGB.aqua, RGB.gray)
  love.graphics.setColor(borderColor)
  love.graphics.rectangle("line", object.x, object.y, object.width, object.height, 10)
  local width, height = object.image:getDimensions()
  local sx = object.sx or object.width / width
  local sy = object.sy or object.height / height
  local imageColor = stateValue(eval, RGB.yellow, RGB.aqua, RGB.white)
  love.graphics.setColor(imageColor)
  love.graphics.draw(object.image, object.x, object.y,
    object.r or 0,
    sx,
    sy,
    object.ox or 0,
    object.oy or 0,
    object.kx or 0,
    object.ky or 0
  )

  return eval
end

--[[ Label ]]--

local function label(object)
  local eval = evaluate(object)

  local font = (object.title) and fontTitle or fontL
  love.graphics.setFont(font)
  love.graphics.setColor(object.color or RGB.white)
  love.graphics.printf(object.text, object.x, object.y, object.width, object.align)

  return eval
end

--[[ Pie ]]--

local function pie(object)
  local eval = evaluate(object)

  -- Contournement de bug LÖVE
  -- https://bitbucket.org/rude/love/issues/855/seemingly-infinite-outline-on-arc-as
  love.graphics.setLineJoin("none")
  love.graphics.setColor(RGB.red)
  love.graphics.arc("fill", "pie", object.x + object.radius, object.y + object.radius, object.radius, object.angle1, object.angle2, 2 * object.radius)
  love.graphics.setColor(RGB.yellow)
  love.graphics.arc("line", "pie", object.x + object.radius, object.y + object.radius, object.radius, object.angle1, object.angle2, 2 * object.radius)

  return eval
end

--[[ Saveslot ]]--

local function saveslot(object)
  local eval = evaluate(object)

  love.graphics.setColor(RGB.alpha(RGB.black, 100))
  love.graphics.rectangle("fill", object.x, object.y, object.width, object.height, 10)
  local color = stateValue(eval, RGB.yellow, RGB.aqua, RGB.white)
  love.graphics.setColor(color)
  love.graphics.rectangle("line", object.x, object.y, object.width, object.height, 10)
  if object.slot.board then
    -- Date et heure de la sauvegarde
    local width = object.width * 0.25
    local dy = (object.height - (2 * fontS:getHeight())) / 2.5
    love.graphics.setFont(fontS)
    if object.slot.lastModified then
      love.graphics.printf(os.date(tr("dateFormat"), object.slot.lastModified), object.x, object.y + dy, width, "center")
      love.graphics.printf(os.date(tr("timeFormat"), object.slot.lastModified), object.x, object.y + object.height - fontS:getHeight() - dy, width, "center")
    end
    -- Séparateur
    local sx = object.x + width
    love.graphics.line(sx, object.y, sx, object.y + object.height)
    -- Plateau de jeu utilisé, nombre de joueurs et de coups joués
    local board = object.slot.board
    local players = #board.order
    local playersFormat = (players > 1) and "playersFormat" or "playerFormat"
    local playersText = string.format(tr(playersFormat), players)
    local moves = #board.moves
    local movesFormat = (moves > 1) and "movesFormat" or "moveFormat"
    local movesText = string.format(tr(movesFormat), moves)
    local text = string.format(" %s, %s", playersText, movesText)
    local dy = ((object.height - (fontL:getHeight() + fontS:getHeight())) / 2)
    love.graphics.printf(tr(board.id), sx, object.y + object.height - fontS:getHeight() - dy, object.width - width, "center")
    love.graphics.setFont(fontL)
    love.graphics.printf(text, sx, object.y + dy, object.width - width, "center")
  else
    -- Nouvelle partie
    local dy = ((object.height - (fontM:getHeight())) / 2)
    love.graphics.setFont(fontM)
    love.graphics.printf(tr("newGame"), object.x, object.y + dy, object.width, "center")
  end

  return eval
end

--[[ Shadow ]]--

local function shadow(object)
  local eval = evaluate(object)

  local color = object.color or { 255, 255, 255, 0 }
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", object.x, object.y, object.width, object.height)

  return eval
end

--[[ Window ]]--

local function window(object)
  local eval = evaluate(object)

  love.graphics.setColor(RGB.black)
  love.graphics.rectangle("fill", object.x, object.y, object.width, object.height, 10)
  love.graphics.setColor(RGB.yellow)
  love.graphics.rectangle("line", object.x, object.y, object.width, object.height, 10)

  return eval
end

--[[
  ****************************************************************************
  Fonctions
  ****************************************************************************
]]

local function dimensions(window)
  if not window then
    window = { x = 0; y = 0; width = WIDTH; height = HEIGHT }
  end
  local margin = window.width * 0.05
  local width = window.width - 2 * margin
  local height = window.height - 2 * margin
  local left = window.x + margin
  local right = left + width
  local top = window.y + margin
  local bottom = top + height
  return margin, width, height, left, right, top, bottom
end

local function screenTile(object)
  for _,tile in ipairs(object.board.tiles) do
    local coordinates = screenCoordinates(object, tile)
    local okX = (x >= coordinates.x - radius) and (x <= coordinates.x + radius)
    local okY = (y >= coordinates.y - radius) and (y <= coordinates.y + radius)
    if okX and okY then
      return tile
    end
  end
  return nil
end

local function standings(board)
  shadow({ x = 0, y = 0, width = WIDTH, height = HEIGHT, color = RGB.alpha(RGB.black, 200) })

  love.graphics.setColor(RGB.yellow)
  love.graphics.setFont(fontStandings)
  love.graphics.printf(tr("standings"), 0, HEIGHT * 0.05, WIDTH, "center")

  local x = WIDTH * 0.2
  local y = HEIGHT * 0.2
  local width = WIDTH - 2 * x
  local height = HEIGHT * 0.1
  for i = 1,#board.order do
    -- Emplacement
    local dy = (i - 1) * HEIGHT * 0.12
    love.graphics.setColor(RGB.black)
    love.graphics.rectangle("fill", x, y + dy, width, height, 10)
    love.graphics.setColor(RGB.white)
    love.graphics.rectangle("line", x, y + dy, width, height, 10)
    -- Séparateur
    local sx = WIDTH * 0.3
    love.graphics.line(sx, y + dy, sx, y + dy + height)
    -- Position
    local py = (height - fontXL:getHeight()) * 0.5
    love.graphics.setFont(fontXL)
    love.graphics.printf(i, x, y + dy + py, sx - x, "center")
    -- Joueur
    local id = board.standings[i]
    if id then
      local player = Board.player(board, id)
      drawPlayer(player, (WIDTH - height * 0.9) * 0.5, y + dy + height * 0.05, height * 0.9, height * 0.9, RGB.white)
    end
  end
end

--[[
  ****************************************************************************
  Interface
  ****************************************************************************
]]

return {
  -- Noyau
  start = start;
  stop = stop;
  evaluate = evaluate;
  -- Objets
  board = board;
  button = button;
  checkbox = checkbox;
  image = image;
  imageButton = imageButton;
  label = label;
  pie = pie;
  saveslot = saveslot;
  shadow = shadow;
  window = window;
  -- Fonctions utilitaires
  dimensions = dimensions;
  screenTile = screenTile;
  standings = standings;
}
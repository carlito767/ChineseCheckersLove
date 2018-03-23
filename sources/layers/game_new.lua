local Board = require "sources.board"

local arrowLeft = love.graphics.newImage('assets/images/arrow_left.png')
local arrowRight = love.graphics.newImage('assets/images/arrow_right.png')

local boardIndex = 1
local modeIndex = 1

local function draw(game, ui)
  ui.shadow({ x = 0; y = 0; width = WIDTH; height = HEIGHT })

  local window = { x = 200; y = 150; width = 400; height = 300 }
  local margin, width, height, left, right, top, bottom = ui.dimensions(window)
  ui.window(window)

  -- Plateau de jeu
  ui.label({ text = tr("board"); x = left; y = top; width = width; height = 40 })

  local arrow_left = ui.imageButton({ x = left; y = top + 45; width = 30; height = 30; image = arrowLeft })
  local arrow_right = ui.imageButton({ x = right - 30; y = top + 45; width = 30; height = 30; image = arrowRight })
  if arrow_left.hit or arrow_right.hit then
    if arrow_left.hit then
      boardIndex = boardIndex - 1
      if boardIndex == 0 then
        boardIndex = #Boards
      end
    end

    if arrow_right.hit then
      boardIndex = boardIndex + 1
      if boardIndex > #Boards then
        boardIndex = 1
      end
    end

    modeIndex = 1
  end
  ui.label({ text = tr(Boards[boardIndex].id); x = left + 50; y = top + 45; width = width - 100; height = 40 })

  -- Nombre de joueurs
  ui.label({ text = tr("numberOfPlayers"); x = left; y = top + 105; width = width; height = 40 })

  for i,mode in ipairs(Boards[boardIndex].modes) do
    if ui.button({
      text = mode.id;
      x = left + ((i - 1) * 60);
      y = top + 150;
      width = 40;
      height = 40;
      selected = (modeIndex == i);
    }).hit then
      modeIndex = i
    end
  end

  -- Boutons d'action
  if ui.button({ text = tr("cancel"); x = right - 210; y = bottom - 30; width = 100; height = 30 }).hit then
    popLayer()
  end
  if ui.button({ text = tr("play"); x = right - 100; y = bottom - 30; width = 100; height = 30 }).hit then
    game.slot.board = Board.new(Boards[boardIndex], modeIndex)
    switchLayer("play")
  end
end

return draw
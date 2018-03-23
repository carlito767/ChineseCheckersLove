local Board = require "sources.board"

local function draw(game, ui)
  -- Classement
  ui.standings(game.slot.board)

  -- Boutons d'action
  local margin, width, height, left, right, top, bottom = ui.dimensions()

  if ui.button({ text = tr("restart"); x = right - 210; y = bottom - 30; width = 100; height = 30 }).hit then
    Board.reset(game.slot.board)
    popLayer()
  end
  if ui.button({ text = tr("quit"); x = right - 100; y = bottom - 30; width = 100; height = 30 }).hit then
    removeGame()
    switchLayer("title")
  end
end

return draw
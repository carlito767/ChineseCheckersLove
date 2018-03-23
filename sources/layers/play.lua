local Board   = require "sources.board"

local background = love.graphics.newImage('assets/images/background_play.png')

local function draw(game, ui)
  ui.image({ image = background })

  -- Plateau de jeu
  local uiBoard = { x = 0; y = 0; width = WIDTH; height = HEIGHT; board = game.slot.board; selectedTile = game.selectedTile }
  if ui.board(uiBoard).hit then
    local board = uiBoard.board
    if not Board.isOver(board) then
      local tile = ui.screenTile(uiBoard)
      if tile then
        if game.selectedTile and Board.move(board, game.selectedTile.id, tile.id) then
          -- Validation du coup
          game.selectedTile = nil
          saveGame()
          if Board.isOver(board) then
            pushLayer("game_over")
          end
        elseif (not game.selectedTile or game.selectedTile ~= tile) and #Board.allowedMoves(board, tile.id) > 0 then
          -- Sélection de la case
          game.selectedTile = tile
        else
          -- Annulation de la sélection
          game.selectedTile = nil
        end
      else
          -- La case n'est pas valide, on annule la sélection courante
          game.selectedTile = nil
      end
    end
  end

  -- Boutons d'action
  if ui.button({ text = tr("quit"); x = 680; y = 20; width = 100; height = 30 }).hit then
    if #game.slot.board.moves == 0 then
      removeGame()
    end
    switchLayer("title")
  end
end

return draw
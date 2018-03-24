local VERSION = 1

local function contains(t, value)
  for _,v in ipairs(t) do
    if value == v then
      return true
    end
  end
  return false
end

--[[ Initialisation ]]--

local function new(rawBoard, modeIndex)
  -- Joueurs
  local mode = rawBoard.modes[modeIndex]
  local players = {}
  local owners = {}
  for _,id in ipairs(mode.order) do
    local player = rawBoard.players[id]
    players[tostring(id)] = {
      id = id;
      color = player.color;
    }
    owners[tostring(player.home)] = id
  end

  -- Plateau de jeu
  local matrix = {}
  local tiles = {}
  for y,row in ipairs(rawBoard.board) do
    matrix[y] = {}
    local x = 0
    for value in string.gmatch(row, ".") do
      x = x + 1

      local tile = {}
      if value ~= " " then
        tile = {
          id = #tiles + 1;
          x = x;
          y = y;
          owner = owners[value];
          piece = players[value] and tonumber(value) or nil;
        }
        table.insert(tiles, tile)
      end

      matrix[y][x] = tile
    end
  end

  return {
    version = VERSION;
    id = rawBoard.id;
    order = mode.order;
    players = players;
    matrix = matrix;
    tiles = tiles;
    moves = {};
    standings = {};
  }
end

local function load(board)
  if board and board.version == VERSION then
    return board
  end
  return nil
end

local function isOver(board)
  return #board.standings == #board.order
end

--[[ Joueurs ]]--

local function player(board, id)
  return board.players[tostring(id)]
end

local function currentPlayer(board)
  if isOver(board) then
    return nil
  end
  if #board.moves == 0 then
    return player(board, board.order[1])
  end
  local move = board.moves[#board.moves]
  local previous = board.tiles[move[2]].piece
  local index = nil
  for i,id in ipairs(board.order) do
    if id == previous then
      index = i
      break
    end
  end
  repeat
    index = index + 1
    if index > #board.order then
      index = 1
    end
  until (not contains(board.standings, board.order[index]))
  return player(board, board.order[index])
end

--[[ Coups possibles ]]--

local function tileXY(board, x, y)
  if board.matrix[y] and board.matrix[y][x] then
    return board.matrix[y][x]
  end
  return {}
end

-- Cases adjacentes
local function neighbors(board, id)
  local tile = board.tiles[id]
  if not tile then
    return {}
  end

  --[[
          (1) (2)
            \ /
        (3)- * -(4)
            / \
          (5) (6)
  ]]--
  return {
    tileXY(board, tile.x - 1, tile.y - 1),    -- (1)
    tileXY(board, tile.x + 1, tile.y - 1),    -- (2)
    tileXY(board, tile.x - 2, tile.y    ),    -- (3)
    tileXY(board, tile.x + 2, tile.y    ),    -- (4)
    tileXY(board, tile.x - 1, tile.y + 1),    -- (5)
    tileXY(board, tile.x + 1, tile.y + 1),    -- (6)
  }
end

-- Cases accessibles par saut
local function jumps(board, id, moves)
  for i,neighbor in ipairs(neighbors(board, id)) do
    if neighbor.id and neighbor.piece then
      local jump = neighbors(board, neighbor.id)[i]
      if jump.id and not jump.piece and not contains(moves, jump.id) then
        table.insert(moves, jump.id)
        jumps(board, jump.id, moves)
      end
    end
  end
end

local function allowedMoves(board, id)
  local tile = board.tiles[id]
  if not tile or not tile.piece or tile.piece ~= currentPlayer(board).id then
    return {}
  end

  local moves = {}
  -- Sauts possibles
  jumps(board, id, moves)
  -- Cases adjacentes accessibles
  for _,neighbor in ipairs(neighbors(board, id)) do
    if neighbor.id and not neighbor.piece then
      table.insert(moves, neighbor.id)
    end
  end

  -- Un pion qui a atteint sa maison ne peut plus la quitter
  if tile.owner == currentPlayer(board).id then
    for i = #moves,1,-1 do
      local moveTile = board.tiles[moves[i]]
      if moveTile.owner ~= currentPlayer(board).id then
        table.remove(moves, i)
      end
    end
  end

  return moves
end

--[[ Déplacements ]]--

local function victory(board, id)
  for _,tile in ipairs(board.tiles) do
    if tile.piece == id and tile.owner ~= id then
      return false
    end
  end
  return true
end

local function move(board, from, to)
  if not contains(allowedMoves(board, from), to) then
    return false
  end
  local origin = board.tiles[from]
  local destination = board.tiles[to]
  destination.piece = origin.piece
  origin.piece = nil
  table.insert(board.moves, { from, to })

  if victory(board, destination.piece) then
    table.insert(board.standings, destination.piece)
    if #board.standings == #board.order - 1 then
      -- Qui est le grand perdant ?
      for _,id in ipairs(board.order) do
        if not contains(board.standings, id) then
          table.insert(board.standings, id)
          break
        end
      end
    end
  end

  return true
end

local function cancelLastMove(board)
  if #board.moves > 0 then
    local move = board.moves[#board.moves]
    table.remove(board.moves, #board.moves)
    local origin = board.tiles[move[1]]
    local destination = board.tiles[move[#move]]
    origin.piece = destination.piece
    destination.piece = nil

    if #board.standings > 0 and board.standings[#board.standings] == origin.piece then
      table.remove(board.standings,  #board.standings)
    end
  end
end

--[[ Réinitialisation ]]--

local function reset(board)
  board.standings = {}
  while #board.moves > 0 do
    cancelLastMove(board)
  end
end

--[[ Interface ]]--

return {
  version = VERSION;
  -- Initialisation
  new = new;
  load = load;
  isOver = isOver;
  -- Joueurs
  player = player;
  currentPlayer = currentPlayer;
  -- Coups possibles
  allowedMoves = allowedMoves;
  -- Déplacements
  move = move;
  cancelLastMove = cancelLastMove;
  -- Réinitialisation
  reset = reset;
}
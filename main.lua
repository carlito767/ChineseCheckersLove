require "devmode"

local Board   = require "sources.board"
local Scaling = require "sources.scaling"
local Storage = require "sources.storage"

TITLE = "ChineseCheckersLöve"
ID = "chinese.checkers.love"
WIDTH = 800
HEIGHT = 600

-- Affichage des identifiants des cases
DEVMODE_SHOW_TILES_ID = false
-- Affichage des coups possibles
DEVMODE_SHOW_ALLOWED_MOVES = true

-- Interface graphique
local ui = nil
-- Calques
local layers = {}
-- Écran affiché (constitué d'une pile de calques)
local screen = {}
-- Données de la partie courante
local game = {}

--[[ Gestion des sauvegardes ]]--

local function slotname(id)
  return string.format("gamesave%d.lua", id)
end

function removeGame()
  local slot = game.slot
  if slot then
    if slot.lastModified then
      Storage.remove(slotname(slot.id))
      slot.lastModified = nil
    end
    slot.creationTime = 0
    slot.board = nil
  end
end

function saveGame()
  local slot = game.slot
  if slot and slot.board then
    if slot.creationTime == 0 then
      slot.creationTime = os.time()
    end
    Storage.save(slotname(slot.id), {
      creationTime = slot.creationTime;
      board = slot.board;
    })
    slot.lastModified = Storage.lastModified(slotname(slot.id))
  end
end

--[[ Gestion des traductions ]]--

function tr(id)
  if not id or not Language then
    return ""
  end
  local translation = Translations[Language]
  if translation and translation[id] then
    return translation[id]
  end
  return id
end

--[[ Gestion des calques ]]--

function popLayer()
  table.remove(screen)
end

function pushLayer(layer)
  if layers[layer] then
    table.insert(screen, layer)
  end
end

function switchLayer(layer)
  if layers[layer] then
    screen = { layer }
  end
end

function topLayer(layer)
  return screen[#screen] == layer
end

--[[ Callbacks ]]--

function love.load()
  math.randomseed(os.time())

  love.window.setTitle(TITLE)
  love.filesystem.setIdentity(ID)

  love.window.setMode(WIDTH, HEIGHT, {
    resizable = true;
    fullscreentype = "desktop";
    highdpi = true;
  })

  -- Chargement des plateaux de jeu
  Boards = {
    require "sources.boards.chinese_checkers",
    require "sources.boards.chinese_checkers_2players",
    require "sources.boards.chinese_checkers_variant",
  }
  if DEVMODE then
    table.insert(Boards, 1, require "sources.boards.chinese_checkers_debug")
  end

  -- Chargement des sauvegardes
  Slots = {}
  for id = 1,4 do
    local board = nil
    local creationTime = 0
    local data = Storage.load(slotname(id))
    if data then
      board = Board.load(data.board)
      creationTime = data.creationTime or 0
    end
    table.insert(Slots, {
      id = id;
      creationTime = creationTime;
      board = board;
      lastModified = board and Storage.lastModified(slotname(id)) or nil;
    })
  end

  -- Chargement des traductions
  Translations = {
    en = require "sources.Languages.en";
    fr = require "sources.Languages.fr";
  }
  Language = "en"

  -- Définition de l'interface graphique
  ui = require "sources.ui"

  -- Chargement des calques
  layers = {
    game_new = require "sources.layers.game_new";
    game_over = require "sources.layers.game_over";
    game_remove = require "sources.layers.game_remove";
    play = require "sources.layers.play";
    title = require "sources.layers.title";
  }

  -- Lancement du jeu
  pushLayer("title")
end

function love.update(dt)
end

function love.draw()
  Scaling.preRender(WIDTH, HEIGHT)
  local x, y = Scaling.position(WIDTH, HEIGHT, love.mouse.getPosition())
  local select = love.mouse.isDown(1)
  ui.start(x, y, select)
  for _,layer in ipairs(screen) do
    layers[layer](game, ui)
  end
  if love.keyboard.isDown("tab") and topLayer("play") then
    ui.standings(game.slot.board)
  end
  ui.stop()
  Scaling.postRender()
end

function love.keypressed(key, scancode, isrepeat)
  if not DEVMODE then
    return
  end

  if key == "kp0" then
    DEVMODE_SHOW_TILES_ID = not DEVMODE_SHOW_TILES_ID
    print("Show Tiles ID: "..tostring(DEVMODE_SHOW_TILES_ID))
  elseif key == "kp." then
    DEVMODE_SHOW_ALLOWED_MOVES = not DEVMODE_SHOW_ALLOWED_MOVES
    print("Show Allowed Moves: "..tostring(DEVMODE_SHOW_ALLOWED_MOVES))
  elseif key == "return" then
    love.window.setFullscreen(not love.window.getFullscreen())
  elseif key == "l" then
    Language = (Language == "en") and "fr" or "en"
  elseif key == "backspace" and topLayer("play") then
    if game.selectedTile then
      game.selectedTile = nil
    else
      Board.cancelLastMove(game.slot.board)
      saveGame()
    end
  end
end
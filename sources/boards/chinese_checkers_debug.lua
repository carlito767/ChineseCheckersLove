local RGB = require "sources.rgb"

-- Identifiant du plateau de jeu
local id = "boardIdDebug"

-- Définition du plateau de jeu
local board = {
  "  2  ",
  " * * ",
  "1 * 3",
}

-- Définition des joueurs
local players = {
  { home = 2, color = RGB.black },
  { home = 3, color = RGB.red },
  { home = 1, color = RGB.green },
}

-- Définition des modes de jeu
local modes = {
  { id = "3", order = { 1, 2, 3 } },
}

return {
  id = id;
  board = board;
  players = players;
  modes = modes;
}
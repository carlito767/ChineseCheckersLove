local RGB = require "sources.rgb"

-- Identifiant du plateau de jeu
local id = "boardIdChineseCheckers"

-- Définition du plateau de jeu
local board = {
  "            4            ",
  "           4 4           ",
  "          4 4 4          ",
  "         4 4 4 4         ",
  "3 3 3 3 * * * * * 5 5 5 5",
  " 3 3 3 * * * * * * 5 5 5 ",
  "  3 3 * * * * * * * 5 5  ",
  "   3 * * * * * * * * 5   ",
  "    * * * * * * * * *    ",
  "   2 * * * * * * * * 6   ",
  "  2 2 * * * * * * * 6 6  ",
  " 2 2 2 * * * * * * 6 6 6 ",
  "2 2 2 2 * * * * * 6 6 6 6",
  "         1 1 1 1         ",
  "          1 1 1          ",
  "           1 1           ",
  "            1            ",
}

-- Définition des joueurs
local players = {
  { home = 4, color = RGB.black },
  { home = 5, color = RGB.teal },
  { home = 6, color = RGB.green },
  { home = 1, color = RGB.red },
  { home = 2, color = RGB.purple },
  { home = 3, color = RGB.yellow },
}

-- Définition des modes de jeu
local modes = {
  { id = "2", order = { 1, 4 } },
  { id = "3", order = { 1, 3, 5 } },
  { id = "4", order = { 1, 3, 4, 6 } },
  { id = "6", order = { 1, 2, 3, 4, 5, 6 } },
}

return {
  id = id;
  board = board;
  players = players;
  modes = modes;
}
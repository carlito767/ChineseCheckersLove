local RGB = require "sources.rgb"

-- Identifiant du plateau de jeu
local id = "boardIdChineseCheckers2Players"

-- Définition du plateau de jeu
local board = {
  "        2        ",
  "       2 2       ",
  "      2 2 2      ",
  "     2 2 2 2     ",
  "    * * * * *    ",
  "   * * * * * *   ",
  "  * * * * * * *  ",
  " * * * * * * * * ",
  "* * * * * * * * *",
  " * * * * * * * * ",
  "  * * * * * * *  ",
  "   * * * * * *   ",
  "    * * * * *    ",
  "     1 1 1 1     ",
  "      1 1 1      ",
  "       1 1       ",
  "        1        ",
}

-- Définition des joueurs
local players = {
  { home = 2, color = RGB.black },
  { home = 1, color = RGB.red },
}

-- Définition des modes de jeu
local modes = {
  { id = "2", order = { 1, 2 } },
}

return {
  id = id;
  board = board;
  players = players;
  modes = modes;
}
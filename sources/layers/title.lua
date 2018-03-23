local background = love.graphics.newImage('assets/images/background_title.png')

local function draw(game, ui)
  ui.image({ image = background })
  ui.label({ text = tr("title1"); x = 350; y = 50; width = WIDTH; title = true })
  ui.label({ text = tr("title2"); x = 380; y = 170; width = WIDTH; title = true })

  -- Langues
  local i = 0
  for id in pairs(Translations) do
    if ui.button({
      text = string.upper(id);
      x = 20 + (i * 50);
      y = 20;
      width = 40;
      height = 40;
      selected = (Language == id);
    }).hit then
      Language = id
    end
    i = i + 1
  end

  -- Emplacements de sauvegarde (triés par heure de création)
  local slots = {}
  local emptySlot = #Boards == 0
  for _,slot in ipairs(Slots) do
    local selected = slot.board
    if not selected and not emptySlot then
      emptySlot = true
      selected = true
    end
    if selected then
      table.insert(slots, slot)
    end
  end
  table.sort(slots, function(a,b) return a.creationTime < b.creationTime end)

  local dy = ((HEIGHT - 270) - (#slots * 50) - ((#slots - 1) * 13)) / 2
  for i,slot in ipairs(slots) do
    local x = 420
    local y = 270 + dy + ((i - 1) * 63)
    local saveslot = ui.saveslot({ x = x; y = y; width = 300; height = 50; slot = slot })
    if saveslot.hit then
      game.slot = slot
      game.selectedTile = nil
      if slot.board then
        switchLayer("play")
      else
        pushLayer("game_new")
      end
    elseif slot.board then
      if saveslot.longPress then
        game.slot = slot
        pushLayer("game_remove")
      elseif saveslot.longPressRatio > 0 then
        ui.pie({
          x = x - 40;
          y = y + 10;
          radius = 15;
          angle1 = 0;
          angle2 = saveslot.longPressRatio * (math.pi * 2);
        })
      end
    end
  end
end

return draw
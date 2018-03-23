local function draw(game, ui)
  ui.shadow({ x = 0; y = 0; width = WIDTH; height = HEIGHT })

  local window = { x = 200; y = 225; width = 400; height = 150 }
  local margin, width, height, left, right, top, bottom = ui.dimensions(window)
  ui.window(window)

  -- Message de confirmation
  ui.label({ text = tr("removeGame"); x = left; y = top; width = width; height = 40 })

  -- Boutons d'action
  if ui.button({ text = tr("yes"); x = left; y = bottom - 30; width = 100; height = 30 }).hit then
    removeGame()
    popLayer()
  end
  if ui.button({ text = tr("no"); x = right - 100; y = bottom - 30; width = 100; height = 30 }).hit then
    popLayer()
  end
end

return draw
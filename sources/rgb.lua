return {
  -- CSS Basic Colors
  -- https://www.w3.org/wiki/CSS/Properties/color/keywords#Basic_Colors

  black   = {   0,   0,   0 }; -- noir
  silver  = { 192, 192, 192 }; -- argent
  gray    = { 128, 128, 128 }; -- gris
  white   = { 255, 255, 255 }; -- blanc
  maroon  = { 128,   0,   0 }; -- bordeaux
  red     = { 255,   0,   0 }; -- rouge
  purple  = { 128,   0, 128 }; -- violet
  fuchsia = { 255,   0, 255 }; -- fuchsia
  green   = {   0, 128,   0 }; -- vert
  lime    = {   0, 255,   0 }; -- vert citron
  olive   = { 128, 128,   0 }; -- jaune olive
  yellow  = { 255, 255,   0 }; -- jaune
  navy    = {   0,   0, 128 }; -- bleu marine
  blue    = {   0,   0, 255 }; -- bleu
  teal    = {   0, 128, 128 }; -- sarcelle
  aqua    = {   0, 255, 255 }; -- bleu-vert eau

  alpha = function(rgb, alpha)
    return { rgb[1], rgb[2], rgb[3], alpha }
  end;
}
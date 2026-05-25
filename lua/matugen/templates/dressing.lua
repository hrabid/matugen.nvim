return function(c, hl)
  -- dressing.nvim
  hl("DressingNormal", { fg = c.on_surface, bg = c.surface_container })
  hl("DressingBorder", { fg = c.primary, bg = c.surface_container })
  hl("DressingTitle", { fg = c.on_primary, bg = c.primary, bold = true })
  hl("DressingInputNormal", { fg = c.on_surface, bg = c.surface_high })
  hl("DressingInputBorder", { fg = c.outline, bg = c.surface_high })
end

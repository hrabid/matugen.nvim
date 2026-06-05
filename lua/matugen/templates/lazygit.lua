return function(c, hl)
  -- lazygit.nvim floating window highlights
  hl("LazyGitFloat", { fg = c.on_surface, bg = c.surface_low })
  hl("LazyGitBorder", { fg = c.outline_variant, bg = c.surface_low })

  -- Terminal ANSI colors used inside the Neovim terminal emulator (used by lazygit)
  vim.g.terminal_color_0 = c.surface_low
  vim.g.terminal_color_8 = c.outline

  vim.g.terminal_color_1 = c.error
  vim.g.terminal_color_9 = c.error

  vim.g.terminal_color_2 = c.tertiary
  vim.g.terminal_color_10 = c.tertiary_container or c.tertiary

  vim.g.terminal_color_3 = c.secondary
  vim.g.terminal_color_11 = c.secondary

  vim.g.terminal_color_4 = c.primary
  vim.g.terminal_color_12 = c.primary

  vim.g.terminal_color_5 = c.secondary_container or c.primary
  vim.g.terminal_color_13 = c.secondary_container or c.primary

  vim.g.terminal_color_6 = c.primary_container
  vim.g.terminal_color_14 = c.primary_container

  vim.g.terminal_color_7 = c.on_surface_variant
  vim.g.terminal_color_15 = c.on_surface
end

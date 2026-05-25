return function(c, hl)
  require("matugen.templates.dressing")(c, hl)
  require("matugen.templates.flash")(c, hl)
  require("matugen.templates.todo_comments")(c, hl)
  require("matugen.templates.render_markdown")(c, hl)
  require("matugen.templates.avante")(c, hl)
  require("matugen.templates.fzf_lua")(c, hl)
end

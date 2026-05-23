return {
  get_colors = function(hex)
    return {
      -- Core surfaces
      surface = hex("editor.background"),
      surface_low = hex("sideBar.background"),
      surface_container = hex("statusBar.background"),
      surface_high = hex("sideBarSectionHeader.background"),
      surface_highest = hex("terminal.inactiveSelectionBackground"),

      -- Text
      on_surface = hex("editor.foreground"),
      on_surface_variant = hex("statusBar.foreground"),
      outline = hex("editorLineNumber.foreground"),
      outline_variant = hex("editorWidget.border"),

      -- Primary (periwinkle blue)
      primary = hex("editorLineNumber.activeForeground"),
      on_primary = hex("button.foreground"),
      primary_container = hex("editorSuggestWidget.selectedBackground"),
      on_primary_container = hex("editorSuggestWidget.selectedForeground"),

      -- Secondary (cool grey-blue)
      secondary = hex("editorWidget.border") ~= hex("editorWarning.foreground") and hex("editorWarning.foreground")
        or "#c3c5dd",
      secondary_container = hex("statusBarItem.remoteBackground"),
      on_secondary_container = hex("statusBarItem.remoteForeground"),

      -- Tertiary (dusty rose)
      tertiary = hex("editorInfo.foreground"),
      tertiary_container = hex("terminal.ansiBrightGreen"),

      -- Error
      error = hex("editorError.foreground"),
      error_container = hex("terminal.ansiBrightRed"),

      -- Selection / highlights
      selection_bg = hex("editor.selectionBackground"),
      word_highlight = hex("editor.wordHighlightBackground"),
      word_highlight_strong = hex("editor.wordHighlightStrongBackground"),

      -- Git
      git_added = hex("editorGutter.addedBackground"),
      git_modified = hex("editorGutter.modifiedBackground"),
      git_deleted = hex("editorGutter.deletedBackground"),
    }
  end,
}

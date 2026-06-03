return {
  get_colors = function(get)
    local fallback = require("matugen.fallback_palette")
    return {
      -- Core surfaces
      surface = get("editor.background") or fallback.surface,
      surface_low = get("sideBar.background") or fallback.surface_low,
      surface_container = get("statusBar.background") or fallback.surface_container,
      surface_high = get("sideBarSectionHeader.background") or fallback.surface_high,
      surface_highest = get("terminal.inactiveSelectionBackground") or fallback.surface_highest,

      -- Text
      on_surface = get("editor.foreground") or fallback.on_surface,
      on_surface_variant = get("statusBar.foreground") or fallback.on_surface_variant,
      outline = get("editorLineNumber.foreground") or fallback.outline,
      outline_variant = get("editorWidget.border") or fallback.outline_variant,

      -- Primary
      primary = get("editorLineNumber.activeForeground") or fallback.primary,
      on_primary = get("button.foreground") or fallback.on_primary,
      primary_container = get("editorSuggestWidget.selectedBackground") or fallback.primary_container,
      on_primary_container = get("editorSuggestWidget.selectedForeground") or fallback.on_primary_container,

      -- Secondary
      secondary = get("editorWarning.foreground") or fallback.secondary,
      secondary_container = get("statusBarItem.remoteBackground") or fallback.secondary_container,
      on_secondary_container = get("statusBarItem.remoteForeground") or fallback.on_secondary_container,

      -- Tertiary
      tertiary = get("editorInfo.foreground") or fallback.tertiary,
      tertiary_container = get("terminal.ansiBrightGreen") or fallback.tertiary_container,

      -- Error
      error = get("editorError.foreground") or fallback.error,
      error_container = get("terminal.ansiBrightRed") or fallback.error_container,

      -- Selection / highlights
      selection_bg = get("editor.selectionBackground") or fallback.selection_bg,
      word_highlight = get("editor.wordHighlightBackground") or fallback.word_highlight,
      word_highlight_strong = get("editor.wordHighlightStrongBackground") or fallback.word_highlight_strong,

      -- Git
      git_added = get("editorGutter.addedBackground") or fallback.git_added,
      git_modified = get("editorGutter.modifiedBackground") or fallback.git_modified,
      git_deleted = get("editorGutter.deletedBackground") or fallback.git_deleted,
    }
  end,
}

local M = {}

function M.get_colors(get)
  return {
    surface = get("editor.background"),
    surface_low = get("sideBar.background"),
    surface_container = get("statusBar.background"),
    surface_high = get("sideBarSectionHeader.background"),
    surface_highest = get("terminal.inactiveSelectionBackground"),

    on_surface = get("editor.foreground"),
    on_surface_variant = get("statusBar.foreground"),
    outline = get("editorLineNumber.foreground"),
    outline_variant = get("editorWidget.border"),

    primary = get("editorLineNumber.activeForeground"),
    on_primary = get("button.foreground"),
    primary_container = get("editorSuggestWidget.selectedBackground"),
    on_primary_container = get("editorSuggestWidget.selectedForeground"),

    secondary = get("editorWarning.foreground"),
    secondary_container = get("statusBarItem.remoteBackground"),
    on_secondary_container = get("statusBarItem.remoteForeground"),

    tertiary = get("editorInfo.foreground"),
    tertiary_container = get("terminal.ansiBrightGreen"),

    error = get("editorError.foreground"),
    error_container = get("terminal.ansiBrightRed"),

    selection_bg = get("editor.selectionBackground"),
    word_highlight = get("editor.wordHighlightBackground"),
    word_highlight_strong = get("editor.wordHighlightStrongBackground"),

    git_added = get("editorGutter.addedBackground"),
    git_modified = get("editorGutter.modifiedBackground"),
    git_deleted = get("editorGutter.deletedBackground"),
  }
end

return M

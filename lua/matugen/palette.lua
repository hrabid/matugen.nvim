local fallback = require("matugen.fallback_palette")

local function is_valid_hex(color)
	if type(color) ~= "string" then
		return false
	end
	return color:match("^#%x%x%x(%x%x%x)?(%x%x)?$") ~= nil
end

return {
  --- @param get fun(key: string): string?
  --- @return table<string, string>?
  get_colors = function(get)
    local colors = {
      surface = get("editor.background") or fallback.surface,
      surface_low = get("sideBar.background") or fallback.surface_low,
      surface_container = get("statusBar.background") or fallback.surface_container,
      surface_high = get("sideBarSectionHeader.background") or fallback.surface_high,
      surface_highest = get("terminal.inactiveSelectionBackground") or fallback.surface_highest,

      on_surface = get("editor.foreground") or fallback.on_surface,
      on_surface_variant = get("statusBar.foreground") or fallback.on_surface_variant,
      outline = get("editorLineNumber.foreground") or fallback.outline,
      outline_variant = get("editorWidget.border") or fallback.outline_variant,

      primary = get("editorLineNumber.activeForeground") or fallback.primary,
      on_primary = get("button.foreground") or fallback.on_primary,
      primary_container = get("editorSuggestWidget.selectedBackground") or fallback.primary_container,
      on_primary_container = get("editorSuggestWidget.selectedForeground") or fallback.on_primary_container,

      secondary = get("editorWarning.foreground") or fallback.secondary,
      secondary_container = get("statusBarItem.remoteBackground") or fallback.secondary_container,
      on_secondary_container = get("statusBarItem.remoteForeground") or fallback.on_secondary_container,

      tertiary = get("editorInfo.foreground") or fallback.tertiary,
      tertiary_container = get("terminal.ansiBrightGreen") or fallback.tertiary_container,

      error = get("editorError.foreground") or fallback.error,
      error_container = get("terminal.ansiBrightRed") or fallback.error_container,

      selection_bg = get("editor.selectionBackground") or fallback.selection_bg,
      word_highlight = get("editor.wordHighlightBackground") or fallback.word_highlight,
      word_highlight_strong = get("editor.wordHighlightStrongBackground") or fallback.word_highlight_strong,

      git_added = get("editorGutter.addedBackground") or fallback.git_added,
      git_modified = get("editorGutter.modifiedBackground") or fallback.git_modified,
      git_deleted = get("editorGutter.deletedBackground") or fallback.git_deleted,
    }

    for _, value in pairs(colors) do
      if type(value) == "string" and value:sub(1, 1) == "#" and not is_valid_hex(value) then
        return nil
      end
    end

    return colors
  end,
}

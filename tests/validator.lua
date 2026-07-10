local jsonc = require("matugen.jsonc")

local M = {}

local function is_valid_hex(color)
	if type(color) ~= "string" then
		return false
	end
	return color:match("^#%x%x%x(%x%x%x)?(%x%x)?$") ~= nil
end

function M.validate(path)
	local result = { ok = true, errors = {}, warnings = {} }

	local expanded = vim.fn.expand(path)
	if vim.fn.filereadable(expanded) ~= 1 then
		result.ok = false
		table.insert(result.errors, "Palette file not found or not readable: " .. path)
		return result
	end

	local f = io.open(expanded, "r")
	if not f then
		result.ok = false
		table.insert(result.errors, "Could not open palette file: " .. path)
		return result
	end

	local content = f:read("*a")
	f:close()

	local cleaned = expanded:match("%.[Jj][Ss][Oo][Nn][Cc]$")
		and jsonc.strip_jsonc(content)
		or content

	local ok, parsed = pcall(vim.json.decode, cleaned)
	if not ok or not parsed then
		result.ok = false
		local ext = expanded:match("%.[Jj][Ss][Oo][Nn][Cc]$") and "JSONC" or "JSON"
		table.insert(result.errors, "Failed to decode " .. ext .. " from palette file: " .. path)
		return result
	end

	local colors = parsed["workbench.colorCustomizations"]
	if not colors then
		result.ok = false
		table.insert(result.errors, "Palette file does not contain 'workbench.colorCustomizations'")
		return result
	end

	if type(colors) ~= "table" then
		result.ok = false
		table.insert(result.errors, "'workbench.colorCustomizations' must be a table/object")
		return result
	end

	for key, value in pairs(colors) do
		if
			type(key) == "string"
			and type(value) == "string"
			and value:sub(1, 1) == "#"
			and not is_valid_hex(value)
		then
			result.ok = false
			table.insert(
				result.errors,
				string.format("Invalid color value '%s' for key '%s' (expected hex color)", value, key)
			)
		end
	end

	if result.ok then
		table.insert(result.warnings, "All color values in palette are valid")
	end

	return result
end

function M.is_valid_hex(color)
	return is_valid_hex(color)
end

--- Validate resolved color values (after hex() processing).
--- Only #-prefixed values are checked; non-hex values pass through.
--- @param colors table<string, string>
--- @return boolean
function M.validate_colors(colors)
	for _, value in pairs(colors) do
		if type(value) == "string" and value:sub(1, 1) == "#" and not is_valid_hex(value) then
			return false
		end
	end
	return true
end

return M

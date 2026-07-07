local M = {}

function M.strip_jsonc(raw)
	return raw
		:gsub("/%*.-%*/", "")
		:gsub("([%s,:{%[%]}])%s*//[^\n]*", "%1")
		:gsub("^%s*//[^\n]*", "")
end

function M.prepare_json(data, filepath)
	if filepath:match("%.[Jj][Ss][Oo][Nn][Cc]$") then
		return M.strip_jsonc(data)
	end
	return data
end

return M

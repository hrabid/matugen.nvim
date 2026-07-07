local M = {}

local health = vim.health or require("health")

function M.check()
	health.start("matugen report")

	-- 1. Neovim version check
	if vim.fn.has("nvim-0.10") == 1 then
		health.ok("Neovim version is 0.10+")
	else
		health.error("Neovim version is less than 0.10.0. This plugin requires Neovim 0.10+.")
	end

	-- 2. matugen CLI executable check
	if vim.fn.executable("matugen") == 1 then
		health.ok("matugen CLI is installed")
	else
		health.info("matugen CLI is not installed or not in system PATH. (Optional if you generate your palette elsewhere and sync it.)")
	end

	-- 3. Configuration & file presence check
	local matugen = require("matugen")
	local opts = matugen.opts
	if not opts then
		health.warn("matugen setup() has not been called yet. Using default configurations.", {
			"Call require('matugen').setup({ ... }) in your Neovim configuration.",
		})
		opts = { palette_path = "" }
	end

	local palette_path = opts.palette_path
	if not palette_path or palette_path == "" then
		health.warn("palette_path is not configured. Falling back to the built-in theme.", {
			"Set `palette_path` in your `opts` configuration.",
		})
	else
		local expanded_path = vim.fn.expand(palette_path)
		if vim.fn.filereadable(expanded_path) == 1 then
			health.ok("Palette file is readable: " .. palette_path)

			-- Try parsing the file
			local f = io.open(expanded_path, "r")
			if f then
				local content = f:read("*a")
				f:close()

				-- Strip JSONC comments only for .jsonc files
				local function strip_jsonc(raw)
					return raw
						:gsub("/%*.-%*/", "")
						:gsub("([%s,:{%[%]}])%s*//[^\n]*", "%1")
				end
				local cleaned = expanded_path:match("%.[Jj][Ss][Oo][Nn][Cc]$") and strip_jsonc(content) or content
				local ok, parsed = pcall(vim.json.decode, cleaned)
				if ok and parsed then
					if parsed["workbench.colorCustomizations"] then
						health.ok("Palette file parsed successfully and contains 'workbench.colorCustomizations'")
					else
						health.error("Palette file does not contain 'workbench.colorCustomizations' block.", {
							"Ensure your matugen template maps color customization options inside a 'workbench.colorCustomizations' block.",
						})
					end
				else
					health.error("Failed to decode JSON from palette file at: " .. palette_path, {
						"Check for syntax errors in " .. palette_path,
					})
				end
			else
				health.error("Could not open color file even though filereadable returned true: " .. palette_path)
			end
		else
			health.error("Palette file not found or not readable: " .. palette_path, {
				"Check that your matugen output path matches: " .. palette_path,
				"Verify your matugen config.toml contains the correct output template path.",
			})
		end
	end

	-- 4. Live Loaded Status
	local status = matugen._status or "Not loaded"
	local count = matugen._template_count or 0
	local path = matugen._palette_path or "No path"
	local last = matugen._last_reload and os.date("%Y-%m-%d %H:%M:%S", matugen._last_reload) or "No data"

	health.info(string.format("Loaded Palette: %s", path))
	health.info(string.format("Status: %s", status))
	health.info(string.format("Active Templates count: %d", count))
	health.info(string.format("Last Reload: %s", last))
end

return M

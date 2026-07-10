local M = {}

local health = vim.health or require("health")

local function load_palette_validator()
	local src = debug.getinfo(1, "S").source:sub(2)
	local root = src:match("^(.*/)lua/matugen/health%.lua$")
	if not root then
		return nil
	end
	local ok, mod = pcall(dofile, root .. "tests/validator.lua")
	if ok and type(mod.validate) == "function" then
		return mod
	end
	return nil
end

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

	-- 3. Palette file validation via tests/validator.lua
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
		local validator = load_palette_validator()
		if validator then
			local result = validator.validate(palette_path)
			for _, err in ipairs(result.errors) do
				health.error(err)
			end
			for _, warn in ipairs(result.warnings) do
				health.warn(warn)
			end
			if result.ok then
				health.ok("Palette file validated successfully")
			end
		else
			health.warn("Could not load tests/validator.lua — falling back to inline check")

			local expanded_path = vim.fn.expand(palette_path)
			if vim.fn.filereadable(expanded_path) == 1 then
				health.ok("Palette file is readable: " .. palette_path)
				local f = io.open(expanded_path, "r")
				if f then
					local content = f:read("*a")
					f:close()
					local cleaned = expanded_path:match("%.[Jj][Ss][Oo][Nn][Cc]$")
						and require("matugen.jsonc").strip_jsonc(content)
						or content
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

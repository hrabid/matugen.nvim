--- @type table<string, any>
local M = {}

--- @param msg string
--- @param lvl? integer
local function notify(msg, lvl)
	vim.notify("matugen: " .. msg, lvl or vim.log.levels.INFO)
end

--- @return fun(table, fun(string, table):nil)[]
local function _load_templates()
	if M._templates then
		return M._templates
	end

	local templates = {}
	-- Pin template loading to this plugin's own directory.
	-- Using debug.getinfo + loadfile instead of nvim_get_runtime_file + require
	-- prevents rogue plugins from injecting files via runtimepath.
	local _self = debug.getinfo(1, "S").source:sub(2) -- strip leading "@"
	local _plugin_lua_dir = _self:match("^(.*)/init%.lua$")
	local _templates_dir = _plugin_lua_dir .. "/templates"
	local _real_tpl_dir = vim.fn.resolve(_templates_dir)

	for _, file in ipairs(vim.fn.glob(_templates_dir .. "/**/*.lua", false, true)) do
		-- Guard: only load files that are strictly inside our templates directory
		local real_file = vim.fn.resolve(file)
		if real_file:sub(1, #_real_tpl_dir + 1) == _real_tpl_dir .. "/" then
			local chunk, err = loadfile(real_file)
			if chunk then
				local ok_chunk, res = pcall(chunk)
				if ok_chunk and type(res) == "function" then
					table.insert(templates, res)
				end
			else
				notify("Failed to load template " .. real_file .. ": " .. tostring(err), vim.log.levels.WARN)
			end
		end
	end

	M._templates = templates
	return templates
end

function M.reload_templates()
	M._templates = nil
end

-- Apply palette colors and highlight groups. Always called from the
-- main thread (either directly or via vim.schedule).
-- on_done: optional function called after highlights are applied.
--- @param v string
--- @return string?
local function hex(v)
	if not v then
		return nil
	end
	if v:sub(1, 1) ~= "#" then
		return v
	end
	local len = #v
	if len == 9 then
		return v:sub(1, 7)
	elseif len == 4 then
		local r, g, b = v:sub(2, 2), v:sub(3, 3), v:sub(4, 4)
		return "#" .. r .. r .. g .. g .. b .. b
	end
	return v
end

local _validator

local function _load_validator()
	if _validator then
		return _validator
	end
	local src = debug.getinfo(1, "S").source:sub(2)
	local root = src:match("^(.*/)lua/matugen/init%.lua$")
	if not root then
		return nil
	end
	local ok, mod = pcall(dofile, root .. "tests/validator.lua")
	if ok and type(mod.validate_colors) == "function" then
		_validator = mod
		return mod
	end
	return nil
end

local function _apply_highlights(w, path, on_done)
	local templates = _load_templates()
	local nvim_set_hl = vim.api.nvim_set_hl
	local hl = function(g, o)
		nvim_set_hl(0, g, o)
	end

	local palette = require("matugen.palette")
	local fallback_palette = require("matugen.fallback_palette")
	local c = palette.get_colors(function(k)
		return hex(w[k])
	end)

	if not c then
		return notify("palette not found", 3)
	end

	for k, v in pairs(fallback_palette) do
		if c[k] == nil then
			c[k] = v
		end
	end

	local validator = _load_validator()
	if validator and not validator.validate_colors(c) then
		notify("palette contains invalid color values, using fallback", vim.log.levels.WARN)
		c = {}
		for k, v in pairs(fallback_palette) do
			c[k] = v
		end
	end

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = "matugen"
	for _, t in ipairs(templates) do
		t(c, hl)
	end
	local now = os.time()
	M._last_reload = now
	M._template_count = #templates
	M._status = "Loaded successfully"
	M._palette_path = vim.fn.fnamemodify(path, ":~")
	vim.g.matugen_last_reload = now
	vim.g.matugen_template_count = M._template_count
	-- matugen_status intentionally not written to vim.g to avoid
	-- leaking the palette path to other plugins via global state
	if on_done then
		M._cached_w = w
		M._cached_path = path
		on_done()
		M._cached_w = nil
		M._cached_path = nil
	end
end

local jsonc = require("matugen.jsonc")

--- @param on_done? fun()
--- @param force_sync? boolean
function M.load(on_done, force_sync)
	if M._cached_w then
		local w = M._cached_w
		local path = M._cached_path
		M._cached_w = nil
		M._cached_path = nil
		_apply_highlights(w, path, on_done)
		return
	end

	local path = vim.fn.expand(M.opts.palette_path)

	if not path or path == "" then
		notify("No palette_path configured. Using fallback color scheme", vim.log.levels.WARN)
		if force_sync then
			_apply_highlights({}, path, on_done)
		else
			vim.schedule(function()
				_apply_highlights({}, path, on_done)
			end)
		end
		return
	elseif not path:match("%.[Jj][Ss][Oo][Nn][Cc]?$") then
		notify("palette_path must end in .json or .jsonc — refusing to open: " .. path, vim.log.levels.ERROR)
		return
	end

	if force_sync then
		local f = io.open(path, "r")
		if not f then
			notify(
				"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
			_apply_highlights({}, path, on_done)
			return
		end

		local raw = jsonc.prepare_json(f:read("*a"), path)
		f:close()

		local ok, parsed = pcall(vim.json.decode, raw)
		local w = {}
		if not ok or not parsed or not parsed["workbench.colorCustomizations"] then
			notify(
				"Failed to parse JSONC from " .. path .. "\nUsing fallback color scheme",
				vim.log.levels.WARN
			)
		else
			w = parsed["workbench.colorCustomizations"]
		end
		_apply_highlights(w, path, on_done)
		return
	end

	-- Non-blocking read via vim.uv so the main loop is not stalled.
	-- Highlight application is deferred to vim.schedule() which runs on
	-- the main thread after the async callbacks complete.
	local uv = vim.uv or vim.loop
	uv.fs_open(path, "r", 438, function(err_open, fd)
		if err_open or not fd then
			vim.schedule(function()
				notify(
					"Could not open color file at: " .. path .. "\nUsing fallback color scheme",
					vim.log.levels.WARN
				)
				_apply_highlights({}, path, on_done)
			end)
			return
		end

		uv.fs_fstat(fd, function(err_stat, stat)
			if err_stat or not stat then
				uv.fs_close(fd, function() end)
				vim.schedule(function()
					notify("Could not stat color file at: " .. path, vim.log.levels.WARN)
					_apply_highlights({}, path, on_done)
				end)
				return
			end

			uv.fs_read(fd, stat.size, 0, function(err_read, data)
				uv.fs_close(fd, function() end)
				vim.schedule(function()
					if err_read or not data then
						notify(
							"Could not read color file at: " .. path .. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
						_apply_highlights({}, path, on_done)
						return
					end

					-- Strip JSONC comments safely:
					--   /* ... */ block comments (non-greedy, across lines)
					--   // line comments only after structural JSON chars or
					--   pure whitespace, never inside string values.
					local raw = jsonc.prepare_json(data, path)
					local ok, parsed = pcall(vim.json.decode, raw)
					local w = {}
					if not ok or not parsed or not parsed["workbench.colorCustomizations"] then
						notify(
							"Failed to parse JSONC from " .. path .. "\nUsing fallback color scheme",
							vim.log.levels.WARN
						)
					else
						w = parsed["workbench.colorCustomizations"]
					end
					_apply_highlights(w, path, on_done)
				end)
			end)
		end)
	end)
end

--- @param opts? {palette_path?: string, load_theme?: boolean}
function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {
		palette_path = "",
		load_theme = true,
	}, opts or {})
	if M.opts.load_theme then
		M.load_theme(true) -- Force synchronous load at startup
	else
		notify("load_theme disabled; theme not loaded", vim.log.levels.WARN)
	end
end

--- @param force_sync? boolean
function M.load_theme(force_sync)
	if force_sync == nil then
		force_sync = true
	end
	-- Pass vim.cmd.colorscheme as on_done so it runs after highlights
	-- are applied by the _apply_highlights callback.
	M.load(function()
		vim.cmd.colorscheme("matugen")
	end, force_sync)
end

return M

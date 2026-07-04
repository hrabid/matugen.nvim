local M = {}

-- opts will be provided via setup(opts)

local function notify(msg, lvl)
	vim.notify("matugen: " .. msg, lvl or vim.log.levels.INFO)
end

function M.load()
	local path = vim.fn.expand(M.opts.jsonc_path)
	local w = {}

	if not path or path == "" then
		notify("No JSONC path configured. Using fallback color scheme", vim.log.levels.WARN)
	elseif not path:match("%.[Jj][Ss][Oo][Nn][Cc]?$") then
		notify("jsonc_path must end in .json or .jsonc — refusing to open: " .. path, vim.log.levels.ERROR)
	else
		local f = io.open(path, "r")
		if not f then
			notify("Could not open color file at: " .. path .. "\nUsing fallback color scheme", vim.log.levels.WARN)
		else
			local raw = f:read("*a"):gsub("/%*.-%*/", ""):gsub("([^:])//[^\n]*", "%1")
			f:close()

			local ok, data = pcall(vim.json.decode, raw)
			if not ok or not data or not data["workbench.colorCustomizations"] then
				notify("Failed to parse JSONC from " .. path .. "\nUsing fallback color scheme", vim.log.levels.WARN)
			else
				w = data["workbench.colorCustomizations"]
			end
		end
	end

	local templates, hl = {}, function(g, o)
		vim.api.nvim_set_hl(0, g, o)
	end

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

	local function hex(v)
		return v and (#v == 9 and v:sub(1, 7) or v)
	end
	local palette = require("matugen.palette")
	local c = palette.get_colors(function(k)
		return hex(w[k])
	end)

	if not c then
		return notify("palette not found", 3)
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
end

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", {
		jsonc_path = "",
		load_theme = true,
	}, opts or {})
	if M.opts.load_theme then
		M.load_theme()
	else
		notify("load_theme disabled; theme not loaded", vim.log.levels.WARN)
	end
end

function M.load_theme()
	M.load()
	vim.cmd.colorscheme("matugen")
end

return M

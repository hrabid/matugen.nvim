local M = {
  opts = {load_theme = true},
}

local function notify(msg, lvl)
  vim.notify("matugen: " .. msg, lvl or vim.log.levels.INFO)
end

function M.load()
  local path = M.opts.jsonc_path
  local w = {}

  if not path then
    notify("No JSONC path configured. Using fallback color scheme", vim.log.levels.WARN)
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

  local templates, hl = {}, function(g, o) vim.api.nvim_set_hl(0, g, o) end

  -- Use namespaced template path
  for _, file in ipairs(vim.api.nvim_get_runtime_file("lua/matugen/templates/**/*.lua", true)) do
    local mod = file:match("lua/(matugen/templates/.*)%.lua$"):gsub("/", ".")
    package.loaded[mod] = nil
    local res = require(mod)
    if type(res) == "function" then
      table.insert(templates, res)
    end
  end

  local function hex(v) return v and (#v == 9 and v:sub(1, 7) or v) end
  local palette = require("matugen.palette")
  local c = palette.get_colors(function(k) return hex(w[k]) end)

  if not c then return notify("palette not found", 3) end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "matugen"
  for _, t in ipairs(templates) do t(c, hl) end
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
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

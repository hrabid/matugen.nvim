local M = {
  opts = {},
}

local function notify(msg, lvl)
  vim.notify("matugen: " .. msg, lvl or vim.log.levels.INFO)
end

function M.load()
  local path = M.opts.jsonc_path
  local f = io.open(path, "r")
  if not f then
    return notify("Could not open color file at: " .. path .. ". Check that the file exists.", 3)
  end
  local raw = f:read("*a"):gsub("/%*.-%*/", ""):gsub("([^:])//[^\n]*", "%1")
  f:close()

  local ok, data = pcall(vim.json.decode, raw)
  local w = ok and data and data["workbench.colorCustomizations"]
  if not w then return notify("failed to parse JSONC from " .. path, 3) end

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
  c = palette.get_colors(function(k) return hex(w[k]) end)

  if not c then return notify("palette not found", 3) end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "matugen"
  for _, t in ipairs(templates) do t(c, hl) end
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

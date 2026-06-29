local matugen = require("matugen")

vim.api.nvim_create_user_command("MatugenReload", function()
  matugen.load()
  vim.notify("matugen: theme reloaded")
end, {})

local signal = (vim.uv or vim.loop).new_signal()
signal:start("sigusr1", vim.schedule_wrap(function()
  matugen.load()
  vim.notify("matugen: theme reloaded")
end))
vim.api.nvim_create_user_command("MatugenStatus", function()
  local matugen_mod = require("matugen")
  local path = vim.fn.expand(matugen_mod.opts.jsonc_path or "~/.config/matugen/themes/nvim-colors.jsonc")
  local status = vim.g.matugen_status or "Not loaded"
  local count = vim.g.matugen_template_count or 0
  local last = vim.g.matugen_last_reload and os.date("%H:%M:%S", vim.g.matugen_last_reload) or "Never"
  local msg = string.format("Palette Path: %s\nStatus: %s (%d templates active)\nLast Reload: %s", path, status, count, last)
  vim.notify(msg, vim.log.levels.INFO)
end, {})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lazy", "mason", "lspinfo", "null-ls-info", "checkhealth" },
  callback = function() vim.wo.winblend = 0 end,
})

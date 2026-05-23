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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lazy", "mason", "lspinfo", "null-ls-info", "checkhealth" },
  callback = function() vim.wo.winblend = 10 end,
})

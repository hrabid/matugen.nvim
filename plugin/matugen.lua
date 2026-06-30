local matugen = require("matugen")

vim.api.nvim_create_user_command("MatugenReload", function()
	matugen.load()
	vim.notify("matugen: theme reloaded")
end, {})

local signal = (vim.uv or vim.loop).new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		matugen.load()
		vim.notify("matugen: theme reloaded")
	end)
)

vim.api.nvim_create_user_command("MatugenStatus", function()
	local matugen_mod = require("matugen")
	-- Show status info
	local path = matugen_mod._palette_path
	local status = matugen_mod._status or "Not loaded"
	local count = matugen_mod._template_count or 0
	local last = matugen_mod._last_reload and os.date("%H:%M:%S", matugen_mod._last_reload) or "No data"
	local msg =
		string.format("Palette Path: %s\nStatus: %s (%d templates active)\nLast Reload: %s", path, status, count, last)
	vim.notify(msg, vim.log.levels.INFO)
end, {})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lazy", "mason", "lspinfo", "null-ls-info", "checkhealth" },
	callback = function()
		vim.wo.winblend = 0
	end,
})

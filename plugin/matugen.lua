local matugen = require("matugen")

vim.api.nvim_create_user_command("MatugenReload", function()
	matugen.reload_templates()
	matugen.load_theme(true)
	vim.notify("matugen: theme and templates reloaded")
end, { desc = "Reload templates from disk and reapply the theme" })

local _last_signal_ns = 0
local _debounce_ns = 300 * 1e6 -- 300 ms in nanoseconds

local signal = (vim.uv or vim.loop).new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		local now = vim.uv.hrtime()
		if now - _last_signal_ns < _debounce_ns then
			return
		end
		_last_signal_ns = now
		matugen.load_theme(false)
		vim.notify("matugen: theme reloaded")
	end)
)


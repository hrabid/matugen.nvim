local matugen = require("matugen")

vim.api.nvim_create_user_command("MatugenReload", function()
	matugen.reload_templates()
	matugen.load_theme(true)
	vim.notify("matugen: theme and templates reloaded")
end, { desc = "Reload templates from disk and reapply the theme" })

local _debounce_timer = nil
local _debounce_ms = 100

local signal = (vim.uv or vim.loop).new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		if _debounce_timer then
			_debounce_timer:stop()
			_debounce_timer:close()
		end
		_debounce_timer = vim.uv.new_timer()
		_debounce_timer:start(_debounce_ms, 0, vim.schedule_wrap(function()
			if _debounce_timer then
				_debounce_timer:stop()
				_debounce_timer:close()
				_debounce_timer = nil
			end
			matugen.load_theme(false)
		end))
	end)
)


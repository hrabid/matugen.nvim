test:
	nvim --headless --clean -u tests/minimal_init.lua \
		--cmd "set rtp+=~/.local/share/nvim/site/pack/vendor/start/plenary.nvim" \
		-c "PlenaryBustedDirectory tests/"

check-syntax:
	nvim --headless --clean -l scripts/check_syntax.lua

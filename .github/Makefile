test:
	nvim --headless --clean \
		--cmd "set rtp+=~/.local/share/nvim/site/pack/vendor/start/plenary.nvim" \
		-u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/ {minimal_init='tests/minimal_init.lua'}"

check-syntax:
	nvim --headless --clean -l .github/scripts/check_syntax.lua

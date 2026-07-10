test:
	nvim --headless --clean -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {keep_going = false}"

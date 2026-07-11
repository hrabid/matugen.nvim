local files = vim.fn.glob("**/*.lua", false, true)
local has_errors = false

for _, file in ipairs(files) do
  if not file:match("%.git/") then
    local ok, err = loadfile(file)
    if not ok then
      print("SYNTAX ERROR: " .. file)
      print(err)
      has_errors = true
    end
  end
end

if has_errors then
  vim.cmd("cquit!")
else
  print("All Lua files OK")
  vim.cmd("q!")
end

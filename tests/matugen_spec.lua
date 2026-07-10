local matugen = require("matugen")

describe("matugen.nvim", function()
  it("can be initialized with setup options", function()
    matugen.setup({
      palette_path = "~/.config/matugen/themes/nvim-colors.json",
      load_theme = false,
    })
    assert.is_not_nil(matugen)
  end)

  it("gracefully handles missing palette files", function()
    matugen.setup({ palette_path = "/this/path/does/not/exist.json" })
    local success, _ = pcall(function()
      matugen.load(nil, true)
    end)
    assert.is_true(success)
  end)
end)

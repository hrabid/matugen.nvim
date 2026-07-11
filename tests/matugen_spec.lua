local matugen = require("matugen")

local test_palette_path = _G.test_palette_path

describe("matugen module", function()
  it("exports expected public API", function()
    assert.is_function(matugen.setup)
    assert.is_function(matugen.load)
    assert.is_function(matugen.load_theme)
    assert.is_function(matugen.reload_templates)
  end)

  describe("setup", function()
    it("applies options correctly with load_theme = false", function()
      matugen.setup({
        palette_path = test_palette_path,
        load_theme = false,
      })
      assert.are.same(test_palette_path, matugen.opts.palette_path)
      assert.is_false(matugen.opts.load_theme)
    end)

    it("applies options correctly with custom palette_path", function()
      matugen.setup({
        palette_path = "/custom/path.json",
        load_theme = false,
      })
      assert.are.same("/custom/path.json", matugen.opts.palette_path)
      assert.is_false(matugen.opts.load_theme)
    end)

    it("applies default options when called with no args", function()
      matugen.setup()
      assert.are.same("", matugen.opts.palette_path)
      assert.is_true(matugen.opts.load_theme)
    end)
  end)

  describe("load (sync)", function()
    before_each(function()
      matugen.setup({
        palette_path = test_palette_path,
        load_theme = false,
      })
    end)

    it("loads palette from valid file", function()
      matugen.load(nil, true)
      assert.are.same("Loaded successfully", matugen._status)
      assert.is_not_nil(matugen._last_reload)
      assert.is_true(matugen._template_count > 0)
      assert.is_not_nil(matugen._palette_path)
      assert.is_true(matugen._palette_path:match("nvim%-colors%.json$") ~= nil)
    end)

    it("handles missing palette file gracefully", function()
      matugen.setup({
        palette_path = "/nonexistent/path.json",
        load_theme = false,
      })
      matugen.load(nil, true)
      assert.are.same("Loaded successfully", matugen._status)
    end)

    it("handles empty palette_path gracefully", function()
      matugen.setup({
        palette_path = "",
        load_theme = false,
      })
      matugen.load(nil, true)
      assert.are.same("Loaded successfully", matugen._status)
    end)

    it("rejects non-json palette_path without crashing", function()
      matugen.setup({
        palette_path = "/some/path.txt",
        load_theme = false,
      })
      matugen.load(nil, true)
    end)

    it("triggers on_done callback", function()
      local called = false
      matugen.load(function()
        called = true
      end, true)
      assert.is_true(called)
    end)
  end)

  describe("reload_templates", function()
    it("clears cached templates", function()
      matugen._templates = { "cached" }
      matugen.reload_templates()
      assert.is_nil(matugen._templates)
    end)
  end)
end)

local validator = require("matugen.validator")

local function test_palette_path()
  return vim.fn.getcwd() .. "/.github/nvim-colors.json"
end

describe("validator", function()
  describe("is_valid_hex", function()
    it("accepts 6-char hex colors", function()
      assert.is_true(validator.is_valid_hex("#aac7ff"))
      assert.is_true(validator.is_valid_hex("#111318"))
      assert.is_true(validator.is_valid_hex("#FFB4AB"))
    end)

    it("accepts 8-char hex colors (with alpha)", function()
      assert.is_true(validator.is_valid_hex("#aac7ff33"))
      assert.is_true(validator.is_valid_hex("#bec6dc33"))
    end)

    it("accepts 3-char shorthand hex colors", function()
      assert.is_true(validator.is_valid_hex("#fff"))
      assert.is_true(validator.is_valid_hex("#abc"))
    end)

    it("accepts 4-char shorthand hex colors (with alpha)", function()
      assert.is_true(validator.is_valid_hex("#ffff"))
      assert.is_true(validator.is_valid_hex("#abcf"))
    end)

    it("rejects hex without leading #", function()
      assert.is_false(validator.is_valid_hex("aac7ff"))
      assert.is_false(validator.is_valid_hex("111318"))
    end)

    it("rejects invalid hex characters", function()
      assert.is_false(validator.is_valid_hex("#GGGGGG"))
      assert.is_false(validator.is_valid_hex("#aac7ffx"))
    end)

    it("rejects wrong length hex strings", function()
      assert.is_false(validator.is_valid_hex("#aac7f"))
      assert.is_false(validator.is_valid_hex("#a"))
    end)

    it("rejects non-string inputs", function()
      assert.is_false(validator.is_valid_hex(123))
      assert.is_false(validator.is_valid_hex(nil))
      assert.is_false(validator.is_valid_hex({}))
    end)
  end)

  describe("validate_colors", function()
    it("returns true when all values are valid hex", function()
      local colors = {
        ["editor.background"] = "#111318",
        ["editor.foreground"] = "#e2e2e9",
      }
      assert.is_true(validator.validate_colors(colors))
    end)

    it("returns false when a value is not a valid hex", function()
      local colors = {
        ["editor.background"] = "#111318",
        ["editor.foreground"] = "not-a-color",
      }
      assert.is_false(validator.validate_colors(colors))
    end)

    it("returns false when a value is missing # prefix", function()
      local colors = {
        ["editor.background"] = "111318",
      }
      assert.is_false(validator.validate_colors(colors))
    end)

    it("returns true for empty table", function()
      assert.is_true(validator.validate_colors({}))
    end)
  end)

  describe("is_valid", function()
    it("returns true when all required keys have valid hex values", function()
      local colors = {}
      for _, key in ipairs(validator.required_keys) do
        colors[key] = "#aac7ff"
      end
      assert.is_true(validator.is_valid(colors))
    end)

    it("returns false when a required key is missing", function()
      assert.is_false(validator.is_valid({ ["editor.background"] = "#aac7ff" }))
    end)

    it("returns false for empty table", function()
      assert.is_false(validator.is_valid({}))
    end)

    it("returns false for non-table input", function()
      assert.is_false(validator.is_valid(nil))
      assert.is_false(validator.is_valid("string"))
      assert.is_false(validator.is_valid(42))
    end)

    it("returns false when a value is invalid hex", function()
      local colors = {}
      for _, key in ipairs(validator.required_keys) do
        colors[key] = "#aac7ff"
      end
      colors["editor.background"] = "bad-color"
      assert.is_false(validator.is_valid(colors))
    end)
  end)

  describe("validate", function()
    it("passes on the test palette file", function()
      local result = validator.validate(test_palette_path())
      assert.is_true(result.ok)
      assert.are.same(0, #result.errors)
    end)

    it("fails on a missing file", function()
      local result = validator.validate("/nonexistent/file.json")
      assert.is_false(result.ok)
      assert.is_true(#result.errors > 0)
    end)

    local function write_temp(content)
      local tmp = "/tmp/matugen_test_" .. vim.fn.getpid() .. ".json"
      local f = assert(io.open(tmp, "w"))
      f:write(content)
      f:close()
      return tmp
    end

    it("fails on a file without workbench.colorCustomizations", function()
      local tmp = write_temp('{"some": "data"}')
      local result = validator.validate(tmp)
      assert.is_false(result.ok)
      os.remove(tmp)
    end)

    it("fails on invalid JSON", function()
      local tmp = write_temp("{invalid json}")
      local result = validator.validate(tmp)
      assert.is_false(result.ok)
      os.remove(tmp)
    end)
  end)
end)

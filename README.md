# matugen.nvim

`matugen.nvim` is a Material You colorscheme for Neovim built around a dedicated template system. It maps your matugen generated colors directly to Neovim highlight groups through a semantic palette without color recomputation

---

## Demo

## [![matugen.nvim demo](https://img.youtube.com/vi/-O9JbfbJub0/maxresdefault.jpg)](https://youtu.be/-O9JbfbJub0)

---

## Requirements

- Neovim 0.10+
- [matugen](https://github.com/InioX/matugen) installed and configured

---

## Setup

**1. Copy the template**

Copy [nvim-colors.jsonc](nvim-colors.jsonc) to your matugen templates folder

**2. Add to your `config.toml`**

```toml
[templates.neovim]
input_path = "~/.config/matugen/templates/nvim-colors.jsonc"
output_path = "~/.config/matugen/themes/nvim-colors.jsonc"
post_hook = "pkill -SIGUSR1 nvim"
```

**3. Install via `lazy.nvim`**

```lua
return {
  {
    "Senal-D-A-Gunaratna/matugen.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      jsonc_path = vim.fn.expand("~/.config/matugen/themes/nvim-colors.jsonc"),
    },
    config = function(_, opts)
      require("matugen").setup(opts)
      vim.cmd.colorscheme("matugen")
    end,
  },
}
```

> **Note:** If the palette file fails to load, the plugin falls back to a built-in dark theme and notifies you

**4. Hyprland opacity** *(optional but recommended)*

Without blur and opacity, transparency won't look right:

```conf
windowrule = match:class kitty, match:title nvim, opacity 0.7 0.8
```

---

## Live Reload

The `post_hook` in your `config.toml` handles reloading automatically on each `matugen` run. To trigger it manually:

```bash
pkill -SIGUSR1 nvim
```

Or from inside Neovim:

```vim
:MatugenReload
```

---

## VS Code Parity

Using [matugen-editors](https://github.com/Senal-D-A-Gunaratna/matugen-editors)? Point the plugin at your existing `code-colors.jsonc` instead — as long as the structure matches, both editors theme from the same palette simultaneously

---

## Customization

All highlight groups derive from a single semantic palette in `lua/matugen/palette.lua`. Adding support for a new plugin or UI component stays consistent by design

To extend it, see [Creating Custom Templates](doc/TEMPLATES.md)

---

## Contributing

Contributions are more than welcome! If you want to add support for another plugin or fix a bug, feel free to open a Pull Request. Let's make this colorscheme even better together!

---

## License

MIT
# dsa_io.nvim

A simple Neovim plugin to manage input/output splits for competitive programming in C++.

## Keybinds

| Keybind     | Action |
|-------------|--------|
| `<leader>io` | Open input/output splits |
| `<leader>rr`  | Compile and run current C++ file using `gpp`-style flags |

## Installation

```lua
{
    dir = "~/Projects/dsa_io.nvim",
    lazy = false,
    config = function()
        require("dsa_io").setup()
    end,
}

-- Catppuccin Macchiato palette.
-- Hyprland color strings use "rgba(RRGGBBAA)". The original macchiato.conf
-- expressed these as 0xAARRGGBB integers; alpha was 0xff everywhere, so
-- these are RGB with ff appended.

local M = {}

M.rosewater = "rgba(f4dbd6ff)"
M.flamingo  = "rgba(f0c6c6ff)"
M.pink      = "rgba(f5bde6ff)"
M.mauve     = "rgba(c6a0f6ff)"
M.red       = "rgba(ed8796ff)"
M.maroon    = "rgba(ee99a0ff)"
M.peach     = "rgba(f5a97fff)"
M.yellow    = "rgba(eed49fff)"
M.green     = "rgba(a6da95ff)"
M.teal      = "rgba(8bd5caff)"
M.sky       = "rgba(91d7e3ff)"
M.sapphire  = "rgba(7dc4e4ff)"
M.blue      = "rgba(8aadf4ff)"
M.lavender  = "rgba(b7bdf8ff)"

M.text     = "rgba(cad3f5ff)"
M.subtext1 = "rgba(b8c0e0ff)"
M.subtext0 = "rgba(a5adcbff)"

M.overlay2 = "rgba(939ab7ff)"
M.overlay1 = "rgba(8087a2ff)"
M.overlay0 = "rgba(6e738dff)"

M.surface2 = "rgba(5b6078ff)"
M.surface1 = "rgba(494d64ff)"
M.surface0 = "rgba(363a4fff)"

M.base   = "rgba(24273aff)"
M.mantle = "rgba(1e2030ff)"
M.crust  = "rgba(181926ff)"

return M

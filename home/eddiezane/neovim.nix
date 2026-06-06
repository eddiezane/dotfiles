# Neovim — your existing ~/.config/nvim (AstroNvim) keeps working as-is.
#
# We intentionally do NOT use `programs.neovim.enable` because home-manager
# writes its own init.lua (with provider toggles and stylix theming) whenever
# that option is on, which collides with Lazy.nvim's bootstrap. Install the
# binary directly and stay out of ~/.config/nvim.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    # Tools nvim plugins (AstroNvim/Lazy.nvim) commonly shell out to.
    tree-sitter
    nodejs
    python3
    luajitPackages.luarocks
    # ripgrep, fd, fzf -> packages.nix (general CLI tools)
    # lazygit -> git.nix (git-adjacent)
  ];

  # EDITOR + SYSTEMD_EDITOR are set in home/eddiezane/default.nix.
  # vi/vim shell aliases are set in home/eddiezane/shell.nix.
}

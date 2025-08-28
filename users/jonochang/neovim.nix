{ pkgs, ... }:

let
  custom-plugins = pkgs.vimPlugins // pkgs.callPackage ./copilot.nix {};
in {
  home.packages = with pkgs; [
    # Basic utilities
    # nodejs
  ];

  programs.neovim = {
    enable = true;
    extraLuaConfig = builtins.readFile ./init.lua;
    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      telescope-nvim
      plenary-nvim
      kanagawa-nvim
      (nvim-treesitter.withPlugins (
        p: with p; [
          c
          cpp
          go
          javascript
          just
          nix
          python
          ruby
          sql
          terraform
          typescript
          zig
        ]
      ))
      vim-fugitive
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-nvim-lsp
      cmp-nvim-lua
      nerdtree
    ];
  };
}

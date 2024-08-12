# Entry point for nix-shell.
let
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  gems = nixpkgs.pkgs.bundlerEnv {
    name = "jekyll-gems";
    gemdir = ./.;
  };
in

mkShell { packages = [ gems gems.wrappedRuby ]; }

with import <nixpkgs> {};

let jekix-env = bundlerEnv rec {
  name = "jekix-${version}";
  version = "1.0.0";

  inherit ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};

in
stdenv.mkDerivation {
  name = "jekix-env";
  buildInputs = [ jekyll bundler ];
  shellHook = ''

  '';
}
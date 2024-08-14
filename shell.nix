# Virtual environment for Jekyll blog development
#
# Ensure to run
# - `bundle lock` => creates Gemfile.lock
# - `bundix` => creates `gemset.nix`
#


with import <nixpkgs> { };

let
  jekix-env = bundlerEnv rec {
    name = "jekix";

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
    bundle install
    bundle exec jekyll serve
    echo && echo "Run 'bundle exec jekyll serve' to start the server again!"
  '';
}

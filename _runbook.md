# Runbook for development environment

Simple runbook for setup and use of bundler + jekyll within a Nix Shell.

## Initial Ruby env setup

### Create a lock file `Gemfile.lock`

```bash
bundle package --no-install
```

or

```bash
bundle lock
```

### Create a `gemset.nix` file

```bash
bundix
```

### Create a `default.nix` file

```nix
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
  buildInputs = [ jekyll bundler ruby gcc ];
  shellHook = ''

  '';
}
```


### Enter the Nix shell

```bash
nix-shell
```


### Install bundle packages

```bash
bundle install
```


### Start Jekyll local instance
```bash
bundle exec jekyll serve
```


<br>

## Running already setup env


### Enter the Nix shell

```bash
nix-shell
```


### Start bundle

```bash
bundle exec jekyll serve
```

<br>

## Adding and removing packages

### Edit the local `Gemfile`

Add or remove the packages you desire to this file


### Generate a new `Gemfile.lock` file

```bash
bundle lock
```


### Generate a new `gemset.nix` file

```bash
bundix
```


### Enter Nix-shell and run `bundle install`

```bash
nix-shell
```

```bash
bundle-install
```

---
layout: post
title:  "Intro to Nixos for WSL"
date:   2024-08-12 20:00:00 -0700
categories: Nixos
---

**Table of Contents**
- [Setting up base instance of Nixos](#setting-up-base-instance-of-nixos)
  - [Install WSL (if applicable)](#install-wsl-if-applicable)
  - [Download the Nixos Tarball](#download-the-nixos-tarball)
  - [Import image into WSL](#import-image-into-wsl)
- [Nixos Flakes -  The Basics](#nixos-flakes----the-basics)
- [Using `flake.nix`](#using-flakenix)
- [Using local .nix files](#using-local-nix-files)

If you are like me, you have multiple machines that you switch between to work on projects throughout the day. WSL is good at being portable as we saw in this post on [Portable Workspaces with WSLv2]({% link _posts/2024-08-09-setup_a_portable_workspace_with_wsl2.markdown %}). 

However, sometimes we need a bit more portability. Nixos can give use a higher degree of flexibility when it comes to package management; especially across multiple distributed WSL instances.


## Setting up base instance of Nixos

> *Official Nixos documentation for this section can be found [here](https://nix-community.github.io/NixOS-WSL/).*

### Install WSL (if applicable)

{% highlight powershell %}
wsl --install --no-distribution
{% endhighlight %}

### Download the Nixos Tarball
Link to the Tarball => [nixos-wsl.tar.gz](https://github.com/nix-community/NixOS-WSL/releases)

### Import image into WSL

{% highlight powershell %}
wsl --import NixOS $env:USERPROFILE\wsl-images\nixos\ nixos-wsl.tar.gz
{% endhighlight %}

Once done, connect to the instance.

{% highlight powershell %}
wsl -d NixOs
{% endhighlight %}


## Nixos Flakes -  The Basics

Now that you are in the instance, you will likely want some packages, maybe customize the user or hostname. To do this, we can use Nixos Flakes. These are portable configurations that can be applied to most installs of Nixos; WSL or not. Using flakes consists of two major files:

- `flake.nix`
  - Entry point for configuration
- `<hostname>.nix`
  - Any local .nix file(s) for your nix config 

These files are used to compile a system configuration. Nix will then us this configuration to make changes to the existing build of the system. This includes adding/removing packages, changing host names, adding users, configuring 3rd party software packages, and much more. The options are limitless.

## Using `flake.nix`

The `flake.nix` file will act like an entry point for our Nixos builds. This file defines the repos and libraries that will be used by the build. Some examples would be `nixpkgs` or `nixos-wsl`. It also contains all the possible hosts that can be built from this config, and their respective packages and configurations.

In Nixos everything is a function. You'll quickly notice that all of these config files are just lambda functions. Access to repos like `nixpkgs` allows us to access more functions. These functions could define software packages, system configurations, or even WSL configurations (wsl.conf).

Now, lets set a baseline `flake.nix` configuration for Nixos. In our WSL home directory, lets create a folder called **config**.
In this folder, lets create our `flake.nix` file.

```nix
{
  # These are the package dependency URLs.
  inputs = {
    # This is what your entire system is based on, it has every package and library function.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # The WSL specific modules.
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  # This will include modules that other flakes can use, or system configurations.
  outputs = { self, nixpkgs, nixos-wsl, ... }: {
    # This is for a system configuration(s)
    nixosConfigurations = {
      
      # Each of these blocks represents one system configuration.
      # `hostName = ... {config options}`
      nixdev = nixpkgs.lib.nixosSystem rec {
        # Desired kernel
        system = "x86_64-linux";
        # These are the modules, or configs to use.
        modules = [
          # This includes the options for the WSL specific settings.
          nixos-wsl.nixosModules.default

          # External host configuration.
          ./nixdev.nix
        ];
      };
    };
  };
}
```

Lets break down this code block.

```nix
# These are the package dependency URLs.
inputs = {
# This is what your entire system is based on, it has every package and library function.
nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

# The WSL specific modules.
nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
};
...
```

`inputs` represent the packages and sources that will be used in our configuration. The inputs block brings these sources into scope for use in the following code and external packages. However, we will need to further provide these packages to other scopes as we go into external files. This block defines the default Nixos package repo `nixpkgs` and an alternate repo for WSL specific configurations `nixos-wsl`.


```nix
...
# This will include modules that other flakes can use, or system configurations.
outputs = { self, nixpkgs, nixos-wsl, ... }: {
# This is for a system configuration(s)
nixosConfigurations = {
...
```

`outputs` represents the final configuration for the system. All configurations setup on this file, and the next few files, will be compiled into this object and used to generate our build. `nixosConfigurations` will define our host specific configurations. You can define multiple configurations here to allow for maximum reusability.


```nix
...

nixdev = nixpkgs.lib.nixosSystem rec {
    # Desired kernel
    system = "x86_64-linux";
    # These are the modules, or configs to use.
    modules = [
        # This includes the options for the WSL specific settings.
        nixos-wsl.nixosModules.default

        # External host configuration.
        ./nixdev.nix
    ];
};
...
```

`nixdev` represents our host config. This is a friendly name, and will only be used when we try and use the flakes during rebuild. `system` is the kernel we want for our host. Since we are not on ARM or Apple Silicon, we want this value to be `x86_64-linux`. `modules` represents the other .nix files we want to compile into our output. This can be a function call like `nixos-wsl.nixosModules.default` or a local file like `./nixdev.nix`.


## Using local .nix files



<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
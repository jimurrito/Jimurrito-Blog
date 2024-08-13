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
- [Using local .nix files (Flakes)](#using-local-nix-files-flakes)
  - [`<hostname>.nix`](#hostnamenix)
  - [`generic-wsl.nix`](#generic-wslnix)
- [Next steps](#next-steps)
  - [Helpful links](#helpful-links)


If you are like me, you have multiple machines that you switch between to work on projects throughout the day. WSL is good at being portable as we saw in this post on [Portable Workspaces with WSLv2]({% link _posts/2024-08-09-setup_a_portable_workspace_with_wsl2.markdown %}). 

However, sometimes we need a bit more portability. Nixos can give use a higher degree of flexibility when it comes to package management; especially across multiple distributed WSL instances.

*[Link to part two: Using Nixos for WSL]()*


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


## Using local .nix files (Flakes)

### `<hostname>.nix`

Now that we have our entry point and host specific config defined in `flake.nix`, we can define local .nix files that contain our modular configurations. These local .nix files are commonly referred to as flakes. While not required, I prefer to use a host specific .nix file, named `<hostname>.nix`. Using this file, I will define the other local .nix files that I want to be a part of this specific host.

Here is an example of a flake configurations for my host called `nixdev.nix`.

```nix
{ pkgs, lib, config, ... }: {
  # What version to run on, this just says to run on whatever release you imported from nixpkgs.
  system.stateVersion = config.system.nixos.release;

  # This lets the system use flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # (they are 'experimental' but everyone uses them, and they are great)

  # Imports local modules
  imports = [
    ./modules/generic-wsl.nix
  ];

  # Change this and the config name in the flake.nix file to change the hostname.
  networking.hostName = "nixdev";

}
```

Ill break this down into its components like I did for the `flake.nix` file.


```nix
{ pkgs, lib, config, ... }: {
...
```

This defines the modules we want in-scope for our flake.


```nix
...
system.stateVersion = config.system.nixos.release;
...
```

This defines the version of Nixos we want to install.


```nix
...
nix.settings.experimental-features = [ "nix-command" "flakes" ];
...
```

Allows the use of Flakes on the host.


```nix
...
imports = [
  ./modules/generic-wsl.nix
];
...
```

These are the other flakes we want to include in this flake. Note that other flakes can define the same, creating a dependency chain. When nixos compiles the desired image, it will sort through this chain and ensure everything is included safely. In this case, I'm importing another local flake called `generic-wsl.nix`.


```nix
...
networking.hostName = "nixdev";
...
```

This defines the hostname of the machine.

---

### `generic-wsl.nix`

In my configuration, I use `generic-wsl.nix` to setup all the general WSL configurations and include other flakes that install packages for more specific purposes.

```nix
{ pkgs, lib, config, ... }: {


  imports = [
    ./docker.nix
    ./packages.nix
    ./jekyll.nix
    ./azdev.nix
  ];

  # The WSL Specific settings from the 'nixos-wsl' module
  wsl = {
    enable = true;
    defaultUser = "james";
    docker-desktop.enable = false;
  };


  # user settings
  users.users.james = {
    # Says you can actually be the user, it is not a service only user.
    isNormalUser = true;
    # Puts you in the wheel group.
    extraGroups = [ "wheel" "docker" ];
  };


  environment = {

    # checks if rebuild is active on user logon
    shellInit = ''
      # prints rebuild.service's status if running ONLY
      state=$(systemctl is-active rebuild)
      [ "$state" == "active" ] && echo -e "Rebuild.Service (nixos-rebuild) \e[31m$state\e[0m"    
    '';

    # Command aliases
    shellAliases = {
      nixos-refresh = ''state=$(systemctl is-active rebuild); [ "$state" != "active" ] && sudo ${lib.getExe pkgs.nixos-rebuild} switch --flake git+ssh://git@github.com/jimurrito/nixos-config#${config.networking.hostName} --refresh'';
      nixos-status = ''state=$(systemctl is-active rebuild); color=$([ "$state" == "active" ] && echo "\e[31m" || echo "\e[32m"); echo -e "Rebuild.Service (nixos-rebuild) $color$state\e[0m"'';
    };
  };


  # Systemd rebuild service for on-boot rebuids of nixos from the repo
  systemd.services.rebuild = {
    script = "${lib.getExe pkgs.nixos-rebuild} switch --flake git+ssh://git@github.com/jimurrito/nixos-config#${config.networking.hostName} --refresh";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ git openssh ];
    restartIfChanged = false;
  };
}
```

There is a lot to go over here. For now, we will skip the configurations under `environment`. That will be covered in a follow-up post on using Nixos in WSL.


```nix
imports = [
  ./docker.nix
  ./packages.nix
  ./jekyll.nix
  ./azdev.nix
];
...
```

Just like in the `<hostname>.nix` file, these are the other local flakes we want to include when this flake is used. In this case, these are flakes that install packages for specific projects or tool chains.


```nix
...
wsl = {
  enable = true;
  defaultUser = "james";
  docker-desktop.enable = false;
};
...
```

This defines the same configurations we would use in a regular `wsl.conf` file.


```nix
...
users.users.james = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" ];
};
...
```

This defines our user, and the groups they should be apart of.

If we wanted to add or install some packages, we could add a line like this.

```nix
...
environment.systemPackages = with pkgs; [ jekyll bundler bundix ];
...
```

This would install the packages needed to develop Jekyll projects in nixos. If you are familiar with Jekyll, you'll notice the newcomer `bundix`. This is used to allow for building the `bundle` packages within a virtual Nixos shell. We will not be covering this tool in this post. However, I do plan on posting a follow-up to the post on [setting up Jekyll for local use]({% link _posts/2024-08-06-running-jekyll-locally.markdown %}).

With all of this set, we can now apply our configuration into our build of Nixos. Running this below command will use our local flakes to build our image live.

```bash
nixos-rebuild switch --flake ./flake.nix#hostname
```
> Note: `hostname` should be replaced with your desired host config we setup in the `flake.nix` file. For this demo, my host config is called `nixdev`.


```bash
nixos-rebuild switch --flake ./flake.nix#nixdev
```

Once done, thats it! If this operation was successful, we should have all the packages needed. Some changes like changing the hostname of a machine does require a reboot to propagate.


## Next steps

From here, you should be able to customize Nixos to your hearts content. In the next post, I will go over some more advanced configurations and QOL changes I added to my Nixos installs.


### Helpful links

- [Flake config function documents](https://noogle.dev/)
- [All Flake functions](https://teu5us.github.io/nix-lib.html)
- [Package explorer + Legacy repo lookup](https://www.nixhub.io/)


<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
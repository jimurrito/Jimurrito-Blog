---
layout: post
title:  "Improving the Nixos Experience"
date:   2024-08-19 14:00:00 -0700
categories: Nixos
---

**Table of Contents**

- [`nixos-rebuild` via git (using Github)](#nixos-rebuild-via-git-using-github)
  - [Directory structure for git](#directory-structure-for-git)
  - [Pull configuration via git (Public)](#pull-configuration-via-git-public)
  - [Pull configuration via git (Private)](#pull-configuration-via-git-private)
    - [Secure SSH Private key](#secure-ssh-private-key)
    - [Create config file `/root/.ssh/config`](#create-config-file-rootsshconfig)
    - [Run in a shell](#run-in-a-shell)
  - [Creating a shortcut (alias)](#creating-a-shortcut-alias)
- [Update Nixos on boot](#update-nixos-on-boot)
  - [Determine if service is running on shell creation.](#determine-if-service-is-running-on-shell-creation)
- [Summary](#summary)

This is a follow-up to my previous post on Nixos for WSL: *[Link to part one: Intro to Nixos for WSL]({% link _posts/2024-08-12-intro-to-nixos-for-wsl.markdown %})*. In this post, we will go over some quality of life changes I made to my WSL instance.


## `nixos-rebuild` via git (using Github)

Using the flakes files locally can be limiting if we want to mirror the configuration to multiple distributed machines. Using a system like git will allow us to keep one source of truth for our configuration.


### Directory structure for git

To ensure `nixos-rebuild` can find our `flake.nix` entry point, we want it to be on the root directory of the git repo. All other flakes can be stored in nested directories. Just ensure to use the path relative to the calling file.

Here is an example using my configuration.

```
https://github.com/username/repo.git#hostname
|
|-flake.nix
|-modules
    |-general-wsl.nix
    |-docker.nix
|-nixdev.nix
|-nixdev-tun.nix

```


### Pull configuration via git (Public)

We can utilize `nixos-rebuild` to pull our configuration directly from Github. We have a few methods that are determined by your use case. For all of these iterations, I will use the `--refresh` switch. This ensures nixos pulls from the github repo and not from cache.

``` bash
# HTTPS
sudo nixos-rebuild switch --flake https://github.com/<username>/<repo>#<hostname> --refresh

# SSH
sudo nixos-rebuild switch --flake git+ssh://github.com/<username>/<repo>#<hostname> --refresh
```


### Pull configuration via git (Private)

Due to the private access, I access the repo via git+ssh. For this to work properly, we need an SSH access key for the repo or your github account. 


#### Secure SSH Private key

Once we have this, we need to import it into `/root/.ssh` and set a configuration in a `config` file. Ensure to run `chmod 600 <sshkey>` as openssh will not work if the key permissions are too open.


#### Create config file `/root/.ssh/config`
```
Host github.com
  Hostname github.com
  IdentityFile "/path/to/private/key"
```


#### Run in a shell

``` bash
# SSH
sudo nixos-rebuild switch --flake git+ssh://github.com/<username>/<repo>#<hostname> --refresh
```


### Creating a shortcut (alias)

Using `environment.shellAliases` in a nix flake, we can setup a shortcut to update our configuration. Our shortcut will be `nixos-refresh`.

```nix
{ pkgs, lib, config, ...}: {
    environment.shellAliases = {
        nixos-refresh = ''
        sudo ${lib.getExe pkgs.nixos-rebuild} switch --flake git+ssh://github.com/<username>/<repo>#${config.networking.hostName} --refresh
        '';
    }
}
```

To keep this block flexible, we used the two functions within Nixos. 
- `${lib.getExe pkgs.nixos-rebuild}` represents the current path to nixos-rebuild's binary. Our shell may not have the proper paths to this binary at the time of rebuild.
- `${config.networking.hostName}` will input whatever value our hostname is, as defined within this configuration.

We will need to run our `nixos-rebuild ...` command as before, then this alias command will become available to us.


## Update Nixos on boot

Now that we know how to rebuild from remote on-demand, we should also rebuild on reboot incase it has been a while. For this, we will create a systemd service that triggers on boot. Our service will be called `rebuild` or `rebuild.service`.

```nix
{ pkgs, lib, config, ...}: {
  systemd.services.rebuild = {
    script = "${lib.getExe pkgs.nixos-rebuild} switch --flake git+ssh://github.com/<username>/<repo>#${config.networking.hostName} --refresh";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ git openssh ];
    restartIfChanged = false;
  };
}
```

Lets break this down:

- `systemd.services.<service-name>` is how we define the name of our service.
- `script` this is what will trigger on service activation. In this case, it is the same command snippet we used for `nixos-refresh`. The only difference is that we do not need to use `sudo` as a systemd service.
- `after` defines what services need to be initialized prior to this triggering.
- `wantedby` defines what services will await this service starting.
- `path` path variable that the service will have access to. In this case, we used `with pkgs; [ git openssh ];` as we need those two packages for this service to run.
- `restartIfChanged` determines if the script should be restarted on change.

Once this is set, we can run `nixos-refresh` or `nixos-rebuild ...` to create this service.


### Determine if service is running on shell creation.
If you are using the system immediately after boot, you may run into a race condition where the rebuild process has not finished yet. To aid in this, we will add a verbose output and alias to allow us to query the state of `rebuild.service`.


**shellAlias**

```nix
{ pkgs, lib, config, ...}: {
    shellAliases = {
      nixos-status = ''state=$(systemctl is-active rebuild); color=$([ "$state" == "active" ] && echo "\e[31m" || echo "\e[32m"); echo -e "Rebuild.Service (nixos-rebuild) $color$state\e[0m"'';
    };
}
```

This creates an alias for us `nixos-status` that queries the state of the systemd service. Here is another example of the code we are using for the alias.

```bash
state=$(systemctl is-active rebuild); 
color=$([ "$state" == "active" ] && echo "\e[31m" || echo "\e[32m")
echo -e "Rebuild.Service (nixos-rebuild) $color$state\e[0m"
```
The output for this will change color depending on the state.
- `Active` == Red
- `Inactive` == Green



**shellInit**

```nix
{ pkgs, lib, config, ...}: {
    shellInit = ''
      state=$(systemctl is-active rebuild)
      [ "$state" == "active" ] && echo -e "Rebuild.Service (nixos-rebuild) \e[31m$state\e[0m"    
    '';
}
```

This configuration will only display an output if the state is `Active`.

With this setup, we can BOTH proactively query the state via `nixos-status` and reactively be alerted of an ongoing rebuild via `environment.shellInit`.


## Summary

From here, you should be able to keep a unified and interchangeable configuration for Nixos. This can be applied to BOTH physical machines and WSL instances.


<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)

---
layout: post
title:  "Setup a Portable Workspace with WSLv2"
date:   2024-08-09 14:00:00 -0700
categories: WSL
---

**WSL**, or **<u>W</u>**indows **<u>S</u>**ubsystem for **<u>L</u>**inux is a great tool for development on Windows. Especially if you hate developing on Windows. This guide will briefly go over how to setup WSL on Windows, create a workspace, and then make the workspace portable for use on other machines.

**Table of Contents**
- [Install WSL](#install-wsl)
- [Install a Distro of you choice](#install-a-distro-of-you-choice)
- [Using WSL](#using-wsl)
  - [1. WSL CLI](#1-wsl-cli)
  - [2. Windows Terminal](#2-windows-terminal)
  - [(Optional) Make this distro default](#optional-make-this-distro-default)
- [Prepare for exporting](#prepare-for-exporting)
  - [Setting a persistent configuration with `wsl.conf`](#setting-a-persistent-configuration-with-wslconf)
- [Exporting the image](#exporting-the-image)
- [Importing the image](#importing-the-image)


## Install WSL
To install WSL on Windows 10 or 11, all we need to do is open a `cmd` or `powershell` window as Administrator.

```cmd
wsl --install
```

This will install WSL, and all of its dependant optional features like the Virtual Machine Platform. Once done, this will require a reboot to finalize. 

Running this will also install Ubuntu as the default image. To avoid that, we can either skip directly to the next step, or run this following command.

```cmd
wsl --install --no-distribution
```

## Install a Distro of you choice

As far as Linux distributions are concerned, there really is no wrong answer here. For this guide, I will be using the tried and true Debian.
If you skipped the last step, this will also install WSL.

```cmd
wsl --install Debian
```

**<u>It's really that easy!</u>**

Here is a list of common WSL images that you can use in-place of Debian.

- `NixOS`
- `Ubuntu`
- `kali-linux`
- `openSUSE-Leap-15.6`

The common distros can either be found by using this command in CMD or Powershell.

```cmd
wsl -l -o
# or
wsl --list --online
```

## Using WSL
To access your image, all you need to do is connect to it via one of these methods.

### 1. WSL CLI
We can use the CLI from CMD or Powershell for this.

```cmd
wsl -d debian
```
This will turn our current session into a tty session on our WSL instance.

### 2. Windows Terminal
Using Windows Terminal, we can natively open a tty session into any of our WSL instance.

- Select the downward arrow button next to the new tab `+` icon.
- When the drop down appears, select the icon that matches the name of the distro we installed.

Once done, this will create a new tab in Windows Terminal to connect to the WSL session.


### (Optional) Make this distro default
If you want this to be the distro that WSL uses as default, you can use the `-s` parameter and provide the name of the distro.

```cmd
wsl -s debian
```


## Prepare for exporting

Now that you have access to WSL, take some time to install all the packages you would want in your new image. Ensure to fully test any features or packages prior to performing the exporting process. A good test to perform once you have everything setup is to reboot the WSL instance. This way you can know that the configuration will withstand the exporting process.

**Disconnect all sessions**
```cmd
wsl --terminate <Distro>
```

**Shuts down the WSL instance**
```cmd
wsl --shutdown <Distro>
```

Once this is done, you just need to open a new session to the instance to start it up again. If everything is as expected, we can continue forward.

### Setting a persistent configuration with `wsl.conf`
Inside of our WSL instance, we need to create a new file called `wsl.conf` under `/etc`. 

```bash
sudo nano /etc/wsl.conf
```

In that file, we can provide a configuration like this:

```toml
# Automatically mount Windows drive when the distribution is launched
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true

# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c.
root = /

# DrvFs-specific options can be specified.
# options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true

# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
hostname = Devian
generateHosts = true
generateResolvConf = true

# Set whether WSL supports interop processes like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
enabled = false
appendWindowsPath = false

# Set the user when launching a distribution with WSL.
[user]
default = user

# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = service docker start
```

Once this is created, we will need to reboot the WSL instance to see the changes occur. This step is critical as without it, the exported image will use root as its default user, and change its host name to that of the new host. For this guide, my new image will be called 'Devian'.


## Exporting the image
Now that our image is setup, we can export it for portable use. To export it, we need to open a CMD or Powershell session. 

While not required, the `--vhd` option will increase our portability as it will avoid the need to install the image on import. Saving and running the `*.vhdx` WSL image from a USB 3.2 drive or network share would also be the more efficient then using built-in directory method of holding the image files.

```cmd
wsl --export <Distro> <Filename> --vhd
```

**Example**
```cmd
wsl --export Debian C:/path/to/devian.vhdx --vhd
```


## Importing the image

Once your image is moved and archived as needed, we can import it into your target machine. Run this to import our `*.vhdx` file from its currently location. Keep in mind this is where the disk will need to stay for the remainder of it's lifecycle. Make sure its somewhere good!

```cmd
wsl --import-in-place <NewDistro> <Filename>
```

**Example**
```cmd
wsl --import-in-place Devian C:/path/to/devian.vhdx
```

`--import-in-place` only works for `.vhdx` files. If you did not export as a `.vhdx` then you will need to use `--import`. If you did export as `.vhdx`, but you want WSL to install to another location, you can also use `--import`. When doing so, make sure to include `-vhd` as we will not be using a Tarball.

```cmd
wsl --import <NewDistro> <InstallDir> <Filename>
# or
wsl --import <NewDistro> <InstallDir> <Filename> -vhd
```

**Example**
```cmd
wsl --import Devian C:/path/for/install C:/path/to/devian.vhdx -vhd
```

This process will take a few moments. When done, we can check if it is properly registered in WSL.
Run this and see if you see the new distro name we provided on import.

```cmd
wsl --list
```

Once done, you'll likely want to set this as default like we did at the start.

```cmd
wsl -s <NewDistro>
```

**Example**
```cmd
wsl -s Devian
```

With that, we are done. WSL was installed, customized, exported, then imported. As you continue to use the image, you can follow the export process over and over again to create and save more iterations of your image.

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
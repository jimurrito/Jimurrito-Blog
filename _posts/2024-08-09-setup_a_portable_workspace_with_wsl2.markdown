---
layout: post
title:  "Setup a Portable Workspace with WSLv2"
date:   2024-08-09 14:00:00 -0700
categories: WSL
---

**WSL**, or **<u>W</u>**indows **<u>S</u>**ubsystem for **<u>L</u>**inux is a great tool for development on Windows. Especially if you hate developing on Windows. This guide will briefly go over how to setup WSL on Windows, create a workspace, and then make the workspace portal for use on other machines.

## Table of Contents
- [Install WSL](#install-wsl)
- [Install a Distro of you choice](#install-a-distro-of-you-choice)
- [Prepare for Exporting](#prepare-for-exporting)
- [Exporting an Image](#exporting-the-image)
- [Importing an Image](#importing-the-image)


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

All distros the common distros can either be 



## Prepare for exporting

## Exporting the image

## Importing the image



<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
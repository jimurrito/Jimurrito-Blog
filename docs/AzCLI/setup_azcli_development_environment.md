# Setup AzCLI development environment

###### *Published: 08/06/2024*

## Table of Contents
1. [Prerequisites](#prerequisites)
   1. [Optionals](#optional)



<br>

The Az CLI is great, and maybe you want to add to its development. Maybe you want to fix a bug. This guide will show you how to setup `AzDev` with Python.


## Prerequisites
- Python 3.6 - 3.8. <u>3.9+ is not supported as of writing this.</u>
- Pip
- Wheel (via Pip)


### Optional
- A `WSL` instance to develop from.
- [VSCode Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

> If you run a version of Debian, where apt no longer contains Python 3.8, please do the following.
> 1. `sudo apt update`
> 2. `sudo apt install software-properties-common`
> 3. `sudo apt update`
> 1. `sudo add-apt-repository ppa:deadsnakes/ppa`
> 2. `sudo apt update`
> 3. `sudo apt install python3.8`
> 


## Setup

For this deployment, I will be using `WSL` running Debian.



### Helpful Links
- https://github.com/Azure/azure-cli-dev-tools


---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](../profile.md)
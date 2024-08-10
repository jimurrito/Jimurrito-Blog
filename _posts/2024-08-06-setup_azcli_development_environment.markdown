---
layout: post
title:  "Setup AzCLI Development Environment using AzDev"
date:   2024-08-06 17:00:00 -0700
categories: azure
---

The Az CLI is great, and maybe you want to add to its development. Maybe you want to fix a bug. This guide will show you how to setup `AzDev` with Python 3.

**Table of Contents**
- [Prerequisites](#prerequisites)
  - [(Optional) Install VSCode extension for WSL](#optional-install-vscode-extension-for-wsl)
  - [For this deployment, I will be using `WSL` running Debian.](#for-this-deployment-i-will-be-using-wsl-running-debian)
- [Setup](#setup)
  - [1. Fork/Clone the AzCLI Source](#1-forkclone-the-azcli-source)
    - [(Optional) Fetch Upstream](#optional-fetch-upstream)
  - [2. Create a virtual environment for Python](#2-create-a-virtual-environment-for-python)
  - [3. Prepare and Install `AzDev`](#3-prepare-and-install-azdev)
  - [4. Setup `AzDev`](#4-setup-azdev)
- [Using `AzDev`](#using-azdev)
  - [Modifying an Az CLI extension](#modifying-an-az-cli-extension)
  - [Creating a new Az CLI Extension](#creating-a-new-az-cli-extension)
  - [Creating a new Az CLI Module](#creating-a-new-az-cli-module)
- [Testing our code](#testing-our-code)
  - [Use `AzDev Test`, `AzDev Linter`, and `AzDev Style` to test your newly created/modified Az CLI code](#use-azdev-test-azdev-linter-and-azdev-style-to-test-your-newly-createdmodified-az-cli-code)
  - [Run your code via a standard Az CLI command](#run-your-code-via-a-standard-az-cli-command)
- [Helpful Links](#helpful-links)


## Prerequisites
- Python 3.6 - 3.8. <u>3.9+ is not supported as of writing this.</u>
- Pip
- Wheel (via Pip)

> *For help installing an older version of Python 3.x, please check out this guide on [Installing Python 3.x from source](../Linux/install_python3_from_source.md)*.


### (Optional) Install VSCode extension for WSL
- A `WSL` instance to develop from.
- [VSCode Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)


### For this deployment, I will be using `WSL` running Debian.

## Setup

### 1. Fork/Clone the AzCLI Source

```bash
# Cloning from Source
git clone https://github.com/Azure/azure-cli.git

# Cloning from Fork
git clone https://github.com/<Github-User>/azure-cli.git
```

#### (Optional) Fetch Upstream
Incase we cloned a Fork, and it is out of date, we can fetch from upstream to ensure we are working on the newest version of the source.

```bash
# Move to dir containing source
cd azure-cli

# Set upstream repo to the official source.
git remote add upstream https://github.com/Azure/azure-cli.git

# Fetch from source
git fetch upstream
```

If you do this, you will likely need to reset the default branch for the repo so it matches the same on the official repo. For this, we can reset the local branch and set a default branch to build from.

> For [Az CLI](https://github.com/Azure/azure-cli) the default branch should be `dev`
```bash
git branch dev --set-upstream-to upstream/dev
```
> For [Az CLI Extensions](https://github.com/Azure/azure-cli-extensions) the default branch is `main`
```bash
git branch main --set-upstream-to upstream/main
```

### 2. Create a virtual environment for Python

In the root directory for your cloned repo, run the following.
```bash
python -m venv env
# or
python3 -m venv env
```

Then activate the environment.
```bash
source env/bin/activate
```


### 3. Prepare and Install `AzDev`

Install dependencies for `AzDev`.

```bash
sudo apt install gcc python3-dev -y
```

Upgrade `pip` for the system.

```bash
python3 -m pip install -U pip
```

Install `AzDev` in Python (via Pip)

```bash
pip install azdev
```


### 4. Setup `AzDev`

Now that `AzDev` is installed, we can set it up for our development environment.

In this example, I only want to work on an AzCLI extension. Therefore, I want to use whatever the upsteam version of the AzCLI is. For this, we only need to provide the local path to the extensions repo.

```bash
azdev setup --repo /path/to/azure-cli-extensions
```

If you also have a local Clone/Fork of the AzCLI, then you can use this command instead.

```bash
azdev setup --cli /path/to/azure-cli --repo /path/to/azure-cli-extensions
```


## Using `AzDev`

Now that `AzDev` is installed and setup, we can use it to test our new code. If you are just fixing a bug, or working on existing an existing module from the official Az CLI repository, you just need to use the standard Az CLI commands to use and test the code. i.e `azdev test ..` or `az ...`

Here are a few scenarios where you will need to run some additional `AzDev` commands prior to running your tests.

### Modifying an Az CLI extension

This will load the extension into the `AzDev` environment. Running `az extension add ...` will download the extension from the official upstream source.

```bash
azdev extension add <extension-name>

# Example: Working on a modified version of 'vm-repair'
azdev extension add vm-repair
```

### Creating a new Az CLI Extension
Creates the extension root folder and adds metadata. Then loads the extension into the `AzDev` environment.
```bash
azdev extension create <extension-name>
azdev extension add <extension-name>
```

### Creating a new Az CLI Module

Creates the module root folder within the local clone of the Az CLI. No further importing required to test.
```bash
azdev cli create <module-name>
```

## Testing our code

Now that you have modified or created code for the Az CLI, now we need to test it. For this, we can do a couple of things.

### Use `AzDev Test`, `AzDev Linter`, and `AzDev Style` to test your newly created/modified Az CLI code

`AzDev Test` will test the functionality to ensure your changes to not cause any breaking changes.
```bash
azdev test <extension-name/module-name>
```

`AzDev Linter` will run a linter over the code to ensure everything is properly spaced and indented.
```bash
azdev linter <extension-name/module-name>
```

`AzDev Test` will further lint and enforce compliance for different functions return standards.
```bash
azdev style <extension-name/module-name>
```

> **Note:** All of these will be ran via an automated pipeline when you submit a pull request to the upstream source. To ensure your pull request does not get blocked from merger, these same 3 tests need to pass. You can use the errors generated (if any) to implement whatever corrections needed.


### Run your code via a standard Az CLI command

Since we loaded our local instances of the AzCLI using `azdev`, we can use all the standard Az CLI commands from our python virtual environment.

```bash
az <module/extension> ...
```

Once you have finished your modifications and tested them, create a Pull request! If approved, your changes will be added to the upstream source for that Az CLI repo.

<br>

## Helpful Links
- [AzDev Documentation and Repo](https://github.com/Azure/azure-cli-dev-tools)
- [Authoring Az CLI Modules](https://github.com/Azure/azure-cli/tree/master/doc/authoring_command_modules)
- [Authoring Az CLI Extensions](https://github.com/Azure/azure-cli/blob/master/doc/extensions/authoring.md)

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
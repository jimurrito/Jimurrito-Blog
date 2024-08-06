---
layout: post
title:  "Setup AzCLI Development Environment"
date:   2024-08-05 21:00:00 -0700
categories: azure
---

The Az CLI is great, and maybe you want to add to its development. Maybe you want to fix a bug. This guide will show you how to setup `AzDev` with Python.

## Table of Contents
- [Prerequisites](#prerequisites)
   - [Optionals](#optional)
- [Setup](#setup)
   - [Fork/Clone the AzCLI Source](#1-forkclone-the-azcli-source)
   - [Create a Virtual Environment for Python](#2-create-a-virtual-environment-for-python)



## Prerequisites
- Python 3.6 - 3.8. <u>3.9+ is not supported as of writing this.</u>
- Pip
- Wheel (via Pip)

> *For help installing an older version of Python 3.x, please check out this guide on [Installing Python 3.x from source](../Linux/install_python3_from_source.md)*.


### Optional
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

#### [Optional] Fetch Upstream
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
> ```bash
> git branch dev --set-upstream-to upstream/dev
> ```
> For [Az CLI Extensions](https://github.com/Azure/azure-cli-extensions) the default branch is `main`
> ```bash
> git branch main --set-upstream-to upstream/main
> ```

## 2. Create a virtual environment for Python

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















### Helpful Links
- https://github.com/Azure/azure-cli-dev-tools

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
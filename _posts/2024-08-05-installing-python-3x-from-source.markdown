---
layout: post
title:  "Installing Python 3.x from Source"
date:   2024-08-05 21:00:00 -0700
categories: Linux WebDev
---

**Table of Contents**
- [1. (Optional) Removing existing Python 3.*x*](#1-optional-removing-existing-python-3x)
- [2. Install Pre-Requisites](#2-install-pre-requisites)
- [3. Decide which Python 3.*x* version to install](#3-decide-which-python-3x-version-to-install)
- [4. Download and extract source](#4-download-and-extract-source)
- [5. Install using `make`](#5-install-using-make)
- [6. Verify installation](#6-verify-installation)
- [7. Add Python 3.*x* to `PATH` variable](#7-add-python-3x-to-path-variable)
- [8. Install Pip](#8-install-pip)


As you use begin to use newer versions of Linux, you will notice that package managers like `apt` no longer provide older versions of different packages. This can cause issues with library dependencies, especially with Python.

An example; to develop for the Az CLI, you need to use Python 3.6 - 3.8. Did not support Python 3.9+ as of writing. 

When you install a fresh version of Debian 12, either via ISO, Azure, or WSL, you will notice that Python 3.11 is the default install.

```bash
python3 --version
#> Python 3.11.2
```

Due to this conflict, developing Az CLI code is not possible out of the box; we would need to remove and reinstall manually. Looking to even Debian 11, the version of Python is 3.9.

This guide will go over how to remove and reinstall Python 3.*x* to your Linux machine.

> *Please note that this guide focuses on Debian based Linux distros. While these steps may work for others, it is not guaranteed. <u>Your milage may vary.</u>*


## 1. (Optional) Removing existing Python 3.*x*
```bash
sudo apt autoremove python3 -y
```

## 2. Install Pre-Requisites
```bash
sudo apt update

sudo apt-get install \
    curl \
    gcc \
    libbz2-dev \
    libev-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncurses-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    make \
    tk-dev \
    wget \
    zlib1g-dev
```

## 3. Decide which Python 3.*x* version to install
In this case, I will choose the newest version of Python 3.8.

```bash
export PYTHON_VERSION=3.8.17
export PYTHON_MAJOR=3
```

## 4. Download and extract source
```bash
curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar -xvzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
```

## 5. Install using `make`
> This step could take 5-10 minutes to complete.

```bash
./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-shared \
    --enable-optimizations \
    --enable-ipv6 \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags

make
sudo make install
```


## 6. Verify installation
Run the following to confirm that we are seeing the desired version of Python.
```bash
/opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} --version
#> Python 3.8.17
```

From here, we are technically done. However, commands like `python3 ...` will not work with our current configuration. We need to add the installation of python to the `PATH` variable.


## 7. Add Python 3.*x* to `PATH` variable

**Non-persistent**

This version will last until you open a new shell session.

```bash
export PATH=/opt/python/${PYTHON_VERSION}/bin/:$PATH
```

**Persistent**

This version will be permanent, but requires a new shell session to propagate.

```bash
echo "PATH=/opt/python/${PYTHON_VERSION}/bin/:$PATH" > /etc/profile.d/python.sh
```

**Validate**
```bash
python3 --version
#> Python 3.8.17
```

## 8. Install Pip
Now that we installed Python 3.*x*, we need to also install Pip3 from source.
```bash
# Just in case you lost them, or reset your session
export PYTHON_VERSION=3.8.17
export PYTHON_MAJOR=3

curl -O https://bootstrap.pypa.io/get-pip.py
sudo /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} get-pip.py
```

**Validate**
```bash
pip3 --version
#> pip 24.2 from /opt/python/3.8.17/lib/python3.8/site-packages/pip (python 3.8)
```
or

```bash
pip --version
#> pip 24.2 from /opt/python/3.8.17/lib/python3.8/site-packages/pip (python 3.8)
```

...and thats it! We are done. Python and Pip are installed from source, we can know that they are the versions we need for our build.

If you have any issues, or find any errors in this guide, please reach out at my contact card below.

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
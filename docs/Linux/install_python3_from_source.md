# Install Python 3.*x* from source

###### *Published: 08/06/2024*

## Table of Contents
1. [Removing Python 3.*x*](#removing-existing-python-3x)

<br>

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


## 1. [Optional] Removing existing Python 3.*x*

In a bash terminal, run the following.

```bash
sudo apt autoremove python3 -y
```

## 2. 










---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](../profile.md)
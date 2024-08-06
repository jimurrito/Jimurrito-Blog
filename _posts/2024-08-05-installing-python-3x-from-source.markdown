---
layout: post
title:  "Installing Python 3.x from Source"
date:   2024-08-05 21:00:00 -0700
categories: linux
---

## Table of Contents
- [Removing existing Python 3.*x*](#1-optional-removing-existing-python-3x)
- [Install Pre-requisites](#2-install-pre-requisites)
- [Decide which Python 3.*x* version to install](#3-decide-which-python-3x-version-to-install)
- [Download and Extract source](#4-download-and-extract-source)
- [Install using `Make`](#5-install-using-make)
- [Verify Installation](#6-verify-installation)
- [Add Python 3.*x* to path variable](#7-add-python-3x-to-path-variable)
- [Install Pip](#install-pip)


As you use begin to use newer versions of Linux, you will notice that package managers like `apt` no longer provide older versions of different packages. This can cause issues with library dependencies, especially with Python.

An example; to develop for the Az CLI, you need to use Python 3.6 - 3.8. Did not support Python 3.9+ as of writing. 

When you install a fresh version of Debian 12, either via ISO, Azure, or WSL, you will notice that Python 3.11 is the default install.

{% highlight bash %}
python3 --version
#> Python 3.11.2
{% endhighlight %}

Due to this conflict, developing Az CLI code is not possible out of the box; we would need to remove and reinstall manually. Looking to even Debian 11, the version of Python is 3.9.

This guide will go over how to remove and reinstall Python 3.*x* to your Linux machine.

> *Please note that this guide focuses on Debian based Linux distros. While these steps may work for others, it is not guaranteed. <u>Your milage may vary.</u>*


## 1. [Optional] Removing existing Python 3.*x*
{% highlight bash %}
sudo apt autoremove python3 -y
{% endhighlight %}

## 2. Install Pre-Requisites
{% highlight bash %}
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
{% endhighlight %}

## 3. Decide which Python 3.*x* version to install
In this case, I will choose the newest version of Python 3.8.

{% highlight bash %}
export PYTHON_VERSION=3.8.17
export PYTHON_MAJOR=3
{% endhighlight %}

## 4. Download and extract source
{% highlight bash %}
curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar -xvzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
{% endhighlight %}

## 5. Install using `make`
> This step could take 5-10 minutes to complete.

{% highlight bash %}
./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-shared \
    --enable-optimizations \
    --enable-ipv6 \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags

make
sudo make install
{% endhighlight %}


## 6. Verify installation
Run the following to confirm that we are seeing the desired version of Python.
{% highlight bash %}
/opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} --version
#> Python 3.8.17
{% endhighlight %}

From here, we are technically done. However, commands like `python3 ...` will not work with our current configuration. We need to add the installation of python to the `PATH` variable.


## 7. Add Python 3.*x* to `PATH` variable

**Non-persistent**

This version will last until you open a new shell session.

{% highlight bash %}
export PATH=/opt/python/${PYTHON_VERSION}/bin/:$PATH
{% endhighlight %}

**Persistent**

This version will be permanent, but requires a new shell session to propagate.

{% highlight bash %}
echo "PATH=/opt/python/${PYTHON_VERSION}/bin/:$PATH" > /etc/profile.d/python.sh
{% endhighlight %}

**Validate**
{% highlight bash %}
python3 --version
#> Python 3.8.17
{% endhighlight %}

## Install Pip
Now that we installed Python 3.*x*, we need to also install Pip3 from source.
{% highlight bash %}
# Just in case you lost them, or reset your session
export PYTHON_VERSION=3.8.17
export PYTHON_MAJOR=3

curl -O https://bootstrap.pypa.io/get-pip.py
sudo /opt/python/${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} get-pip.py
{% endhighlight %}

**Validate**
{% highlight bash %}
pip3 --version
#> pip 24.2 from /opt/python/3.8.17/lib/python3.8/site-packages/pip (python 3.8)
{% endhighlight %}
or

{% highlight bash %}
pip --version
#> pip 24.2 from /opt/python/3.8.17/lib/python3.8/site-packages/pip (python 3.8)
{% endhighlight %}

...and thats it! We are done. Python and Pip are installed from source, we can know that they are the versions we need for our build.

If you have any issues, or find any errors in this guide, please reach out at my contact card below.

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
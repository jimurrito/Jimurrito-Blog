---
layout: post
title:  "Running Jekyll Locally"
date:   2024-08-06 14:00:00 -0700
categories: Linux WebDev
---

Quick guide that goes over installing and running `Jekyll`.

**Table of Contents**
- [Setup](#setup)
- [How to use](#how-to-use)
- [Helpful Links](#helpful-links)


## Setup

- Install Ruby 
{% highlight bash %}
sudo apt-get install ruby-full build-essential zlib1g-dev -y
{% endhighlight %}

- Setup Gem install dir to local user 
{% highlight bash %}
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
{% endhighlight %}

- Install Jekyll and Bundler
{% highlight bash %}
gem install jekyll bundler
{% endhighlight %}


## How to use

- Navigate to the publishing directory of your Github pages repo.
- Build your site
{% highlight bash %}
bundle install
{% endhighlight %}

- Run the site instance
{% highlight bash %}
bundle exec jekyll serve
{% endhighlight %}


## Helpful Links
- [Setup Jekyll for local builds](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)
- [Create a new Jekyll project for github-pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll)

<br>

---

<br>

<img src="https://avatars.githubusercontent.com/u/77898354?v=4" alt="Profile_Pic_Git" width="100" height="100"/>

Written by [James Immer](/bio)
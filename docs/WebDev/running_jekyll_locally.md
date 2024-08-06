
## Setup Linux

- Install Ruby 
  ```bash
  sudo apt-get install ruby-full build-essential zlib1g-dev -y
  ```
- Setup Gem install dir to local user 
    ```bash
    echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```
- Install Jekyll and Bundler
  ```bash
  gem install jekyll bundler
  ```

## How to use

- Navigate to the publishing directory of your Github pages repo.
- Build your site
  ``` bash
  bundle install
  ```
- Run the site instance
  ```bash
  bundle exec jekyll serve
  ```
    
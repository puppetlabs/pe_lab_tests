#!/bin/sh

# Get Ruby version from parameter
RUBY_VERSION=$PT_ruby_version
echo "Installing Ruby version: $RUBY_VERSION"

# Install dependencies
sudo dnf config-manager --set-enabled powertools
sudo dnf groupinstall "Development Tools" -y
sudo dnf install -y libyaml-devel
sudo dnf install git curl openssl-devel readline-devel zlib-devel libffi-devel -y

# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby (using parameter)
~/.rbenv/bin/rbenv install $RUBY_VERSION
~/.rbenv/bin/rbenv global $RUBY_VERSION

# Install bundler
~/.rbenv/shims/gem install bundler
~/.rbenv/bin/rbenv rehash

# Verify installation
echo "Ruby version:"
~/.rbenv/shims/ruby --version
echo "Bundler version:"
~/.rbenv/shims/bundle --version
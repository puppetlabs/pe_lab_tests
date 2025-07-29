#!/bin/sh

# Get Ruby version from parameter
RUBY_VERSION=$PT_ruby_version
echo "Installing Ruby version: $RUBY_VERSION"

# Check if rbenv and the correct Ruby version are already installed
if [ -d "$HOME/.rbenv" ] && [ -x "$HOME/.rbenv/bin/rbenv" ]; then
  echo "rbenv found, checking installed Ruby versions..."
  
  # Check if the specific version is already installed and set as global
  CURRENT_GLOBAL=$(~/.rbenv/bin/rbenv global 2>/dev/null || echo "none")
  
  if [ "$CURRENT_GLOBAL" = "$RUBY_VERSION" ]; then
    echo "Ruby $RUBY_VERSION is already installed and set as global version"
    
    # Verify bundler is available
    if ~/.rbenv/shims/bundle --version >/dev/null 2>&1; then
      echo "Bundler is already installed"
      echo "Setup complete - Ruby $RUBY_VERSION is ready to use"
      exit 0
    else
      echo "Installing bundler..."
      ~/.rbenv/shims/gem install bundler
      ~/.rbenv/bin/rbenv rehash
      echo "Setup complete - Ruby $RUBY_VERSION is ready to use"
      exit 0
    fi
  elif ~/.rbenv/bin/rbenv versions | grep -q "$RUBY_VERSION"; then
    echo "Ruby $RUBY_VERSION is installed but not set as global, setting it now..."
    ~/.rbenv/bin/rbenv global $RUBY_VERSION
    
    # Ensure bundler is available
    ~/.rbenv/shims/gem install bundler
    ~/.rbenv/bin/rbenv rehash
    echo "Setup complete - Ruby $RUBY_VERSION is now set as global version"
    exit 0
  else
    echo "Ruby $RUBY_VERSION not found, proceeding with installation..."
  fi
else
  echo "rbenv not found, proceeding with full installation..."
fi

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
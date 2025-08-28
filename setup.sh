#!/bin/bash

set -e  # Exit on any error

echo "🚀 Setting up your new Mac..."

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for M1/M2 Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# Download and install from Brewfile
echo "📥 Downloading dotfiles..."
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/Brewfile -o /tmp/Brewfile

echo "🍺 Installing all packages from Brewfile..."
brew bundle install --file=/tmp/Brewfile

echo "🧹 Cleaning up..."
rm /tmp/Brewfile

echo "✨ Setup complete! You may need to restart your terminal."
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

echo "⚙️  Setting up dotfiles..."

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh already installed"
fi

# Download and install config files
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.gitconfig -o ~/.gitconfig
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.zshrc -o ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.zprofile -o ~/.zprofile

# Setup SSH directory and config
mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/ssh/config -o ~/.ssh/config
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/ssh/id_ed25519.pub -o ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/config ~/.ssh/id_ed25519.pub

echo "🧹 Cleaning up..."
rm /tmp/Brewfile

echo "✨ Setup complete! You may need to restart your terminal."
echo "⚠️  Don't forget to:"
echo "   - Add your SSH private key to ~/.ssh/id_ed25519"
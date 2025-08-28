# Dotfiles

My personal dotfiles and configuration setup.

## One-Command Setup 🚀

On your new Mac, just run this in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/setup.sh | bash
```

This will:
1. Install Homebrew (if not installed)
2. Download your Brewfile
3. Install all CLI tools, GUI apps, and VS Code extensions

## Manual Setup (Alternative)

```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone repo and install
git clone https://github.com/tsibog/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle install
```

## What Gets Installed

- Development tools: git, node, deno, docker, ripgrep, etc.
- GUI apps: Arc, Discord, Obsidian, Spotify, VS Code, etc.
- VS Code extensions: Claude Code, Copilot, Tailwind, etc.

## Updating

To capture new apps you've installed:
```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```
# Dotfiles

My personal dotfiles and configuration setup.

## Recommended Setup 🚀

On your new Mac, run these commands in Terminal:

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

**Why download first?** Some apps may prompt for sudo password - you'll see the prompts this way.

This will:
1. Install Homebrew (if not installed)
2. Install Oh My Zsh and restore shell configuration
3. Install all CLI tools, GUI apps, and VS Code extensions
4. Set up Git configuration and SSH config

## Alternative: One-Command Setup

If you prefer a single command (may hang on sudo prompts):

```bash
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/setup.sh | bash
```

## Manual Setup

```bash
# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Clone repo and install
git clone https://github.com/tsibog/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle install
```

## SSH Keys Setup

SSH keys are **automatically generated** during setup! The setup script will:

1. Generate a fresh Ed25519 SSH key pair
2. Add it to the SSH agent  
3. Copy the public key to your clipboard

**Manual step:** Just paste the key into GitHub:
- Go to GitHub Settings > SSH and GPG Keys > New SSH Key
- Paste the key (already in clipboard) and save
- Test: `ssh -T git@github.com`

**Why fresh keys?** More secure than transferring private keys between machines.

## What Gets Installed

- Development tools: git, node, deno, docker, ripgrep, etc.
- GUI apps: Arc, Discord, Obsidian, Spotify, VS Code, etc.
- VS Code extensions: Claude Code, Copilot, Tailwind, etc.
- Shell setup: Oh My Zsh with custom configuration
- Git configuration with your user details

## Updating

To capture new apps you've installed:
```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```
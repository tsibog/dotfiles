#!/bin/bash

# Create error log
ERROR_LOG="$HOME/dotfiles-setup-errors.log"
echo "Setup started at $(date)" > "$ERROR_LOG"

# Function to log errors but continue
log_error() {
    echo "❌ ERROR: $1" | tee -a "$ERROR_LOG"
    echo "   Command: $2" >> "$ERROR_LOG"
    echo "   Time: $(date)" >> "$ERROR_LOG"
    echo "" >> "$ERROR_LOG"
}

echo "🚀 Setting up your new Mac..."
echo "📝 Errors will be logged to: $ERROR_LOG"

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
if ! brew bundle install --file=/tmp/Brewfile; then
    log_error "Brewfile installation failed" "brew bundle install --file=/tmp/Brewfile"
    echo "⚠️  Some packages may have failed to install. Check $ERROR_LOG for details."
else
    echo "✅ Brewfile installation completed successfully"
fi

echo "⚙️  Setting up dotfiles..."

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_error "Oh My Zsh installation failed" "oh-my-zsh install script"
    else
        echo "✅ Oh My Zsh installed successfully"
    fi
else
    echo "✅ Oh My Zsh already installed"
fi

# Download and install config files
echo "📄 Downloading config files..."
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.gitconfig -o ~/.gitconfig || log_error "Failed to download .gitconfig" "curl .gitconfig"
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.zshrc -o ~/.zshrc || log_error "Failed to download .zshrc" "curl .zshrc"  
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/.zprofile -o ~/.zprofile || log_error "Failed to download .zprofile" "curl .zprofile"

# Install Claude CLI via npm
echo "🤖 Installing Claude CLI..."
if command -v npm &> /dev/null; then
    if ! npm install -g @anthropic-ai/claude-code; then
        log_error "Failed to install Claude CLI" "npm install -g @anthropic-ai/claude-code"
    else
        echo "✅ Claude CLI installed successfully"
    fi
else
    log_error "npm not found - Claude CLI installation skipped" "npm install -g @anthropic-ai/claude-code"
fi

# Install claude-switch
echo "🔀 Installing claude-switch..."
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/bin/claude-switch -o ~/.local/bin/claude-switch
chmod +x ~/.local/bin/claude-switch
echo "✅ claude-switch installed to ~/.local/bin/"

# Install Claude Code skills
SKILLS="api-endpoint commit commit-split create-mr diy find-skills jira-cleanup mr-breakdown ship svelte-component svelte-core-bestpractices ticket week-summary"
echo "🧠 Installing Claude Code skills..."
mkdir -p ~/.claude/skills
for skill in $SKILLS; do
    mkdir -p ~/.claude/skills/"$skill"
    curl -fsSL "https://raw.githubusercontent.com/tsibog/dotfiles/master/claude/skills/${skill}/SKILL.md" -o ~/.claude/skills/"$skill"/SKILL.md || log_error "Failed to download skill: $skill" "curl skill $skill"
done
echo "✅ Claude Code skills installed"

# Setup SSH directory and config
mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl -fsSL https://raw.githubusercontent.com/tsibog/dotfiles/master/ssh/config -o ~/.ssh/config
chmod 644 ~/.ssh/config

# Generate fresh SSH key automatically
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "🔑 Generating fresh SSH key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "$(git config user.email || echo "$(whoami)@$(hostname)")"
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    
    # Add key to ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    # Copy public key to clipboard
    pbcopy < ~/.ssh/id_ed25519.pub
    echo "📋 SSH public key copied to clipboard!"
else
    echo "✅ SSH key already exists"
fi

echo "🧹 Cleaning up..."
rm /tmp/Brewfile

echo "✨ Setup complete! You may need to restart your terminal."

# Show summary
if [ -s "$ERROR_LOG" ] && [ "$(wc -l < "$ERROR_LOG")" -gt 1 ]; then
    echo "⚠️  Some steps encountered errors. Check the log:"
    echo "   cat $ERROR_LOG"
    echo ""
fi

echo "🔑 Next steps:"
echo "   - SSH key has been generated and copied to clipboard"
echo "   - Go to GitHub Settings > SSH Keys and paste the key" 
echo "   - Test connection: ssh -T git@github.com"
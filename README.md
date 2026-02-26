# Home Manager Configuration

A modular Home Manager configuration for development environments with integrated tooling and Claude Code support.

## Overview

This configuration provides a comprehensive development setup including:

- **Development Environment**: Neovim with LSP, tmux, fish shell, starship prompt
- **Language Support**: TypeScript, JavaScript, Go, Python, Lua, Terraform, YAML
- **AI Integration**: Claude Code with custom configuration
- **Infrastructure Tools**: AWS CLI, Terraform, Docker, direnv
- **Development Utilities**: asdf version manager, cachix, devenv

## Installation

### 1. Install Nix

**Linux/WSL2:**
```bash
# Install Nix with flakes support
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Source the nix environment (or restart shell)
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

**Alternative (Official installer):**
```bash
# Install Nix (single-user)
curl -L https://nixos.org/nix/install | sh

# Enable flakes (add to ~/.config/nix/nix.conf or /etc/nix/nix.conf)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Install Home Manager

```bash
# Add Home Manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Install Home Manager
nix-shell '<home-manager>' -A install
```

### 3. Deploy Configuration

```bash
# Clone this configuration
git clone <your-repo-url> ~/.config/home-manager
cd ~/.config/home-manager

# Install/update configuration
home-manager switch --flake .

# Check status
home-manager generations
```

## Quick Start

After installation, use these commands for daily operations:

```bash
# Update configuration
home-manager switch --flake .

# List generations
home-manager generations

# Rollback if needed
home-manager switch --flake . --rollback
```

## Features

### Editor & Development
- **Neovim**: Configured with LSP, TreeSitter, Telescope, and modern plugins
- **Language Servers**: TypeScript, Go, Lua, Terraform, YAML, Astro
- **Shell**: Fish with asdf integration and starship prompt
- **Terminal**: tmux with custom configuration

### Claude Code Integration

This configuration includes Claude Code setup with:

- **Package Installation**: `claude-code` package automatically installed
- **Configuration Files**: 
  - Global instructions: `~/.claude/CLAUDE.md`
  - Settings: `~/.claude/settings.json` 
  - Ignore patterns: `~/.claude/.claudeignore`

The Claude configuration is set up for software engineering workflows with:
- Principal Engineer persona with 10+ years experience
- Focus on Python, Go, AWS, GCP, Terraform, CI/CD
- Incremental development philosophy
- Infrastructure and DevOps best practices

### Infrastructure & Cloud
- **AWS**: CLI v2 with aws-vault for credential management
- **Terraform**: Language server and CLI tools
- **Docker**: Configured with proper socket access
- **PostgreSQL**: Development database

## Module Structure

```
modules/
├── claude/
│   ├── claude.nix          # Claude Code package and file management
│   ├── CLAUDE.md           # Global Claude instructions
│   ├── settings.json       # Claude settings
│   └── .claudeignore       # Claude ignore patterns
├── starship/
│   └── starship.toml       # Prompt configuration
└── set-fish-shell.nix      # Fish shell setup
```

## Configuration Files

### Core Files
- `flake.nix` - Nix flake definition
- `home.nix` - Main Home Manager configuration
- `flake.lock` - Locked dependency versions

### Neovim
- `nvim-config/` - Lua configuration files
- Integrated with system clipboard via `xclip`

## System Requirements

- Linux, macOS, or WSL2
- Git
- Curl (for installation)
- Bash shell (for installation scripts)

## Troubleshooting

### Common Issues

**Flakes not enabled:**
```bash
# Add to ~/.config/nix/nix.conf
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

**WSL2 specific:**
```bash
# If you get locale warnings, add to your shell config:
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

**Permission issues:**
```bash
# Ensure Nix daemon is running (multi-user install)
sudo systemctl enable nix-daemon
sudo systemctl start nix-daemon
```

## Development Workflow

The configuration supports modern development patterns:

1. **Version Management**: asdf for runtime versions
2. **Environment Management**: direnv for project-specific environments
3. **Containerization**: Docker with proper socket access
4. **Infrastructure**: Terraform with language server support
5. **AI Assistance**: Claude Code for development tasks

## Recent Changes

### Claude Code Integration (Current Branch)
- Added `claude-code` package installation
- Configured global Claude instructions for software engineering
- Set up Claude settings and ignore patterns
- Integrated Claude module into main configuration

The Claude setup provides an AI pair programming experience optimized for:
- Infrastructure as Code (Terraform, AWS)
- Backend development (Go, Python)
- CI/CD and DevOps workflows
- Security-conscious development practices

## Usage

After switching to this configuration, Claude Code will be available with pre-configured:
- Engineering best practices and standards
- AWS and GCP infrastructure patterns
- CI/CD pipeline templates
- Security and observability guidelines

Access Claude via the `claude` command with full context of your development environment and coding standards.
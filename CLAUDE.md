# Home Manager Project Configuration

<!-- This extends the global engineering config at ~/.claude/CLAUDE.md -->

**Use all global engineering practices and standards from `~/.claude/CLAUDE.md`, plus the project-specific context below.**

## Project Context

This is a **Home Manager configuration** using Nix flakes for declarative development environment management.

### Technology Stack
- **Nix/NixOS**: Package management and system configuration
- **Home Manager**: User environment and dotfile management  
- **Nix Flakes**: Reproducible, composable configurations
- **Modules**: Modular configuration structure

### Key Files & Structure
- `flake.nix` - Main flake definition with inputs/outputs
- `home.nix` - Primary Home Manager configuration
- `modules/` - Reusable configuration modules
- `flake.lock` - Locked dependency versions (don't edit manually)

### Development Principles

**Nix-Specific:**
- Prefer pure, reproducible expressions
- Use `lib` functions for complex logic
- Pin versions via flake inputs, not hardcoded strings
- Test changes with `nix flake check` before committing
- Modularize reusable configuration into `modules/`

**Home Manager Patterns:**
- Import modules via `imports = [ ./modules/... ]`
- Use `programs.*` options over manual `home.file` when available
- Leverage `xdg.*` for cross-platform config placement
- Test config changes with `home-manager switch --flake .`

### Common Tasks

**Adding Packages:**
```nix
home.packages = with pkgs; [ new-package ];
```

**Creating Modules:**
```nix
# modules/feature/default.nix
{ config, pkgs, lib, ... }: {
  # module implementation
}
```

**Debugging:**
- `nix flake show` - show available outputs
- `home-manager switch --flake . --show-trace` - detailed errors
- `nix-store --verify --check-contents` - verify store integrity

### Security & Best Practices
- Never commit secrets to Nix expressions
- Use `sops-nix` or similar for secret management  
- Test configuration in isolated environments first
- Document module options and examples
- Use semantic versioning for flake updates

### When Making Changes
1. Test locally with `home-manager switch --flake .`
2. Verify with `nix flake check`
3. Update documentation in README.md
4. Consider backward compatibility
5. Test rollback capability

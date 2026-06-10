# ❄️ Modular NixOS & Home Manager Configuration

Welcome to my personal, flake-based NixOS configuration. This setup is fully modularized, keeping system-level configurations and user-level dotfiles (via Home Manager) cleanly separated and organized.

> 💡 **Note:** I am a Computer Science student transitioning to NixOS. I used an AI assistant to help me structure parts of these configurations, handle the syntax, and write clean, informative comments within the codebase.

---

## 📁 Repository Structure

The project follows a standard Nix flake directory layout:

```text
nixos-config
├── flake.nix                  # Main entry point for the system configuration
├── README.md                  # This documentation file
├── hosts/
│   └── default/
│       └── configuration.nix  # System-level settings, hardware imports, and core config
└── home/
    ├── zizo.nix               # User-specific Home Manager profile configuration
    └── modules/               # Modular standalone configurations for apps & environment
        ├── ghoststy.nix       # Ghostty terminal emulator styling & configuration
        ├── hyprland.nix       # Hyprland tiling window manager settings & keybinds
        ├── neovim.nix         # Neovim text editor setup and plugins
        ├── shell.nix          # Shell configurations, aliases, and environment variables
        └── waybar.nix         # Waybar status bar customization

# NixOS system flake
# Host: zizo | ASUS TUF Gaming A15 FA506NC
# Stack: Hyprland + Gruvbox Dark Hard + Wayland + AMD/NVIDIA Hybrid GPU

{
  description = "Zizo's NixOS Configuration — ASUS TUF A15 | Gruvbox + Hyprland";

  inputs = {
    # Core nixpkgs — unstable for latest Hyprland, Ghostty, and GPU driver patches
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager — must follow nixpkgs to avoid version mismatch warnings
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland — pulled from its own flake to stay in sync with
    # xdg-desktop-portal-hyprland (mixing versions causes portal failures).
    # Both programs.hyprland.package and programs.hyprland.portalPackage
    # in configuration.nix reference inputs.hyprland.packages.*.
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix — system-wide theming engine.
    # home-manager.follows prevents a duplicate home-manager closure.
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows    = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Zen Browser — not yet in nixpkgs.
    # "default" package on main branch tracks the stable/beta channel.
    # home-manager.follows keeps the closure small.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
  {
    nixosConfigurations.zizo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Pass the full inputs attrset so every module can reach
      # inputs.hyprland, inputs.zen-browser, etc. without re-importing.
      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/default/configuration.nix

        stylix.nixosModules.stylix

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            # useGlobalPkgs — HM uses the system nixpkgs instance,
            # avoiding a second evaluation of nixpkgs.
            useGlobalPkgs    = true;

            # useUserPackages — packages declared in home.packages land in
            # /etc/profiles/per-user/<user> rather than ~/.nix-profile,
            # which is required for some system integrations (e.g. PAM).
            useUserPackages  = true;

            # Forward inputs so zizo.nix can reference zen-browser, hyprland, etc.
            extraSpecialArgs = { inherit inputs; };

            users.ziad = import ./home/zizo.nix;
          };
        }
      ];
    };
  };
}

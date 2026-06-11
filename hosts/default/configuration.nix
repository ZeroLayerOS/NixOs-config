# NixOS system configuration
# Host: zizo | ASUS TUF Gaming A15 FA506NC
# Stack: Hyprland + Gruvbox Dark Hard + Wayland + AMD/NVIDIA Hybrid GPU

{ config, pkgs, inputs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Nix daemon ────────────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      trusted-users         = [ "root" "ziad" ];
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
      ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };

  # Allow proprietary packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # ── Boot loader ───────────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot = {
        enable             = true;
        configurationLimit = 10;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint     = "/boot/efi";
      };
      timeout = 3;
    };
    # Latest kernel for AMD P-state driver and RTL8852BE WiFi support
    kernelPackages = pkgs.linuxPackages_latest;
    # Plymouth is disabled — known to break SDDM on NixOS 25.05+ (nixpkgs#431207)
  };

  # ── Network ───────────────────────────────────────────────────────────────
  networking = {
    hostName              = "zizo";
    networkmanager.enable = true;
    firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # ── Locale / time ─────────────────────────────────────────────────────────
  time.timeZone = "Africa/Cairo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME     = "en_US.UTF-8";
      LC_MONETARY = "ar_EG.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ar_EG.UTF-8/UTF-8"
    ];
  };

  # ── GPU ───────────────────────────────────────────────────────────────────
  # X server is required even on Wayland for XWayland and driver initialisation
  services.xserver = {
    enable       = true;
    videoDrivers = [ "amdgpu" "nvidia" ];
    xkb = {
      layout  = "us,ara";
      options = "grp:alt_shift_toggle";
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # Fine-grained power management — turns the dGPU fully off when idle.
    # Supported on Turing (RTX 20xx) and newer; RTX 3050 Mobile qualifies.
    powerManagement.enable            = true;
    powerManagement.finegrained       = true;

    # Use the proprietary driver — open kernel module is unstable on Ampere mobile.
    open = false;

    nvidiaSettings = true;

    prime = {
      offload = {
        enable           = true;
        # Generates the `nvidia-offload` wrapper script used in hyprland.nix
        # and the nvidia-run alias in shell.nix.
        enableOffloadCmd = true;
      };
      # Bus IDs confirmed via: sudo lspci | grep -E "VGA|3D"
      # 01:00.0 → NVIDIA GeForce RTX 3050 Mobile
      # 05:00.0 → AMD Radeon 680M (iGPU)
      nvidiaBusId  = "PCI:1:0:0";
      amdgpuBusId  = "PCI:5:0:0";
    };
  };

  # Enable OpenGL / hardware acceleration
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  # ── Display manager — SDDM ────────────────────────────────────────────────
  # Qt6 build required for sddm-astronaut theme.
  # qtmultimedia fixes "module QtMultimedia is not installed" on unstable/25.05
  # (nixpkgs#390251).
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    package        = pkgs.kdePackages.sddm;
    theme          = "sddm-astronaut-theme";
    extraPackages  = [
      pkgs.sddm-astronaut
      pkgs.kdePackages.qtmultimedia
    ];
    settings = {
      Theme.CursorTheme = "Bibata-Modern-Amber";
    };
  };

  # ── Hyprland ──────────────────────────────────────────────────────────────
  # Packages come from the flake input to ensure version consistency
  # with xdg-desktop-portal-hyprland (mixing versions causes portal failures).
  programs.hyprland = {
    enable        = true;
    package       = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # XDG portal — hyprland portal is added automatically by programs.hyprland above
  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ── Audio — PipeWire ──────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true;
  };

  # ── Bluetooth ─────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  # ── Input — touchpad ──────────────────────────────────────────────────────
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping          = true;
      middleEmulation  = true;
      accelSpeed       = "0.3";
    };
  };

  # ── Power management ──────────────────────────────────────────────────────
  # thermald is intentionally absent — conflicts with power-profiles-daemon
  # on amd_pstate systems.
  services.power-profiles-daemon.enable = true;
  powerManagement = {
    enable          = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # ── User account ──────────────────────────────────────────────────────────
  users.users.ziad = {
    isNormalUser = true;
    description  = "Ziad Ali";
    home         = "/home/ziad";
    shell        = pkgs.zsh;
    linger       = true;
    extraGroups  = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "docker"
      "libvirtd"
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  # ── System packages ───────────────────────────────────────────────────────
  # Only packages that must be system-wide go here.
  # User-specific tools live in home.packages in ziad.nix.
  environment.systemPackages = with pkgs; [
    # Core utilities
    git curl wget
    unzip zip p7zip
    file tree
    htop btop
    lsof pciutils usbutils
    nvme-cli

    # GPU diagnostics
    nvtopPackages.full
    radeontop
    vulkan-tools
    glxinfo

    # Networking
    networkmanagerapplet
    wl-clipboard

    # Wayland essentials
    wayland-utils
    xwayland
    brightnessctl
    polkit_gnome

    # ASUS-specific utilities
    asusctl
    supergfxctl

    # Fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    font-awesome

    # Theming
    gruvbox-gtk-theme
    sddm-astronaut

    # PostgreSQL client tools
    postgresql_16
    pgcli
    dbeaver-bin

    # Miscellaneous
    libnotify
    xdg-utils
    shared-mime-info
  ];

  # ── Programs ──────────────────────────────────────────────────────────────
  programs = {
    zsh.enable   = true;
    dconf.enable = true;
    gnupg.agent = {
      enable           = true;
      enableSSHSupport = true;
    };
    thunar = {
      enable  = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  # ── Virtualisation ────────────────────────────────────────────────────────
  # Docker disabled on boot to avoid unnecessary startup overhead.
  virtualisation.docker = {
    enable       = true;
    enableOnBoot = false;
    autoPrune = {
      enable = true;
      dates  = "weekly";
    };
    daemon.settings = {
      userland-proxy = false;
    };
  };

  # ── Stylix — system-wide Gruvbox Dark Hard theming ────────────────────────
  stylix = {
    enable = true;
    image  = if builtins.pathExists ./wallpaper.jpg
             then ./wallpaper.jpg
             else builtins.fetchurl {
               url    = "https://raw.githubusercontent.com/NixOS/nixos-artwork/master/wallpapers/nix-wallpaper-dracula.png";
               sha256 = "sha256:07ly21bhs6cgfl7pv4xlqzdqm44h22frwfhdqyd4gkn2jlalwaab";
             };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity     = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name    = "Bibata-Modern-Amber";
      size    = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name    = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name    = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name    = "Noto Serif";
      };
      sizes = {
        terminal     = 13;
        applications = 12;
        desktop      = 12;
        popups       = 12;
      };
    };
  };

  # ── PostgreSQL — local development instance ───────────────────────────────
  services.postgresql = {
    enable  = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 50 ''
      # TYPE  DATABASE  USER      ADDRESS          METHOD
      local   all       postgres                   trust
      local   all       all                        trust
      host    all       all       127.0.0.1/32     scram-sha-256
      host    all       all       ::1/32           scram-sha-256
    '';
    settings = {
      shared_buffers       = "256MB";
      effective_cache_size = "768MB";
      maintenance_work_mem = "64MB";
      work_mem             = "4MB";
      max_connections      = 100;
      log_connections      = true;
      log_duration         = false;
      log_statement        = "ddl";
    };
    initialScript = pkgs.writeText "pg-init" ''
      CREATE USER ziad WITH SUPERUSER PASSWORD 'ziad';
      CREATE DATABASE gradeiq OWNER ziad;
      CREATE DATABASE dev     OWNER ziad;
    '';
  };

  # ── System services ───────────────────────────────────────────────────────
  services = {
    gvfs.enable     = true;
    tumbler.enable  = true;
    printing.enable = true;
    avahi = {
      enable   = true;
      nssmdns4 = true;
    };
    udisks2.enable = true;
    upower.enable  = true;
    fwupd.enable   = true;
    gnome.gnome-keyring.enable = true;
  };

  security = {
    polkit.enable = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

  # Force Electron and Chromium apps to use native Wayland instead of XWayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "25.05";
}

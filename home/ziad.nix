# Home Manager configuration for user: ziad
# Theme: Gruvbox Dark Hard | Shell: Zsh | WM: Hyprland

{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./modules/hyprland.nix
    ./modules/waybar.nix
    ./modules/ghostty.nix
    ./modules/neovim.nix
    ./modules/shell.nix
    # rofi.nix is superseded by programs.rofi below; kept for reference
    # ./modules/rofi.nix
  ];

  home = {
    username     = "ziad";
    homeDirectory = "/home/ziad";
    stateVersion  = "25.05";

    # Preferred over sessionVariables.PATH — evaluated after profile sources
    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

    packages = with pkgs; [
      # Terminal utilities
      fastfetch
      eza          # modern ls replacement
      bat          # syntax-highlighted cat
     #fd           # fast find alternative
     # ripgrep      # fast grep alternative
      fzf          # fuzzy finder
      zoxide       # smarter directory jumping
      delta        # better git diff pager
      lazygit      # git TUI
      yazi         # terminal file manager
      bottom       # system resource monitor
      dust         # disk usage analyser
      tokei        # code statistics
      procs        # modern ps replacement (aliased in shell.nix)

      # Wayland / Hyprland ecosystem
     # rofi-wayland
      swww             # animated wallpaper daemon
      grimblast        # Hyprland-native screenshot tool
      slurp            # screen area selection
      wf-recorder      # screen recording
      hyprpicker       # colour picker

      # GTK / theming
      nwg-look         # GTK settings GUI

      # Applications
      zed-editor
      inputs.zen-browser.packages.${pkgs.system}.default
      pavucontrol
      blueman

      # Development toolchain
      #gcc
      gnumake
      cmake
      pkg-config
      rustup
      python3
      nodejs
      docker-compose

      # Productivity
      obsidian

      # Media
      mpv
      imv
    ];
  };

  # Disable Stylix auto-management for GTK and cursor.
  # GTK is handled manually below with gruvbox-gtk-theme.
  # Cursor is managed by gtk.cursorTheme to avoid a double-definition conflict.
  stylix.targets.gtk.enable      = false;
#  stylix.targets.cursor.enable   = false;
  stylix.targets.hyprland.enable = false;

  # GTK theming — Gruvbox Dark BL variant
  gtk = {
    enable = true;
    theme = {
      name    = "Gruvbox-Dark-BL";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name    = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name    = "Bibata-Modern-Amber";
      package = pkgs.bibata-cursors;
      size    = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";

  };

  # XDG directories and MIME associations
  xdg = {
    enable = true;
    userDirs = {
      enable            = true;
      createDirectories = true;
      desktop   = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download  = "${config.home.homeDirectory}/Downloads";
      music     = "${config.home.homeDirectory}/Music";
      pictures  = "${config.home.homeDirectory}/Pictures";
      videos    = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        # zen-browser flake installs the desktop file as "zen.desktop"
        "text/html"              = "zen.desktop";
        "x-scheme-handler/http"  = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "image/jpeg"             = "imv.desktop";
        "image/png"              = "imv.desktop";
        "video/mp4"              = "mpv.desktop";
        "inode/directory"        = "thunar.desktop";
      };
    };
  };

  programs.git = {
    enable    = true;
    userName  = "Ziad Ali";
    userEmail = "zalshemy9@gmail.com";
    extraConfig = {
      init.defaultBranch  = "main";
      pull.rebase         = true;
      protocol.version    = 2;
      http.postBuffer     = 524288000;
      core = {
        editor   = "nvim";
        pager    = "delta";
        autocrlf = "input";
      };
      delta = {
        navigate     = true;
        dark         = true;
        line-numbers = true;
        syntax-theme = "gruvbox-dark";
      };
      "protocol \"ipv4\"".allow          = "always";
      "url \"https://github.com/\"".insteadOf = "git://github.com/";
    };
  };

  programs.ssh = {
    enable          = true;
    addKeysToAgent  = "yes";
    matchBlocks."github.com" = {
      hostname     = "github.com";
      user         = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
  };

  # Services
  services = {
    dunst = {
      enable = true;
      settings = lib.mkForce {
        global = {
          font            = "JetBrainsMono Nerd Font 11";
          frame_color     = "#d79921";
          separator_color = "#d79921";
          background      = "#1d2021";
          foreground      = "#ebdbb2";
          corner_radius   = 8;
          offset          = "10x10";
          origin          = "top-right";
          timeout         = 5;
        };
        urgency_normal.background   = "#282828";
        urgency_critical.background = "#cc241d";
      };
    };

    # Clipboard history manager
    cliphist.enable = true;

    # Idle management — hypridle is the native Hyprland idle daemon.
    # "hypridle" is intentionally absent from exec-once in hyprland.nix;
    # this systemd service handles startup instead.
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd     = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };
        listener = [
          {
            timeout    = 300;
            on-timeout = "hyprlock";
          }
          {
            timeout   = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume  = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  # Rofi launcher — single authoritative definition here.
  # rofi.nix is kept in modules/ for reference but NOT imported above.
#  programs.rofi = {
 #   enable = true;
  #  package = pkgs.rofi-wayland;
   # terminal = "${pkgs.ghostty}/bin/ghostty";
    #theme = "gruvbox-dark-hard";
    #extraConfig = {
     # modi       = "run,drun,window";
      #show-icons = true;
    #};
  #};
  programs.wofi = {
  enable = true;
  settings = {
    width         = 600;
    height        = 400;
    #terminal      = "${pkgs.ghostty}/bin/ghostty";
    show          = "drun";
    insensitive   = true;
    prompt        = "Search...";
    allow_markup  = true;
    allow_images  = true;
  };
};

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
}

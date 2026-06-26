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
    # rofi.nix is superseded by programs.wofi below; kept for reference
    # ./modules/rofi.nix
  ];

  # ── Home ──────────────────────────────────────────────────────────────────
  home = {
    username      = "ziad";
    homeDirectory = "/home/ziad";
    stateVersion  = "25.05";

    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

    packages = with pkgs; [
      # Terminal utilities
      fastfetch
      eza
      bat
      #fd
      #ripgrep
      fzf
      zoxide
      delta
      lazygit
      yazi
      bottom
      dust
      tokei
      procs

      # Wayland / Hyprland ecosystem
      awww             # animated wallpaper daemon (renamed from swww)
      wofi-power-menu  # power menu for waybar
      grimblast
      slurp
      wf-recorder
      hyprpicker

      # GTK / theming
      nwg-look

      # Applications
      zed-editor
      inputs.zen-browser.packages.${pkgs.system}.default
      pavucontrol
      blueman
      kdePackages.okular

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

  # ── Stylix ────────────────────────────────────────────────────────────────
  stylix.targets.gtk.enable      = false;
  # stylix.targets.cursor.enable = false;
  stylix.targets.hyprland.enable = false;

  # ── GTK theming ───────────────────────────────────────────────────────────
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
    gtk4.theme = config.gtk.theme;
  };

  # ── Qt ────────────────────────────────────────────────────────────────────
  qt = {
    enable             = true;
    platformTheme.name = lib.mkForce "gtk3";
  };

  # ── XDG ───────────────────────────────────────────────────────────────────
  xdg = {
    enable = true;
    userDirs = {
      enable              = true;
      createDirectories   = true;
      setSessionVariables = true;
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
        "text/html"              = "zen.desktop";
        "x-scheme-handler/http"  = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "image/jpeg"             = "imv.desktop";
        "image/png"              = "imv.desktop";
        "video/mp4"              = "mpv.desktop";
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "application/pdf"        = "okular.desktop";
        "application/x-pdf"      = "okular.desktop";
      };
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Ziad Ali";
        email = "zalshemy9@gmail.com";
      };
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
      "protocol \"ipv4\"".allow               = "always";
      "url \"https://github.com/\"".insteadOf = "git://github.com/";
    };
  };

  # ── SSH ───────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable                = true;
    enableDefaultConfig   = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        Hostname     = "github.com";
        User         = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # ── Services ──────────────────────────────────────────────────────────────
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

    cliphist.enable = true;

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
            timeout    = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume  = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  # ── Wofi launcher ─────────────────────────────────────────────────────────
  programs.wofi = {
    enable = true;
    settings = {
      width        = 600;
      height       = 400;
      show         = "drun";
      insensitive  = true;
      prompt       = "Search...";
      allow_markup = true;
      allow_images = true;
    };
  };

  fonts.fontconfig.enable  = true;
  programs.home-manager.enable = true;
}

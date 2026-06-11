# Hyprland window manager configuration
# Hardware: ASUS TUF Gaming A15 | 1920x1080 @ 144Hz | AMD iGPU + NVIDIA dGPU

{ config, pkgs, inputs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    # Setting both to null defers to the packages declared in programs.hyprland
    # (configuration.nix), preventing version mismatches between the NixOS module
    # and the Home Manager module.
    package       = null;
    portalPackage = null;

    xwayland.enable = true;

    # Export all session variables to systemd/D-Bus so that user services
    # (hypridle, waybar, dunst) have a complete environment.
    systemd.variables = [ "--all" ];

    settings = {

      monitor = [
        "eDP-1,1920x1080@144,0x0,1"
        ",preferred,auto,1"
      ];

      env = [
        "LIBVA_DRIVER_NAME,radeonsi"
        "GBM_BACKEND,amdgpu"
        "__GLX_VENDOR_LIBRARY_NAME,mesa"
        "XCURSOR_THEME,Bibata-Modern-Amber"
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland,x11"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec-once = [
        "swww-daemon && swww img ~/.config/hypr/wallpaper.jpg --transition-type wipe"
        
        # waybar  — started by systemd via programs.waybar.systemd.enable
        # dunst   — started by systemd via services.dunst.enable
        # hypridle — started by systemd via services.hypridle.enable
        #            (do NOT also exec-once hypridle; that would run two instances)
        "nm-applet --indicator"
        "blueman-applet"
        # cliphist pipe — handled by services.cliphist.enable in zizo.nix
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "hyprctl setcursor Bibata-Modern-Amber 24"
      ];

      input = {
        kb_layout  = "us,ara";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity  = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click   = true;
          drag_lock      = true;
          scroll_factor  = 0.8;
        };
      };

      general = {
        gaps_in  = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border"   = "rgba(d79921ff) rgba(b57614ff) 45deg";
        "col.inactive_border" = "rgba(3c3836aa)";
        layout        = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled           = true;
          size              = 4;
          passes            = 2;
          new_optimizations = true;
          ignore_opacity    = true;
          xray              = false;
        };
        shadow = {
          enabled      = true;
          range        = 15;
          render_power = 3;
          color        = "rgba(00000080)";
        };
        inactive_opacity = 0.93;
        active_opacity   = 1.0;
      };

      animations = {
        enabled = true;
        bezier = [
          "smooth,   0.05, 0.9,  0.1,  1.05"
          "snappy,   0.25, 1,    0.5,  1"
          "overshot, 0.13, 0.99, 0.29, 1.1"
          "linear,   0,    0,    1,    1"
        ];
        animation = [
          "windows,          1, 5,  smooth,  slide"
          "windowsOut,       1, 4,  snappy,  popin 80%"
          "windowsMove,      1, 4,  smooth"
          "border,           1, 10, default"
          "borderangle,      1, 8,  linear,  loop"
          "fade,             1, 7,  default"
          "workspaces,       1, 5,  overshot, slide"
          "specialWorkspace, 1, 6,  smooth,  slidevert"
        ];
      };

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
        smart_split    = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe          = true;
        workspace_swipe_fingers  = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_cancel_ratio = 0.2;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
        animate_manual_resizes  = true;
        enable_swallow          = true;
        swallow_regex           = "^(ghostty|foot)$";
        vfr                     = true;
      };

      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(imv)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(nwg-look)$"

        "center, class:^(pavucontrol)$"
        "center, class:^(blueman-manager)$"

        "size 700 500, class:^(pavucontrol)$"

        "opacity 0.9 0.85, class:^(Thunar)$"

        "workspace 1, class:^(com.mitchellh.ghostty)$"
        # zen-browser flake exposes the binary/WM_CLASS as "zen"
        "workspace 2, class:^(zen)$"
        "workspace 3, class:^(zeditor)$"
        "workspace 3, class:^(nvim)$"
        "workspace 4, class:^(obsidian)$"
        "workspace 5, class:^(thunar)$"
        "workspace 9, class:^(steam)$"
        "workspace 9, class:^(gamescope)$"
      ];

      layerrule = [
      "blur,       waybar"
      "ignorezero, waybar"
      "blur,       wofi"
      "ignorezero, wofi"
      "blur,       dunst"
      "ignorezero, dunst"
    ];
      "$mod"      = "SUPER";
      "$terminal" = "ghostty";
      # zen-browser flake installs the binary as "zen"; verify with:
      # ls $(nix build inputs#zen-browser...)/bin/
      "$browser"  = "zen";
      "$editor"   = "zeditor";
      "$launcher" = "wofi --show drun";
      "$files"    = "thunar";

      bind = [
        "$mod, Return,    exec, $terminal"
        "$mod, B,         exec, $browser"
        "$mod, E,         exec, $editor"
        "$mod, F,         exec, $files"
        "$mod, Space,     exec, $launcher"
        "$mod SHIFT, C,   killactive,"
        "$mod SHIFT, M,   exit,"
        "$mod, V,         exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        "$mod, T,         togglefloating,"
        "$mod, P,         pseudo,"
        "$mod, o,         togglesplit,"
        "$mod, F11,       fullscreen, 0"
        "$mod SHIFT, F,   fullscreen, 1"

        "$mod, H,         movefocus, l"
        "$mod, L,         movefocus, r"
        "$mod, K,         movefocus, u"
        "$mod, J,         movefocus, d"

        "$mod SHIFT, H,   movewindow, l"
        "$mod SHIFT, L,   movewindow, r"
        "$mod SHIFT, K,   movewindow, u"
        "$mod SHIFT, J,   movewindow, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, S,         togglespecialworkspace, magic"
        "$mod SHIFT, S,   movetoworkspace, special:magic"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"

        ",      Print,   exec, grimblast copy area"
        "SHIFT, Print,   exec, grimblast copy output"
        "$mod,  Print,   exec, grimblast save area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"

        "$mod, Backspace, exec, hyprlock"
        "$mod, C,         exec, hyprpicker -a"
        "$mod SHIFT, W,   exec, swww img $(find ~/Pictures/Wallpapers -type f | shuf -n1) --transition-type wipe"
      ];

      binde = [
        "$mod ALT, H, resizeactive, -30 0"
        "$mod ALT, L, resizeactive,  30 0"
        "$mod ALT, K, resizeactive,  0 -30"
        "$mod ALT, J, resizeactive,  0  30"

        ", XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute,      exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      bind = , XF86Launch1, exec, rog-control-center
      bind = , XF86Launch3, exec, asusctl led-mode -n
      bind = $mod SHIFT, G, exec, nvidia-offload ghostty
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = lib.mkForce [{
        monitor     = "";
        path        = "~/.config/hypr/wallpaper.jpg";
        blur_size   = 7;
        blur_passes = 3;
        brightness  = 0.6;
      }];
      input-field = lib.mkForce [{
        monitor           = "";
        size              = "250, 50";
        outline_thickness = 2;
        outer_color       = "rgb(d79921)";
        inner_color       = "rgb(1d2021)";
        font_color        = "rgb(ebdbb2)";
        placeholder_text  = "<i>Password...</i>";
        position          = "0, -100";
        halign            = "center";
        valign            = "center";
      }];
      label = [{
        monitor     = "";
        text        = "$TIME";
        color       = "rgba(235, 219, 178, 1.0)";
        font_size   = 64;
        font_family = "JetBrainsMono Nerd Font";
        position    = "0, 100";
        halign      = "center";
        valign      = "center";
      }];
    };
  };
}

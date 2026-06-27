# Hyprland window manager configuration
# Hardware: ASUS TUF Gaming A15 | 1920x1080 @ 144Hz | AMD iGPU + NVIDIA dGPU

{ config, pkgs, inputs, lib, ... }:

let
  colors = import ../colorScheme.nix;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    #  configType = "lua";

    configType = "hyprlang";

    extraConfig = ''
      # Legacy source stub. Main config is handled standalone in hyprland.lua below.
    '';
    # Setting both to null defers to the packages declared in programs.hyprland
    package       = null;
    portalPackage = null;

    xwayland.enable = true;

    # Export all session variables to systemd/D-Bus
    systemd.variables = [ "--all" ];
  };

  # ── hyprland.lua ────────────────────────────────────────────────────────
  # Written directly as text — bypasses the broken HM attrset translator.
  home.file.".config/hypr/hyprland.lua".text = ''
    -- ═══════════════════════════════════════════════════════════════════
    -- Hyprland config (Lua) — generated from nixos-config
    -- ═══════════════════════════════════════════════════════════════════

    local mainMod   = "SUPER"
    local terminal  = "ghostty"
    local browser   = "zen"             
    local editor    = "zeditor"
    local launcher  = "wofi --show drun"
    local files     = "nautilus"

    -- ── Monitors ──────────────────────────────────────────────────────────
    hl.config({
      monitor = {
        { name = "eDP-1", resolution = "1920x1080@144", position = "0x0", scale = 1 },
        { name = "",      resolution = "preferred",     position = "auto", scale = 1 },
      },
    })

    -- ── Environment variables ───────────────────────────────────────────
    hl.env("LIBVA_DRIVER_NAME", "radeonsi")
    hl.env("GBM_BACKEND", "amdgpu")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
    hl.env("XCURSOR_THEME", "Bibata-Modern-Amber")
    hl.env("XCURSOR_SIZE", "24")
    hl.env("QT_QPA_PLATFORM", "wayland")
    hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
    hl.env("GDK_BACKEND", "wayland,x11")
    hl.env("SDL_VIDEODRIVER", "wayland")
    hl.env("MOZ_ENABLE_WAYLAND", "1")
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")

    -- ── Autostart ─────────────────────────────────────────────────────────
    hl.on("hyprland.start", function()
      hl.exec_cmd("swww-daemon && swww img ~/.config/hypr/wallpaper.jpg --transition-type wipe")
      hl.exec_cmd("nm-applet --indicator")
      hl.exec_cmd("blueman-applet")
      hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
      hl.exec_cmd("hyprctl setcursor Bibata-Modern-Amber 24")
    end)

    -- ── Input ─────────────────────────────────────────────────────────────
    hl.config({
      input = {
        kb_layout    = "us,ara",
        kb_options   = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
          natural_scroll = true,
          tap_to_click   = true,
          drag_lock      = true,
          scroll_factor  = 0.8,
        },
      },
    })

    -- ── General ───────────────────────────────────────────────────────────
    hl.config({
      general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,
        ["col.active_border"]   = "rgba(${colors.yellow}ff) rgba(${colors.orange}ff) 45deg",
        ["col.inactive_border"] = "rgba(${colors.bg1}aa)",
        layout        = "dwindle",
        allow_tearing = false,
      },
    })

    -- ── Decoration ────────────────────────────────────────────────────────
    hl.config({
      decoration = {
        rounding = 8,
        blur = {
          enabled           = true,
          size              = 4,
          passes            = 2,
          ignore_opacity    = true,
          xray              = false,
        },
        shadow = {
          enabled      = true,
          range        = 15,
          render_power = 3,
          color        = "rgba(${colors.bg0_hard}80)",
        },
        inactive_opacity = 0.93,
        active_opacity   = 1.0,
      },
    })

    -- ── Animations ────────────────────────────────────────────────────────
    hl.config({
      animations = {
        enabled = true,
        bezier = {
          { "smooth",   0.05, 0.9,  0.1,  1.05 },
          { "snappy",   0.25, 1,    0.5,  1    },
          { "overshot", 0.13, 0.99, 0.29, 1.1  },
          { "linear",   0,    0,    1,    1    },
        },
        animation = {
          { "windows",          true, 5,  "smooth"   },
          { "windowsOut",       true, 4,  "snappy"   },
          { "windowsMove",      true, 4,  "smooth"   },
          { "border",           true, 10, "default"  },
          { "borderangle",      true, 8,  "linear"   },
          { "fade",             true, 7,  "default"  },
          { "workspaces",       true, 5,  "overshot" },
          { "specialWorkspace", true, 6,  "smooth"   },
        },
      },
    })

    -- ── Layout: dwindle ───────────────────────────────────────────────────
    hl.config({
      dwindle = {
        pseudotile     = true,
        preserve_split = true,
        smart_split    = true,
      },
      master = {
        new_status = "master",
      },
    })

    -- ── Gestures ──────────────────────────────────────────────────────────
    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

    -- ── Misc ──────────────────────────────────────────────────────────────
    hl.config({
      misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        animate_manual_resizes  = true,
        enable_swallow          = true,
        swallow_regex           = "^(ghostty|foot)$",
        vfr                     = true,
      },
    })

    -- ── Window rules ──────────────────────────────────────────────────────
    hl.windowrule({ "float",  class = "^(pavucontrol)$" })
    hl.windowrule({ "float",  class = "^(blueman-manager)$" })
    hl.windowrule({ "float",  class = "^(nm-connection-editor)$" })
    hl.windowrule({ "float",  class = "^(imv)$" })
    hl.windowrule({ "float",  title = "^(Picture-in-Picture)$" })
    hl.windowrule({ "float",  class = "^(nwg-look)$" })

    hl.windowrule({ "center", class = "^(pavucontrol)$" })
    hl.windowrule({ "center", class = "^(blueman-manager)$" })

    hl.windowrule({ "size 700 500", class = "^(pavucontrol)$" })
    hl.windowrule({ "opacity 0.9 0.85", class = "^(org.gnome.Nautilus)$" })

    hl.windowrule({ "workspace 1", class = "^(com.mitchellh.ghostty)$" })
    hl.windowrule({ "workspace 2", class = "^(zen)$" })
    hl.windowrule({ "workspace 3", class = "^(zeditor)$" })
    hl.windowrule({ "workspace 3", class = "^(nvim)$" })
    hl.windowrule({ "workspace 4", class = "^(obsidian)$" })
    hl.windowrule({ "workspace 5", class = "^(org.gnome.Nautilus)$" })
    hl.windowrule({ "workspace 9", class = "^(steam)$" })
    hl.windowrule({ "workspace 9", class = "^(gamescope)$" })

    -- ── Layer rules ───────────────────────────────────────────────────────
    hl.layerrule({ "blur",       "waybar" })
    hl.layerrule({ "ignorezero", "waybar" })
    hl.layerrule({ "blur",       "wofi" })
    hl.layerrule({ "ignorezero", "wofi" })
    hl.layerrule({ "blur",       "dunst" })
    hl.layerrule({ "ignorezero", "dunst" })

    -- ── Binds: apps & session ─────────────────────────────────────────────
    hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))
    hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(editor))
    hl.bind(mainMod .. " + F",      hl.dsp.exec_cmd(files))
    hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(launcher))
    hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill_active())
    hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
    hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

    -- ── Binds: window state ───────────────────────────────────────────────
    hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
    hl.bind(mainMod .. " + O", hl.dsp.window.toggle_split())
    hl.bind(mainMod .. " + F11",       hl.dsp.window.fullscreen({ mode = 0 }))
    hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 1 }))

    -- ── Binds: focus (vim keys + arrows) ──────────────────────────────────
    for _, pair in ipairs({ { "H", "l" }, { "L", "r" }, { "K", "u" }, { "J", "d" },
                             { "left", "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" } }) do
      hl.bind(mainMod .. " + " .. pair[1], hl.dsp.window.move_focus(pair[2]))
    end

    -- ── Binds: move window (vim keys + arrows) ────────────────────────────
    for _, pair in ipairs({ { "H", "l" }, { "L", "r" }, { "K", "u" }, { "J", "d" },
                             { "left", "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" } }) do
      hl.bind(mainMod .. " + SHIFT + " .. pair[1], hl.dsp.window.move(pair[2]))
    end

    -- ── Binds: workspaces 1-10 ─────────────────────────────────────────────
    for i = 1, 9 do
      hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.workspace.go(tostring(i)))
      hl.bind(mainMod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move_to_workspace(tostring(i)))
    end
    hl.bind(mainMod .. " + 0", hl.dsp.workspace.go("10"))
    hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move_to_workspace("10"))

    -- ── Binds: special workspace ───────────────────────────────────────────
    hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move_to_workspace("special:magic"))

    -- ── Binds: workspace scroll ────────────────────────────────────────────
    hl.bind(mainMod .. " + mouse_down", hl.dsp.workspace.go("e+1"))
    hl.bind(mainMod .. " + mouse_up",   hl.dsp.workspace.go("e-1"))

    -- ── Binds: screenshots ─────────────────────────────────────────────────
    hl.bind("Print",         hl.dsp.exec_cmd("grimblast copy area"))
    hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grimblast copy output"))
    hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(
      "grimblast save area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
    ))

    -- ── Binds: misc utilities ──────────────────────────────────────────────
    hl.bind(mainMod .. " + Backspace", hl.dsp.exec_cmd("hyprlock"))
    hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd("hyprpicker -a"))
    hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(
      "swww img $(find ~/Pictures/Wallpapers -type f | shuf -n1) --transition-type wipe"
    ))

    -- ── Binds: repeatable resize ───────────────────────────────────────────
    for _, pair in ipairs({ { "H", "-30 0" }, { "L", "30 0" }, { "K", "0 -30" }, { "J", "0 30" },
                             { "left", "-30 0" }, { "right", "30 0" }, { "up", "0 -30" }, { "down", "0 30" } }) do
      hl.binde(mainMod .. " + ALT + " .. pair[1], hl.dsp.window.resize_active(pair[2]))
    end

    -- ── Binds: media keys ──────────────────────────────────────────────────
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
    hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"))
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

    -- ── Binds: ASUS-specific & NVIDIA offload ─────────────────────────────
    hl.bind("XF86Launch1", hl.dsp.exec_cmd("rog-control-center"))
    hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl led-mode -n"))
    hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("nvidia-offload ghostty"))

    -- ── Mouse binds ────────────────────────────────────────────────────────
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.move_active())
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize_active())
  '';

  # ── hyprlock ──────────────────────────────────────────────────────────
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
        outer_color       = "rgb(${colors.yellow})";
        inner_color       = "rgb(${colors.bg0_hard})";
        font_color        = "rgb(${colors.fg})";
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

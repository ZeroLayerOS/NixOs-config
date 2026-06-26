# Waybar status bar configuration
# Theme: Gruvbox Dark Hard

{ config, pkgs, lib, ... }:

let
  colors = import ../colorScheme.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      # Ensure waybar only starts after the Hyprland session is fully active,
      # preventing a race condition on login.
      targets = [ "hyprland-session.target" ];
    };

    settings = [{
      layer         = "top";
      position      = "top";
      height        = 36;
      margin-top    = 6;
      margin-left   = 10;
      margin-right  = 10;
      spacing       = 4;

      modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [
        "pulseaudio"
        "bluetooth"
        "network"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "tray"
        "custom/power"
      ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs    = true;
        active-only    = false;
        on-click       = "activate";
        format         = "{icon}";
        format-icons = {
          "1" = "󰆍";
          "2" = "󰈹";
          "3" = "󰘦";
          "4" = "󱓧";
          "5" = "󰉋";
          "6" = "󰎄";
          "9" = "󰊴";
          "urgent"  = "󰀧";
          "focused" = "󰮯";
          "default" = "󰊠";
        };
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
        };
      };

      "hyprland/window" = {
        max-length       = 50;
        separate-outputs = true;
        format           = "  {}";
      };

      clock = {
        format     = "  {:%H:%M}";
        format-alt = "  {:%A, %B %d, %Y}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        calendar = {
          mode         = "year";
          mode-mon-col = 3;
          weeks-pos    = "right";
          on-scroll    = 1;
          # Calendar colours come from colorScheme.nix
          format = {
            months   = "<span color='#${colors.yellow}'><b>{}</b></span>";
            days     = "<span color='#${colors.fg}'>{}</span>";
            weeks    = "<span color='#${colors.cyan}'><b>W{}</b></span>";
            weekdays = "<span color='#${colors.bright_green}'><b>{}</b></span>";
            today    = "<span color='#${colors.bright_red}'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up   = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      cpu = {
        format   = "  {usage}%";
        tooltip  = true;
        interval = 2;
        on-click = "ghostty -e btop";
      };

      memory = {
        format         = "  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        interval       = 3;
        on-click       = "ghostty -e btop";
      };

      temperature = {
        # thermal-zone 0 = CPU on Ryzen 7535HS; more stable than hwmon-path
        # which can change index between reboots.
        thermal-zone       = 0;
        critical-threshold = 80;
        format             = " {temperatureC}°C";
        format-critical    = " {temperatureC}°C";
        tooltip            = false;
      };

      battery = {
        states = {
          good     = 95;
          warning  = 30;
          critical = 15;
        };
        format          = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged  = "󰚥 {capacity}%";
        format-alt      = "{icon} {time}";
        format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format  = "{timeTo} | {power:.1f}W";
      };

      network = {
        format-wifi         = "󰤨  {essid}";
        format-ethernet     = "󰈀  {ipaddr}";
        format-disconnected = "󰤭  Offline";
        format-alt          = "󰤨  {bandwidthUpBytes}  {bandwidthDownBytes}";
        tooltip-format-wifi = "{essid} ({signalStrength}%) | {frequency}MHz\n{ifname} — {ipaddr}";
        on-click            = "nm-connection-editor";
        on-click-right      = "nm-applet";
        interval            = 5;
      };

      bluetooth = {
        format           = "󰂯";
        format-connected = "󰂱 {device_alias}";
        format-disabled  = "󰂲";
        tooltip-format   = "{controller_alias}\n{num_connections} connected";
        on-click         = "blueman-manager";
      };

      pulseaudio = {
        format           = "{icon} {volume}%";
        format-muted     = "󰝟 Muted";
        format-bluetooth = "󰂯 {volume}%";
        format-icons = {
          headphone = "󰋋";
          headset   = "󰋎";
          speaker   = "󰓃";
          default   = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click       = "pavucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step    = 5;
      };

      tray = {
        icon-size          = 16;
        spacing            = 8;
        show-passive-items = true;
      };

      "custom/power" = {
        format   = "󰐥";
        tooltip  = false;
        on-click = "wofi-power-menu";
      };
    }];

    # All colours below come from colorScheme.nix — edit colours there, not here.
    style = ''
      @define-color bg-hard  #${colors.bg0_hard};
      @define-color bg       #${colors.bg0};
      @define-color bg1      #${colors.bg1};
      @define-color bg2      #${colors.bg2};
      @define-color fg       #${colors.fg};
      @define-color fg2      #${colors.fg2};
      @define-color yellow   #${colors.yellow};
      @define-color orange   #${colors.orange};
      @define-color red      #${colors.red};
      @define-color green    #${colors.green};
      @define-color aqua     #${colors.cyan};
      @define-color blue     #${colors.blue};
      @define-color purple   #${colors.magenta};

      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: alpha(@bg-hard, 0.92);
        border-radius: 10px;
        border: 1px solid @bg2;
        color: @fg;
        transition: all 0.3s ease;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 2px 8px;
        color: @fg2;
        background: transparent;
        border-radius: 6px;
        margin: 4px 2px;
        transition: all 0.2s ease;
        border: none;
      }

      #workspaces button:hover {
        background: @bg1;
        color: @yellow;
      }

      #workspaces button.active {
        background: @yellow;
        color: @bg-hard;
        font-weight: bold;
        padding: 2px 12px;
      }

      #workspaces button.urgent {
        background: @red;
        color: @bg-hard;
      }

      #workspaces button.empty { color: @bg2; }

      #window {
        color: @fg2;
        font-style: italic;
        padding: 0 8px;
      }

      #clock {
        color: @yellow;
        font-weight: bold;
        font-size: 14px;
        padding: 0 12px;
      }

      #cpu, #memory, #temperature, #battery,
      #network, #bluetooth, #pulseaudio, #tray,
      #custom-power {
        padding: 2px 10px;
        margin: 4px 2px;
        border-radius: 6px;
        background: @bg1;
        color: @fg;
        transition: background 0.2s ease;
      }

      #cpu         { color: @green;  }
      #memory      { color: @blue;   }
      #temperature { color: @orange; }
      #battery     { color: @aqua;   }
      #network     { color: @blue;   }
      #bluetooth   { color: @blue;   }
      #pulseaudio  { color: @yellow; }

      #battery.charging { color: @green;  }
      #battery.warning  { color: @orange; }
      #battery.critical { color: @red; animation: blink 1s infinite; }

      #temperature.critical { color: @red; }

      #tray { background: transparent; }

      #custom-power {
        color: @red;
        font-size: 15px;
        padding: 2px 12px;
      }

      #custom-power:hover { background: @red; color: @bg-hard; }

      #cpu:hover, #memory:hover, #battery:hover,
      #network:hover, #pulseaudio:hover {
        background: @bg2;
      }

      @keyframes blink {
        to { background: @red; color: @bg-hard; }
      }

      tooltip {
        background: @bg-hard;
        border: 1px solid @yellow;
        border-radius: 8px;
        color: @fg;
      }
    '';
  };
}

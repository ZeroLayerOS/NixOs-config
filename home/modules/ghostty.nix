# Ghostty terminal emulator configuration
# Theme: Gruvbox Dark Hard | GPU-accelerated | native Wayland

{ config, pkgs, lib, ... }:

let
  colors = import ../colorScheme.nix;
in
{
  programs.ghostty = {
    enable               = true;
    package              = pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      # ── Font ──────────────────────────────────────────────────────────────
      font-family = "JetBrainsMono Nerd Font";
      font-size   = 13;

      # ── Theme ─────────────────────────────────────────────────────────────
      # "GruvboxDark" below refers to the custom theme defined in
      # themes.GruvboxDark (Hard variant), not Ghostty's built-in soft one.
      theme              = "GruvboxDark";
      background-opacity = 0.92;
      background-blur    = true;

      # ── Window ────────────────────────────────────────────────────────────
      window-decoration = false;
      window-padding-x  = 12;
      window-padding-y  = 10;

      # ── Cursor ────────────────────────────────────────────────────────────
      cursor-style       = "bar";
      cursor-style-blink = true;

      # ── Scrollback ────────────────────────────────────────────────────────
      scrollback-limit = 10000;

      # ── Shell integration ─────────────────────────────────────────────────
      shell-integration          = "zsh";
      shell-integration-features = "cursor,sudo,title";

      # ── Misc ──────────────────────────────────────────────────────────────
      mouse-hide-while-typing = true;
      copy-on-select          = false;
      confirm-close-surface   = false;

      # ── Keybindings ───────────────────────────────────────────────────────
      keybind = [
        # Tabs
        "ctrl+a>c=new_tab"
        "ctrl+a>n=next_tab"
        "ctrl+a>p=previous_tab"
        "ctrl+a>w=close_surface"

        # Splits
        "ctrl+a>shift+percent=new_split:right"
        "ctrl+a>shift+quotedbl=new_split:down"

        # Pane navigation (vim keys)
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
        "ctrl+k=goto_split:top"
        "ctrl+j=goto_split:bottom"

        # Zoom / fullscreen
        "ctrl+a>z=toggle_split_zoom"

        # Quick tab switch
        "alt+1=goto_tab:1"
        "alt+2=goto_tab:2"
        "alt+3=goto_tab:3"
        "alt+4=goto_tab:4"

        # Font size
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"

        # Clipboard
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        # Reload config
        "ctrl+a>r=reload_config"
      ];
    };

    # ── Custom Gruvbox Dark Hard colour theme ────────────────────────────────
    # Ghostty's built-in "GruvboxDark" is the *soft* variant.
    # Values come from colorScheme.nix — edit colours there, not here.
    themes.GruvboxDark = {
      background           = colors.bg0_hard;
      foreground            = colors.fg;
      cursor-color          = colors.cursor;
      selection-background  = colors.selection_bg;
      selection-foreground  = colors.selection_fg;

      palette = [
        "0=#${colors.bg0}"             # black
        "1=#${colors.red}"             # red
        "2=#${colors.green}"           # green
        "3=#${colors.yellow}"          # yellow
        "4=#${colors.blue}"            # blue
        "5=#${colors.magenta}"         # magenta
        "6=#${colors.cyan}"            # cyan
        "7=#${colors.fg4}"             # white
        "8=#${colors.bg4}"             # bright black
        "9=#${colors.bright_red}"      # bright red
        "10=#${colors.bright_green}"   # bright green
        "11=#${colors.bright_yellow}"  # bright yellow
        "12=#${colors.bright_blue}"    # bright blue
        "13=#${colors.bright_magenta}" # bright magenta
        "14=#${colors.bright_cyan}"    # bright cyan
        "15=#${colors.fg}"             # bright white
      ];
    };
  };
}

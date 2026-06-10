# Ghostty terminal emulator configuration
# Theme: Gruvbox Dark Hard | GPU-accelerated | native Wayland

{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable  = true;
    package = pkgs.ghostty;

    # Zsh shell integration — provides prompt marks, working directory tracking,
    # and cursor shape changes on command execution.
    enableZshIntegration = true;

    settings = {
      # Font
      font-family = "JetBrainsMono Nerd Font";
      font-size   = 13;

      # Gruvbox Dark Hard palette
      # background / foreground are set via the theme block below
      theme               = "GruvboxDark";
      background-opacity  = 0.92;
      background-blur     = true;

      # Window
      window-decoration = false;
      window-padding-x  = 12;
      window-padding-y  = 10;

      # Cursor
      cursor-style          = "bar";
      cursor-style-blink    = true;

      # Scrollback
      scrollback-limit = 10000;

      # Shell
      shell-integration       = "zsh";
      shell-integration-features = "cursor,sudo,title";

      # Misc
      mouse-hide-while-typing = true;
      copy-on-select          = false;
      confirm-close-surface   = false;
    };

    # Custom Gruvbox Dark Hard colour theme.
    # Ghostty's built-in "GruvboxDark" uses the soft variant;
    # this override matches the Hard variant used everywhere else.
    themes.GruvboxDark = {
      background         = "1d2021";
      foreground         = "ebdbb2";
      cursor-color       = "d79921";
      selection-background = "504945";
      selection-foreground = "ebdbb2";

      palette = [
        "0=#282828"   # black
        "1=#cc241d"   # red
        "2=#98971a"   # green
        "3=#d79921"   # yellow
        "4=#458588"   # blue
        "5=#b16286"   # magenta
        "6=#689d6a"   # cyan
        "7=#a89984"   # white
        "8=#928374"   # bright black
        "9=#fb4934"   # bright red
        "10=#b8bb26"  # bright green
        "11=#fabd2f"  # bright yellow
        "12=#83a598"  # bright blue
        "13=#d3869b"  # bright magenta
        "14=#8ec07c"  # bright cyan
        "15=#ebdbb2"  # bright white
      ];
    };

    # Keybindings — CTRL-A leader to mirror the WezTerm/tmux layout.
    # Navigation uses vim keys; splits use leader+direction.
    settings.keybind = [
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
}

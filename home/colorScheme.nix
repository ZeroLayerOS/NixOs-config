# Gruvbox Dark Hard — single source of truth for all colours.
# Import this file wherever you need palette values:
#
#   let colors = import ./colorScheme.nix; in ...
#
# Every hex value is bare (no leading #) so it works directly in:
#   - Ghostty themes   (background = colors.bg0_hard)
#   - Hyprland         ("col.active_border" = "rgba(${colors.yellow}ff)")
#   - Waybar CSS       (@define-color yellow #${colors.yellow};)
#   - Dunst, hyprlock, anywhere else a hex string is needed

{
  # ── Backgrounds ───────────────────────────────────────────────────────────
  bg0_hard = "1d2021";   # darkest  — terminal / bar background
  bg0      = "282828";   # dark     — base background
  bg1      = "3c3836";   # statusline / inactive border
  bg2      = "504945";   # selection / visual
  bg3      = "665c54";   # dividers
  bg4      = "7c6f64";   # comments (dark)

  # ── Foregrounds ───────────────────────────────────────────────────────────
  fg0      = "fbf1c7";   # lightest
  fg       = "ebdbb2";   # base foreground
  fg2      = "d5c4a1";   # dimmed
  fg3      = "bdae93";   # more dimmed
  fg4      = "a89984";   # subtle

  # ── Normal colours ────────────────────────────────────────────────────────
  red      = "cc241d";
  green    = "98971a";
  yellow   = "d79921";
  blue     = "458588";
  magenta  = "b16286";
  cyan     = "689d6a";
  orange   = "d65d0e";

  # ── Bright colours ────────────────────────────────────────────────────────
  bright_red     = "fb4934";
  bright_green   = "b8bb26";
  bright_yellow  = "fabd2f";
  bright_blue    = "83a598";
  bright_magenta = "d3869b";
  bright_cyan    = "8ec07c";

  # ── Cursor / selection ────────────────────────────────────────────────────
  cursor       = "d79921";   # same as yellow
  selection_bg = "504945";   # same as bg2
  selection_fg = "ebdbb2";   # same as fg
}

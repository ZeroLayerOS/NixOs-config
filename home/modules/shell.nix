# Shell environment — Zsh + Oh-My-Zsh + Powerlevel10k + modern CLI tools

{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable                   = true;
    enableCompletion         = true;
    autosuggestion.enable    = true;
    syntaxHighlighting.enable = true;
    dotDir                   = ".config/zsh";

    history = {
      size        = 50000;
      save        = 50000;
      path        = "${config.xdg.dataHome}/zsh/history";
      extended    = true;
      ignoreDups  = true;
      ignoreSpace = true;
      share       = true;
    };

    oh-my-zsh = {
      enable  = true;
     # theme   = "powerlevel10k/powerlevel10k";
      plugins = [
        "git"
        "sudo"
        "docker"
        "rust"
        "python"
        "colored-man-pages"
        "command-not-found"
    #    "z"
        "fzf"
        "extract"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src  = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src  = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src  = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    sessionVariables = {
      EDITOR   = "nvim";
      VISUAL   = "nvim";
      PAGER    = "bat";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      # TERM is intentionally unset here; Ghostty sets it to "xterm-ghostty" automatically.
      # Forcing a value breaks SSH sessions on remote hosts that lack the ghostty terminfo entry.

      CARGO_HOME  = "${config.home.homeDirectory}/.cargo";
      RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";

      # FZF — Gruvbox colour scheme
      FZF_DEFAULT_OPTS = ''
        --color=bg+:#3c3836,bg:#1d2021,spinner:#d79921,hl:#fb4934
        --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#d79921
        --color=marker:#d79921,fg+:#ebdbb2,prompt:#d79921,hl+:#fb4934
        --layout=reverse --border=rounded --height=40%
        --preview-window=border-rounded
      '';

      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
      FZF_CTRL_T_COMMAND  = "$FZF_DEFAULT_COMMAND";
      FZF_ALT_C_COMMAND   = "fd --type d --hidden --follow --exclude .git";

      BAT_THEME = "gruvbox-dark";
      _ZO_ECHO  = "1";
    };

    shellAliases = {
      # Directory navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";
      "~"    = "cd ~";

      # ls → eza
      ls  = "eza --icons --group-directories-first";
      ll  = "eza -lh --icons --group-directories-first --git";
      la  = "eza -lah --icons --group-directories-first --git";
      lt  = "eza --tree --icons --level=2";
      lta = "eza --tree --icons --level=3 -a";

      # cat → bat
      cat  = "bat";
      catp = "bat -p";

      # grep → ripgrep
      grep = "rg";

      # find → fd
      find = "fd";

      # cd → zoxide
      #cd = "z";
      j = "z";

      # Git shortcuts
      g    = "git";
      gs   = "git status";
      ga   = "git add";
      gaa  = "git add .";
      gc   = "git commit -m";
      gca  = "git commit --amend";
      gp   = "git push";
      gpl  = "git pull";
      gco  = "git checkout";
      gcb  = "git checkout -b";
      glog = "git log --oneline --graph --decorate";
      lg   = "lazygit";

      # Editor
      v   = "nvim";
      vi  = "nvim";
      vim = "nvim";

      # NixOS rebuild helpers
      #rebuild          = "sudo nixos-rebuild switch --flake ~/dotfiles#zizo";
      #rebuild-test     = "sudo nixos-rebuild test   --flake ~/dotfiles#zizo";
      #rebuild-boot     = "sudo nixos-rebuild boot   --flake ~/dotfiles#zizo";
      #nix-update       = "nix flake update ~/dotfiles";
      rebuild      = "sudo nixos-rebuild switch --flake ~/nixos-config#zizo";
      rebuild-test = "sudo nixos-rebuild test   --flake ~/nixos-config#zizo";
      rebuild-boot = "sudo nixos-rebuild boot   --flake ~/nixos-config#zizo";
      nix-update   = "nix flake update ~/nixos-config";
      nix-clean        = "sudo nix-collect-garbage -d";
      nix-generations  = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

      # System utilities
      df  = "df -h";
      du  = "dust";
      ps  = "procs";
      top = "btop";
      free = "free -h";

      # GPU — NVIDIA PRIME offload
      nvidia-run = "nvidia-offload";

      # PostgreSQL helpers
      pg-start   = "sudo systemctl start postgresql";
      pg-stop    = "sudo systemctl stop postgresql";
      pg-status  = "sudo systemctl status postgresql";
      pg-log     = "sudo journalctl -u postgresql -f";
      pg         = "pgcli -U ziad";
      pg-gradeiq = "pgcli -U ziad -d gradeiq";
      pg-dev     = "pgcli -U ziad -d dev";

      # Wayland clipboard
      copy  = "wl-copy";
      paste = "wl-paste";

      # Quick config access
     # zshrc    = "nvim ~/dotfiles/home/ziad/modules/shell.nix";
      #hyprconf = "nvim ~/dotfiles/home/ziad/modules/hyprland.nix";
      zshrc    = "nvim ~/nixos-config/home/modules/shell.nix";
      hyprconf = "nvim ~/nixos-config/home/modules/hyprland.nix";
      #dotfiles = "cd ~/dotfiles && nvim .";
      dotfiles = "cd ~/nixos-config && nvim .";
      # Cargo shortcuts
      cr  = "cargo run";
      cb  = "cargo build";
      ct  = "cargo test";
      cc  = "cargo check";
      cf  = "cargo fmt";
      ccl = "cargo clippy";
    };

    initExtra = ''
      # Powerlevel10k instant prompt — must be sourced before anything else
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Show fastfetch only in the first shell level (avoid nested terminal spam)
      if [[ -z "$FASTFETCH_SHOWN" && $SHLVL -eq 1 ]]; then
        export FASTFETCH_SHOWN=1
        fastfetch
      fi

      # Powerlevel10k theme config
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # zoxide — smart cd
      eval "$(zoxide init zsh)"

      # fzf key bindings and completion
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # fzf-tab previews
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons --level=1 $realpath'
      zstyle ':fzf-tab:complete:*'    fzf-preview  'bat --style=numbers --color=always --line-range=:50 {} 2>/dev/null || eza --icons $realpath'

      # Completion settings
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Key bindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^R'   fzf-history-widget
      bindkey '^F'   fzf-file-widget

      # Drop into a temporary nix-shell with the given packages
      nix-shell-pkg() {
        nix-shell -p "$@" --run zsh
      }

      # Fuzzy-jump to a project directory
      proj() {
        local dir
        dir=$(find ~/projects -maxdepth 2 -type d | fzf --preview 'eza --tree --icons --level=2 {}')
        [[ -n "$dir" ]] && cd "$dir"
      }
    '';
  };

  programs.fastfetch = {
    enable   = true;
    settings = {
      logo = {
        source  = "nixos";
        color   = { "1" = "yellow"; "2" = "yellow"; };
        padding = { top = 1; left = 2; right = 1; };
      };
      display = {
        separator = "  ";
        color = {
          keys   = "yellow";
          title  = "yellow";
          output = "white";
        };
      };
      modules = [
        { type = "title"; format = "{user-name}@{host-name}"; color.output = "yellow"; }
        { type = "separator"; string = "─"; }
        { type = "os";       key = "  OS";       format = "{name} {version}"; }
        { type = "kernel";   key = "  Kernel"; }
        { type = "uptime";   key = "  Uptime"; }
        { type = "packages"; key = "  Packages"; }
        { type = "shell";    key = "  Shell"; }
        { type = "display";  key = "  Display"; }
        { type = "wm";       key = "  WM"; }
        { type = "terminal"; key = "  Terminal"; }
        { type = "cpu";      key = "  CPU"; format = "{name} ({cores-physical}C/{cores-logical}T)"; }
        { type = "gpu";      key = "  GPU"; format = "{name}"; }
        { type = "memory";   key = "  Memory"; format = "{used} / {total} ({percentage})"; }
        { type = "disk";     key = "  Disk"; folders = "/"; format = "{used} / {total} ({percentage})"; }
        { type = "battery";  key = "  Battery"; }
        { type = "separator"; string = "─"; }
        { type = "colors"; paddingLeft = 2; }
      ];
    };
  };

  programs.direnv = {
    enable               = true;
    nix-direnv.enable    = true;
    enableZshIntegration = true;
  };

  programs.btop = {
    enable   = true;
    settings = {
      color_theme      = lib.mkForce "gruvbox";
      theme_background = false;
      vim_keys         = true;
      rounded_corners  = true;
      update_ms        = 1000;
      proc_sorting     = "cpu lazy";
      proc_tree        = false;
    };
  };
}

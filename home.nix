{ config, pkgs, ... }:

{
  home.username = "leoz";
  home.homeDirectory = "/home/leoz";

  home.stateVersion = "26.05"; # Please read the comment before changing.

  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];

  home.packages = with pkgs; [
		# essential
    neovim
    lazygit
		yazi
		trash-cli
		pass

		# ai
		pi-coding-agent
		rtk

		# fetch
    fastfetch
    onefetch
    cmatrix

		# system
    ripgrep
    fd
    bat

    # desktop
    (rofi.override {
      plugins = [
        rofi-emoji
        rofi-calc
      ];
    })
    rofi-network-manager
    waybar
    dunst
    pavucontrol
    playerctl
    btop
    mpv
    qview
    t3code
    vesktop
    hyprshot
		hyprpicker
    wl-kbptr
    cliphist
    wl-clipboard
    grim
    slurp
    (tesseract.override {
      enableLanguages = [ "eng" ];
    })
    nerd-fonts.jetbrains-mono
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = builtins.readFile ./zsh/.zshrc;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "20";
  };

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 20;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Leo Zhou";
        email = "128760280+laoz40@users.noreply.github.com";
      };
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  home.file = {
    ".local/bin" = {
      source = ./shell-scripts/.local/bin;
      recursive = true;
    };
    ".bunfig.toml".source = ./node/.bunfig.toml;
    ".npmrc".source = ./node/.npmrc;
    ".config/pnpm/rc".source = ./node/.config/pnpm/rc;
    ".agents/skills" = {
      source = ./skills/.agents/skills;
      recursive = true;
    };
    "Pictures/Wallpapers" = {
      source = ./wallpapers/Pictures/Wallpapers;
      recursive = true;
    };
    ".pi/agent" = {
      source = ./pi/.pi/agent;
      recursive = true;
    };
    ".config/wl-kbptr/config".source = ./wl-kbptr/.config/wl-kbptr/config;
    ".config/lazygit/config.yml".source = ./lazygit/.config/lazygit/config.yml;
    ".config/herdr/config.toml".source = ./herdr/.config/herdr/config.toml;
    ".config/fastfetch" = {
      source = ./fastfetch/.config/fastfetch;
      recursive = true;
    };
    ".config/nvim" = {
      source = ./nvim/.config/nvim;
      recursive = true;
    };
    ".config/yazi" = {
      source = ./yazi/.config/yazi;
      recursive = true;
    };
    ".config/hypr" = {
      source = ./hypr/.config/hypr;
      recursive = true;
    };
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/ghostty/.config/ghostty";
    ".config/rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/rofi/.config/rofi";
    ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/waybar/.config/waybar";
    ".config/dunst/dunstrc".source = ./dunst/.config/dunst/dunstrc;
    ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=KvArcDark
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

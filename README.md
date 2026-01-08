# I use arch btw

Everything uses my custom blue and gold colorscheme, based off my keycaps.

## Stuff I use

Essential stuff:

- **Neovim**: `neovim`
- **tmux**: `tmux`
    - tmux-sessionizer
- **Ghostty**: `ghostty`
- **Lazygit**: `lazygit`
- **Yazi**: `yazi`
- **fzf**: `fzf`
- **Zen Browser**: `zen-browser-bin` (AUR)

`paru -S neovim tmux ghostty lazygit yazi fzf zen-browser-bin`

Linux stuff and other stuff:

- **hyprland**: `hyprland`
- **hyprpaper**: `hyprpaper`
- **hyprlock**: `hyprlock`
- **hypridle**: `hypridle`
- **hyprshot**: `hyprshot`
- **rofi**: `rofi`
- **waybar**: `waybar`
- **dunst**: `dunst`
- **fastfetch**: `fastfetch`
- **WezTerm** (for Windows)

`paru -S hyprland hyprpaper hyprlock hypridle hyprshot rofi waybar dunst fastfetch`

System stuff:

- **ly**: `ly`
- **Network Manager**: `networkmanager`
- **pavucontrol**: `pavucontrol`
- **blueman** (if bluetooth): `blueman`
- **mpris**: `playerctl`
- **btop**: `btop`
- **cliphist**: `cliphist`
- **TLP** (for laptop): `tlp`
- Timeshift and GRUB btrfs for backing up and restoring

`paru -S ly networkmanager pavucontrol playerctl btop cliphist`

Appearance stuff:

- **JetBrains Mono**: `ttf-jetbrains-mono`
- **Bibata cursor**: `bibata-cursor-theme-bin` (AUR)
- **Tela icons**: `tela-icon-theme` (AUR)
- **cmatrix**: `cmatrix`
- **batcat**: `bat`

`paru -S bibata-cursor-theme-bin tela-icon-theme ttf-jetbrains-mono cmatrix bat`

## Setup stuff:

ly Display Manager (Login screen):

```
sudo systemctl enable ly@tty1.service
systemctl disable getty@tty1.service
```

Networking and Bluetooth:

```
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

TLP for laptop:

`sudo systemctl enable tlp.service`


# 🍙 My Dotfiles

![My Setup](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png)
> *Placeholder untuk screenshot desktop Anda. Ganti link di atas dengan link gambar asli nanti.*

Koleksi konfigurasi (dotfiles) untuk setup Linux saya menggunakan **Hyprland** dan **Waybar**.

## 🖼️ Gallery

| Desktop | App Launcher |
|:---:|:---:|
| <img src="screenshot_desktop.png" alt="Desktop" width="400"/> | <img src="screenshot_menu.png" alt="Launcher" width="400"/> |
| *Clean State* | *App Launcher* |

## 🛠️ Details

- **OS**: Linux
- **WM**: [Hyprland](https://github.com/hyprwm/Hyprland)
- **Bar**: [Waybar](https://github.com/Alexays/Waybar)
- **Terminal**: Alacritty / Kitty
- **Shell**: Zsh
- **Font**: JetBrains Mono Nerd Font
- **Launcher**: Wofi / Hyprlauncher

## 📂 Structure

Repository ini berisi konfigurasi untuk:

- **`hypr/`** : Konfigurasi utama Hyprland, keybindings, dan wallpaper.
- **`waybar/`** : Konfigurasi status bar dan styling (CSS).

## 🚀 Installation

### 1. Clone Repository
Clone repository ini ke folder home Anda:

```bash
git clone https://github.com/USERNAME_ANDA/dotfiles.git ~/dotfiles
```

### 2. Symlink Configs
Gunakan perintah `ln -s` untuk menghubungkan config ke folder `.config` Anda.

**⚠️ Warning**: Backup konfigurasi lama Anda sebelum menjalankan perintah ini!

```bash
# Backup config lama
mv ~/.config/hypr ~/.config/hypr.bak
mv ~/.config/waybar ~/.config/waybar.bak

# Create Symlinks
ln -s ~/dotfiles/hypr ~/.config/hypr
ln -s ~/dotfiles/waybar ~/.config/waybar
```

### 3. Font Installation
Pastikan Anda sudah menginstall font yang dibutuhkan agar icon terlihat benar:
- [Nerd Fonts](https://www.nerdfonts.com/) (Recommended: JetBrains Mono / Iosevka)

## ⌨️ Keybinds

| Key | Action |
|:---:|:---|
| `Super + Q` | Open Terminal |
| `Super + C` | Close App |
| `Super + E` | File Manager |
| `Super + Space` | App Launcher |

---

<div align="center">
  <sub>Made with ❤️ by Lyon</sub>
</div>

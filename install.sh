#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Fungsi untuk print status
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Lokasi dotfiles saat ini
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config"

# --- 1. TAMPILKAN PREVIEW ---
if [ -f "$DOTFILES_DIR/waybar/image.png" ]; then
    log "Menampilkan preview setup..."
    # Coba tampilkan dengan kitten (kitty) atau imv/feh jika ada
    if command -v kitten &> /dev/null; then
        kitten icat "$DOTFILES_DIR/waybar/image.png"
    elif command -v imv &> /dev/null; then
        imv "$DOTFILES_DIR/waybar/image.png" &
    else
        warn "Preview image ada di waybar/image.png (install kitten/imv untuk melihat di terminal)"
    fi
else
    warn "Preview image (waybar/image.png) tidak ditemukan."
fi

echo ""
echo -e "${YELLOW}!!! PERINGATAN !!!${NC}"
echo "Script ini akan membackup config lama kamu ke format .bak"
echo "dan menggantinya dengan symlink dari dotfiles ini."
read -p "Lanjutkan instalasi? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    error "Instalasi dibatalkan."
    exit 1
fi

# --- 1.5 INSTALASI DEPENDENSI UTAMA & TEMA ---
echo ""
log "Memeriksa dan menginstal paket yang dibutuhkan..."

# Daftar paket lengkap
# Core: Hyprland, Waybar, Rofi, Eww, Kitty
# Utils: Dunst (Notif), SWWW (Wallpaper), Polkit (Auth), Nautilus (File), Blueman (BT)
# Screenshot & Clip: Grim, Slurp, WL-Clipboard
# Audio & Brightness: Pamixer, Brightnessctl
# Themes: Catppuccin, Tela Icons, Deepin Cursor, Nordic Cursor

PACKAGES="hyprland waybar rofi-wayland eww-wayland kitty \
dunst swww polkit-kde-agent nemo nemo-fileroller \
hyprlock hypridle file-roller jq qt6ct wireplumber \
xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
grim slurp wl-clipboard wf-recorder cliphist pamixer brightnessctl \
inverse-icon-theme-git bibata-cursor-theme \
visual-studio-code-bin google-chrome spotify scrcpy \
bluez-utils networkmanager fastfetch gvfs"

if command -v yay &> /dev/null; then
    yay -S --needed $PACKAGES
    success "Paket berhasil diinstal via yay."
elif command -v paru &> /dev/null; then
    paru -S --needed $PACKAGES
    success "Paket berhasil diinstal via paru."
else
    warn "yay atau paru tidak ditemukan. Lewati instalasi paket otomatis."
    warn "Silakan instal manual: $PACKAGES"
fi
echo ""

# --- 2. FUNGSI LINKING ---
link_config() {
    local folder_name=$1
    local source_path="$DOTFILES_DIR/$folder_name"
    local target_path="$CONFIG_DIR/$folder_name"

    log "Memproses: $folder_name"

    # Cek apakah source ada di dotfiles
    if [ ! -d "$source_path" ] && [ ! -f "$source_path" ]; then
        warn "Sumber tidak ditemukan: $source_path (Melewati...)"
        return
    fi

    # Cek target, backup jika ada (dan bukan symlink yang benar)
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        # Cek apakah sudah symlink ke tempat yang benar
        current_link=$(readlink -f "$target_path")
        if [ "$current_link" == "$source_path" ]; then
            success "$folder_name sudah terhubung dengan benar."
            return
        fi

        warn "Config lama ditemukan. Membuat backup..."
        mv "$target_path" "${target_path}.bak_$(date +%Y%m%d_%H%M%S)"
        success "Backup dibuat di ${target_path}.bak_..."
    fi

    # Buat symlink
    ln -s "$source_path" "$target_path"
    success "Symlink dibuat: $target_path -> $source_path"
}

# --- 3. EKSEKUSI LINKING ---
# Pastikan folder config ada
mkdir -p "$CONFIG_DIR"

# List folder yang mau di-link
link_config "eww"
link_config "hypr"
link_config "waybar"
link_config "rofi"
link_config "gtk-3.0"
link_config "gtk-4.0"
link_config "kitty"
link_config "dunst"
link_config "hypridle"

# --- 4. LINK FILE (Untuk .bashrc dll) ---
link_file() {
    local file_name=$1
    local source_path="$DOTFILES_DIR/$file_name"
    local target_path="$HOME/$file_name"

    log "Memproses: $file_name"

    # Cek source
    if [ ! -f "$source_path" ]; then
        error "Sumber file tidak ditemukan: $source_path"
        return
    fi

    # Cek target, backup jika ada
    if [ -f "$target_path" ] || [ -L "$target_path" ]; then
        current_link=$(readlink -f "$target_path")
        if [ "$current_link" == "$source_path" ]; then
            success "$file_name sudah terhubung dengan benar."
            return
        fi

        warn "File lama ditemukan. Membuat backup..."
        mv "$target_path" "${target_path}.bak_$(date +%Y%m%d_%H%M%S)"
        success "Backup dibuat di ${target_path}.bak_..."
    fi

    # Buat symlink
    ln -s "$source_path" "$target_path"
    success "Symlink dibuat: $target_path -> $source_path"
}

# Link .bashrc
link_file ".bashrc"

# --- 5. LINK FONTS CUSTOM ---
echo ""
if [ -d "$DOTFILES_DIR/fonts" ]; then
    log "Memproses: fonts"
    mkdir -p "$HOME/.local/share"
    
    if [ -d "$HOME/.local/share/fonts" ] && [ ! -L "$HOME/.local/share/fonts" ]; then
        warn "Folder font asli ditemukan. Membuat backup..."
        mv "$HOME/.local/share/fonts" "$HOME/.local/share/fonts.bak_$(date +%Y%m%d_%H%M%S)"
    fi
    
    if [ ! -L "$HOME/.local/share/fonts" ]; then
        ln -s "$DOTFILES_DIR/fonts" "$HOME/.local/share/fonts"
        success "Font berhasil ditautkan!"
    fi
    
    # Refresh cache font sistem
    fc-cache -fv &> /dev/null
    success "Cache font diperbarui."
else
    warn "Folder fonts tidak ditemukan di dotfiles. Lewati setup font."
fi

# --- 6. APPLY THEMES (ALL DONE) ---
echo ""
log "Menerapkan tema MonoTheme secara otomatis..."

# Install Theme variants if not exists
if [ ! -d "$HOME/.themes/MonoThemeDark" ]; then
    log "Cloning Mono-gtk-theme from GitHub..."
    git clone https://github.com/witalihirsch/Mono-gtk-theme.git /tmp/Mono-gtk-theme
    mkdir -p "$HOME/.themes"
    cp -r /tmp/Mono-gtk-theme/Mono* "$HOME/.themes/"
    rm -rf /tmp/Mono-gtk-theme
fi

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme 'MonoThemeDark'
    gsettings set org.gnome.desktop.interface icon-theme 'Reversal-black-dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    
    # Nemo specific settings for better aesthetics
    if command -v nemo &> /dev/null; then
        gsettings set org.nemo.desktop show-desktop-icons false 2>/dev/null
        gsettings set org.nemo.window-state sidebar-width 200 2>/dev/null
    fi
    
    success "Tema, Ikon, dan Kursor telah diterapkan!"
else
    warn "gsettings tidak ditemukan. Silakan atur tema secara manual."
fi

# Refresh desktop portal
log "Refreshing desktop portal..."
systemctl --user restart xdg-desktop-portal-gtk.service 2>/dev/null || pkill xdg-desktop-portal-gtk

# Refresh xdg-desktop-portal-gtk to apply changes to file picker
log "Refreshing desktop portal..."
systemctl --user restart xdg-desktop-portal-gtk.service 2>/dev/null || pkill xdg-desktop-portal-gtk

echo ""
echo -e "${GREEN}=== Instalasi Selesai! ===${NC}"
echo "Silakan restart terminal atau source ~/.bashrc untuk melihat perubahan."
echo "Nikmati setup Monochrome kamu! 🏁"

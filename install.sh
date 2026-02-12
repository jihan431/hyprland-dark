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

# --- 2. FUNGSI LINKING ---
link_config() {
    local folder_name=$1
    local source_path="$DOTFILES_DIR/$folder_name"
    local target_path="$CONFIG_DIR/$folder_name"

    log "Memproses: $folder_name"

    # Cek apakah source ada di dotfiles
    if [ ! -d "$source_path" ] && [ ! -f "$source_path" ]; then
        error "Sumber tidak ditemukan: $source_path"
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
link_config "hypr"
link_config "waybar"
link_config "rofi"
link_config "networkmanager-dmenu"

echo ""
echo -e "${GREEN}=== Instalasi Selesai! ===${NC}"
echo "Silakan restart Hyprland atau Waybar untuk melihat perubahan."

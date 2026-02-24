# 🏁 Monochrome Dots

> A premium, minimalist, and high-contrast monochrome desktop environment.

This repository contains my personal configuration files (dotfiles) for **Arch Linux**. The setup is built around **Hyprland**, **Waybar**, and **Eww**, carefully curated to achieve a sophisticated **Monochrome (Black & White)** aesthetic with glassmorphism touches.

---

## 🖼️ Gallery

![Desktop Overview](waybar/image5.png)

<div align="center">
  <img src="waybar/image.png" width="45%" alt="Desktop Overview" />
  <img src="waybar/image2.png" width="45%" alt="App Launcher" />
  <br/>
  <img src="waybar/image3.png" width="45%" alt="Floating Windows" />
  <img src="waybar/image4.png" width="45%" alt="Lock Screen / Extra" />
</div>

---

## 🛠️ System Components

| Component | Selection | Description |
|-----------|-----------|-------------|
| **OS** | Arch Linux | The foundation |
| **WM** | [Hyprland](https://github.com/hyprwm/Hyprland) | Wayland compositor |
| **Status Bar**| [Waybar](https://github.com/Alexays/Waybar) | Minimal vertical bar |
| **Widgets** | [Eww](https://github.com/elkowar/eww) | Glassmorphism Control Center |
| **Lockscreen**| [Hyprlock](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/) | Minimalist protection |
| **Terminal** | Kitty | GPU-accelerated B&W terminal |
| **Launcher** | Rofi | Custom monochrome menus |
| **Shell** | Bash | Clean monochrome prompt |
| **Theme** | **Monochrome** | High-contrast Black & White |
| **Font** | SF Compact Display | Clean, modern typography |

---

## ✨ Key Features

### 🎛️ Control Center
A sophisticated glassmorphism-inspired panel for seamless system control:
- **Connectivity**: Integrated Wi-Fi management and Bluetooth controls.
- **Audio Hub**: Precision sliders for Volume and Microphone with status indicators.
- **Capture**: Quick-access Screen Recording and Clipboard-integrated Screenshots.

### 🌑 Aesthetics
- **Borderless Design**: Maximizing screen real estate and focus.
- **Monochrome Palette**: Consistent black, white, and grey tones across all UI elements.
- **Micro-animations**: Subtle transitions for a premium interactive feel.

---

## 🚀 Setup

### 1. Clone
```bash
git clone https://github.com/jihan431/hyprland-dark.git
cd hyprland-dark
```

### 2. Install
The included `install.sh` handles the heavy lifting of symlinking and configuration.

```bash
chmod +x install.sh
./install.sh
```

---

## ⌨️ Quick Bindings

| Combination | Action |
|-------------|--------|
| `SUPER + Q` | Close Window |
| `SUPER + RET` | Terminal |
| `SUPER + SPC` | Launcher |
| `SUPER + E` | File Manager |
| `SUPER + L` | Power Menu |
| `SUPER + V` | Toggle Floating |

---

## 📂 Repository Layout

```text
dotfiles/
├── eww/                  # Widgets & Control Center
├── fonts/                # UI Typography
├── hypr/                 # Compositor & Lockscreen
├── waybar/               # Custom Status Bar
├── rofi/                 # Application Launcher
├── gtk-3.0/              # System-wide B&W styling
└── install.sh            # Setup automation
```
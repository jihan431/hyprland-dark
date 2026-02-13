
from PIL import Image
import sys
import os

DOTS = {
    0x01: (0, 0), 0x02: (0, 1), 0x04: (0, 2), 0x40: (0, 3),
    0x08: (1, 0), 0x10: (1, 1), 0x20: (1, 2), 0x80: (1, 3)
}

def braille_to_image(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = [line.rstrip() for line in f]
    
    # Calculate dimensions
    height_chars = len(lines)
    if height_chars == 0: return None
    width_chars = max(len(line) for line in lines)
    
    img_width = width_chars * 2
    img_height = height_chars * 4
    
    img = Image.new('1', (img_width, img_height), 0)
    pixels = img.load()
    
    for y, line in enumerate(lines):
        for x, char in enumerate(line):
            code = ord(char)
            if 0x2800 <= code <= 0x28FF:
                val = code - 0x2800
                for bit, (dx, dy) in DOTS.items():
                    if val & bit:
                        pixels[x*2 + dx, y*4 + dy] = 1
                        
    return img

def image_to_braille(img):
    width, height = img.size
    cols = (width + 1) // 2
    rows = (height + 3) // 4
    
    lines = []
    pixels = img.load()
    
    for r in range(rows):
        line = ""
        for c in range(cols):
            val = 0
            for bit, (dx, dy) in DOTS.items():
                px = c*2 + dx
                py = r*4 + dy
                if px < width and py < height:
                    if pixels[px, py]:
                        val |= bit
            line += chr(0x2800 + val)
        lines.append(line)
        
    return "\n".join(lines)

def main():
    input_file = os.path.expanduser("~/dotfiles/ascii.txt")
    if not os.path.exists(input_file):
        print("File not found")
        return

    img = braille_to_image(input_file)
    if not img:
        print("Failed to load image")
        return

    # Resize (Scale down by 50%)
    new_size = (int(img.width * 0.5), int(img.height * 0.5))
    resized_img = img.resize(new_size, Image.NEAREST) # Nearest neighbor for clear pixel art

    output = image_to_braille(resized_img)
    
    # Save back
    with open(input_file, "w", encoding='utf-8') as f:
        f.write(output)
    
    print("Resized ASCII art saved to ascii.txt")

if __name__ == "__main__":
    main()

import os
from PIL import Image, ImageDraw

def generate_icons():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    logo_path = os.path.join(base_dir, 'assets', 'images', 'logo.png')
    trans_logo_path = os.path.join(base_dir, 'assets', 'images', 'trans-logo.png')
    res_dir = os.path.join(base_dir, 'android', 'app', 'src', 'main', 'res')

    img = Image.open(logo_path).convert('RGBA')
    trans_img = Image.open(trans_logo_path).convert('RGBA')

    densities = {
        'mipmap-mdpi': (48, 108),
        'mipmap-hdpi': (72, 162),
        'mipmap-xhdpi': (96, 216),
        'mipmap-xxhdpi': (144, 324),
        'mipmap-xxxhdpi': (192, 432),
    }

    for folder, (size, fg_size) in densities.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)

        # 1. Standard ic_launcher.png (square/soft-round)
        launcher = img.resize((size, size), Image.Resampling.LANCZOS)
        launcher.save(os.path.join(folder_path, 'ic_launcher.png'), 'PNG')

        # 2. Round ic_launcher_round.png
        mask = Image.new('L', (size, size), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size - 1, size - 1), fill=255)
        round_launcher = Image.new('RGBA', (size, size), (255, 255, 255, 0))
        round_launcher.paste(launcher, (0, 0), mask=mask)
        round_launcher.save(os.path.join(folder_path, 'ic_launcher_round.png'), 'PNG')

        # 3. Adaptive Foreground ic_launcher_foreground.png (108dp viewport, inner 72dp safe area)
        fg_canvas = Image.new('RGBA', (fg_size, fg_size), (0, 0, 0, 0))
        inner_size = int(fg_size * 0.72)
        offset = (fg_size - inner_size) // 2
        inner_logo = trans_img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
        fg_canvas.paste(inner_logo, (offset, offset), mask=inner_logo)
        fg_canvas.save(os.path.join(folder_path, 'ic_launcher_foreground.png'), 'PNG')

        print(f"Generated {folder}: {size}x{size}, round: {size}x{size}, fg: {fg_size}x{fg_size}")

    # 4. Values colors.xml
    values_dir = os.path.join(res_dir, 'values')
    os.makedirs(values_dir, exist_ok=True)
    colors_xml_path = os.path.join(values_dir, 'colors.xml')
    with open(colors_xml_path, 'w', encoding='utf-8') as f:
        f.write('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFFFFF</color>
</resources>
''')
    print("Generated colors.xml")

    # 5. anydpi-v26 adaptive icon XMLs
    anydpi_dir = os.path.join(res_dir, 'mipmap-anydpi-v26')
    os.makedirs(anydpi_dir, exist_ok=True)

    adaptive_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''
    with open(os.path.join(anydpi_dir, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write(adaptive_xml)

    with open(os.path.join(anydpi_dir, 'ic_launcher_round.xml'), 'w', encoding='utf-8') as f:
        f.write(adaptive_xml)
    print("Generated anydpi-v26 XMLs")

if __name__ == '__main__':
    generate_icons()

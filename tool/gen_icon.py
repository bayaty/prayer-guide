#!/usr/bin/env python3
"""Generate salah_guide app icons from a crescent moon emoji.

Renders the Noto Color Emoji glyph onto a night-sky gradient background
and writes every platform icon size Flutter expects.
"""
from PIL import Image, ImageDraw, ImageFont
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EMOJI_FONT = "/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"
EMOJI = "\U0001F319"  # 🌙 crescent moon
S = 1024  # master size

# --- background: soft rose → lilac gradient --------------------------------
TOP = (255, 214, 233)   # blush pink
BOT = (198, 168, 245)   # soft lilac

bg = Image.new("RGBA", (S, S))
d = ImageDraw.Draw(bg)
for y in range(S):
    t = y / (S - 1)
    d.line([(0, y), (S, y)],
           fill=tuple(int(a + (b - a) * t) for a, b in zip(TOP, BOT)) + (255,))

# --- emoji glyph -----------------------------------------------------------
# NotoColorEmoji is a CBDT bitmap font: it only renders at 109px, so render
# there and upscale with LANCZOS.
NATIVE = 109
font = ImageFont.truetype(EMOJI_FONT, NATIVE)
glyph = Image.new("RGBA", (NATIVE * 2, NATIVE * 2), (0, 0, 0, 0))
ImageDraw.Draw(glyph).text((NATIVE, NATIVE), EMOJI, font=font,
                           embedded_color=True, anchor="mm")
glyph = glyph.crop(glyph.getbbox())

# scale glyph to ~62% of canvas, preserving aspect
target = int(S * 0.62)
w, h = glyph.size
scale = target / max(w, h)
glyph = glyph.resize((max(1, round(w * scale)), max(1, round(h * scale))),
                     Image.LANCZOS)

# --- soft white halo behind the moon ---------------------------------------
from PIL import ImageFilter
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
r = int(S * 0.34)
gd.ellipse([S // 2 - r, S // 2 - r, S // 2 + r, S // 2 + r],
           fill=(255, 255, 255, 110))
glow = glow.filter(ImageFilter.GaussianBlur(S * 0.07))
bg = Image.alpha_composite(bg, glow)

# --- recolour the moon to soft cream/white ---------------------------------
# The Noto glyph is saturated gold; tint it toward cream so it reads soft
# against pastel rather than harsh.
px = glyph.load()
for yy in range(glyph.height):
    for xx in range(glyph.width):
        r_, g_, b_, a_ = px[xx, yy]
        if a_:
            # blend 55% toward warm cream
            px[xx, yy] = (
                int(r_ * 0.45 + 255 * 0.55),
                int(g_ * 0.45 + 250 * 0.55),
                int(b_ * 0.45 + 240 * 0.55),
                a_,
            )

gx = (S - glyph.width) // 2
gy = (S - glyph.height) // 2
bg.paste(glyph, (gx, gy), glyph)

# --- sparkles --------------------------------------------------------------
def sparkle(img, cx, cy, size, alpha=235):
    """Four-point twinkle star."""
    lay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(lay)
    ld.polygon([(cx, cy - size), (cx + size * 0.26, cy - size * 0.26),
                (cx + size, cy), (cx + size * 0.26, cy + size * 0.26),
                (cx, cy + size), (cx - size * 0.26, cy + size * 0.26),
                (cx - size, cy), (cx - size * 0.26, cy - size * 0.26)],
               fill=(255, 255, 255, alpha))
    return Image.alpha_composite(img, lay)

for cx, cy, sz in [
    (0.22, 0.22, 0.070), (0.80, 0.30, 0.048),
    (0.74, 0.79, 0.060), (0.27, 0.76, 0.038),
]:
    bg = sparkle(bg, cx * S, cy * S, sz * S)

master = bg

# --- output targets --------------------------------------------------------
targets = {
    # Android launcher icons
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": 48,
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": 72,
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": 96,
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": 144,
    "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": 192,
    # Web
    "web/favicon.png": 16,
    "web/icons/Icon-192.png": 192,
    "web/icons/Icon-512.png": 512,
    "web/icons/Icon-maskable-192.png": 192,
    "web/icons/Icon-maskable-512.png": 512,
}

# iOS AppIcon set
ios = {
    "Icon-App-20x20@1x.png": 20, "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60, "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58, "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40, "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120, "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180, "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152, "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}
for name, px in ios.items():
    targets[f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{name}"] = px

master.save(os.path.join(ROOT, "tool/icon_master.png"))

for rel, px in sorted(targets.items()):
    path = os.path.join(ROOT, rel)
    if not os.path.isdir(os.path.dirname(path)):
        print(f"  skip (no dir): {rel}")
        continue
    img = master.resize((px, px), Image.LANCZOS)
    # iOS icons must be opaque with no alpha channel
    if "/ios/" in path or rel.startswith("ios/"):
        flat = Image.new("RGB", (px, px), TOP)
        flat.paste(img, (0, 0), img)
        flat.save(path)
    else:
        img.save(path)
    print(f"  {px:>4}px  {rel}")

print("\nmaster: tool/icon_master.png")

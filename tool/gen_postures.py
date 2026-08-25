#!/usr/bin/env python3
"""Generate faceless prayer-posture figures as PNG assets.

Flat, faceless silhouettes in the app palette, used instead of the
human emoji (standing / bowing / kneeling / open hands), which render
with faces and skin tones on most devices.
"""
import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "postures")
os.makedirs(OUT, exist_ok=True)

S = 512                      # master canvas
FIG = (123, 63, 118)         # AppColors.primary
ACCENT = (176, 90, 150)      # AppColors.accent
BG = (252, 239, 247)         # AppColors.tintBg


def canvas():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # soft round backdrop
    d.ellipse([8, 8, S - 8, S - 8], fill=BG + (255,))
    return img, d


def head(d, cx, cy, r, color=FIG):
    """A plain circle. No face, deliberately."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=color + (255,))


def limb(d, p1, p2, w, color=FIG):
    d.line([p1, p2], fill=color + (255,), width=w, joint="curve")
    for p in (p1, p2):
        d.ellipse([p[0] - w // 2, p[1] - w // 2, p[0] + w // 2, p[1] + w // 2],
                  fill=color + (255,))


def rounded_body(d, box, radius, color=FIG):
    d.rounded_rectangle(box, radius=radius, fill=color + (255,))


def standing():
    """Qiyam: upright, hands folded at the chest."""
    img, d = canvas()
    head(d, 256, 150, 46)
    # torso: gown flaring slightly to the hem
    d.polygon([(214, 205), (298, 205), (322, 400), (190, 400)],
              fill=FIG + (255,))
    # folded arms
    limb(d, (222, 250), (290, 268), 26, ACCENT)
    limb(d, (290, 250), (222, 268), 26, ACCENT)
    return img


def bowing():
    """Ruku: torso horizontal, hands on knees, back flat."""
    img, d = canvas()
    head(d, 148, 214, 44)
    # flat back
    rounded_body(d, [176, 182, 352, 258], 38)
    # legs down from the hip
    limb(d, (326, 250), (326, 384), 30)
    limb(d, (300, 250), (300, 384), 30)
    # arm reaching to the knee
    limb(d, (232, 244), (250, 356), 26, ACCENT)
    return img


def prostrating():
    """Sujud: forehead down, forearms flat, hips raised. Faces left.

    Drawn as separated parts (arms / head / torso / thigh / shin) with
    visible gaps, so the silhouette reads as a body rather than one blob.
    """
    img, d = canvas()

    GROUND = 372

    # shin flat along the ground, knee at its right end
    limb(d, (300, GROUND), (404, GROUND), 30, FIG)
    # thigh rising from knee up to the hips (highest point)
    limb(d, (300, GROUND), (306, 250), 34, FIG)
    # back sloping down from hips toward the shoulders at the left
    limb(d, (306, 252), (196, 296), 40, FIG)
    # head on the ground, forehead down, kept clear of the arms
    head(d, 150, 318, 42, FIG)
    # forearms flat on the ground beneath the head
    limb(d, (112, GROUND), (250, GROUND), 24, ACCENT)

    return img


def hands():
    """Dua: two open palms held side by side, tilted into a cup."""
    img, d = canvas()

    def palm(cx, cy, tilt, color):
        # palm slab
        p = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        pd = ImageDraw.Draw(p)
        pd.rounded_rectangle([cx - 62, cy - 78, cx + 62, cy + 86],
                             radius=44, fill=color + (255,))
        # four fingers as rounded tabs along the top edge
        for i in range(4):
            fx = cx - 45 + i * 30
            pd.rounded_rectangle([fx - 12, cy - 122, fx + 12, cy - 58],
                                 radius=12, fill=color + (255,))
        # thumb off the outer side
        tx = cx - 74 if tilt < 0 else cx + 74
        pd.rounded_rectangle([tx - 18, cy - 26, tx + 18, cy + 52],
                             radius=18, fill=color + (255,))
        return p.rotate(tilt, resample=Image.BICUBIC, center=(cx, cy))

    img.alpha_composite(palm(196, 286, 14, FIG))
    img.alpha_composite(palm(316, 286, -14, ACCENT))
    return img


def sitting():
    """Julus / tashahhud: seated, hands resting on the thighs."""
    img, d = canvas()
    head(d, 240, 158, 44)
    # upright torso
    d.polygon([(202, 210), (280, 210), (296, 320), (188, 320)],
              fill=FIG + (255,))
    # folded legs
    rounded_body(d, [166, 318, 344, 366], 24)
    # arm resting on the thigh
    limb(d, (286, 250), (312, 330), 24, ACCENT)
    return img


FIGURES = {
    "standing": standing,
    "bowing": bowing,
    "prostrating": prostrating,
    "sitting": sitting,
    "hands": hands,
}

if __name__ == "__main__":
    for name, fn in FIGURES.items():
        img = fn()
        # Exported large enough to stay crisp when scaled up on 3x screens.
        img.resize((384, 384), Image.LANCZOS).save(
            os.path.join(OUT, f"{name}.png"))
        print(f"  {name}.png")
    # contact sheet for review
    sheet = Image.new("RGBA", (S * len(FIGURES), S), (255, 255, 255, 255))
    for i, (name, fn) in enumerate(FIGURES.items()):
        sheet.paste(fn(), (i * S, 0))
    sheet.save("/tmp/postures_sheet.png")
    print("\nsheet: /tmp/postures_sheet.png")

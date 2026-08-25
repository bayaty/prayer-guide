#!/usr/bin/env python3
"""Replace hardcoded red hex literals with AppColors references."""
import re, os

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lib")

MAP = {
    "0xFFB71C1C": "AppColors.primary",
    "0xFFC62828": "AppColors.accent",
    "0xFFE53935": "AppColors.highlight",
    "0xFFFFEBEE": "AppColors.tintBg",
    "0xFFEF9A9A": "AppColors.softPink",
    "0xFFF5F5F5": "AppColors.scaffold",
}

FILES = [
    "main.dart",
    "screens/home_screen.dart",
    "screens/prayer_screen.dart",
    "screens/prayer_steps_screen.dart",
]

for rel in FILES:
    path = os.path.join(ROOT, rel)
    src = open(path).read()
    orig = src
    for hexv, name in MAP.items():
        # `const Color(0xHEX)` -> drop the const, a static const field is
        # already a valid const expression.
        src = re.sub(r"const\s+Color\(\s*" + hexv + r"\s*\)", name, src)
        # bare `Color(0xHEX)`
        src = re.sub(r"Color\(\s*" + hexv + r"\s*\)", name, src)

    if src != orig and "app_colors.dart" not in src:
        depth = rel.count("/")
        imp = "../" * depth + "theme/app_colors.dart"
        line = f"import '{imp}';\n"
        # insert after the material import
        src = src.replace(
            "import 'package:flutter/material.dart';\n",
            "import 'package:flutter/material.dart';\n" + line, 1)

    open(path, "w").write(src)
    n = sum(orig.count(h) for h in MAP)
    print(f"{rel}: {n} literals replaced")

leftover = []
for rel in FILES:
    s = open(os.path.join(ROOT, rel)).read()
    for h in MAP:
        if h in s:
            leftover.append((rel, h))
print("leftover:", leftover or "none")

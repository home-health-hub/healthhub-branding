#!/usr/bin/env python3
"""Verify token schema, generated CSS, and declared contrast pairs."""

from __future__ import annotations

import importlib.util
import json
import re
import sys
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent.parent
SOURCE = PROJECT_DIR / "tokens" / "brand.tokens.json"
OUTPUT = PROJECT_DIR / "tokens" / "brand.css"
GENERATOR = PROJECT_DIR / "scripts" / "build-design-tokens.py"
HEX_COLOR = re.compile(r"^#[0-9A-Fa-f]{6}$")


def load_generator():
    spec = importlib.util.spec_from_file_location("build_design_tokens", GENERATOR)
    if spec is None or spec.loader is None:
        raise RuntimeError("Could not load design-token generator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def channel(value: int) -> float:
    normalized = value / 255
    return normalized / 12.92 if normalized <= 0.04045 else ((normalized + 0.055) / 1.055) ** 2.4


def luminance(color: str) -> float:
    values = [int(color[index : index + 2], 16) for index in (1, 3, 5)]
    red, green, blue = (channel(value) for value in values)
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def contrast(foreground: str, background: str) -> float:
    lighter, darker = sorted((luminance(foreground), luminance(background)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    try:
        tokens = json.loads(SOURCE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"Could not read token source: {error}")

    required = {
        "schema_version",
        "font",
        "spacing",
        "radius",
        "border",
        "focus",
        "target",
        "motion",
        "chart",
        "accent",
        "themes",
        "contrast_pairs",
    }
    missing = sorted(required - set(tokens))
    if missing:
        fail(f"Missing token groups: {', '.join(missing)}")
    if tokens["schema_version"] != 1:
        fail("Unsupported token schema_version")
    if set(tokens["themes"]) != {"light", "dark"}:
        fail("Token themes must contain exactly light and dark")

    generator = load_generator()
    expected = generator.render(tokens)
    try:
        actual = OUTPUT.read_text(encoding="utf-8")
    except OSError as error:
        fail(f"Could not read generated CSS: {error}")
    if actual != expected:
        fail("tokens/brand.css is stale; run scripts/build-design-tokens.py")

    for pair in tokens["contrast_pairs"]:
        theme_name = pair["theme"]
        colors = tokens["themes"][theme_name]["color"]
        foreground = colors[pair["foreground"]]
        background = colors[pair["background"]]
        if not HEX_COLOR.fullmatch(foreground) or not HEX_COLOR.fullmatch(background):
            fail(f"Malformed color in contrast pair for {theme_name}")
        ratio = contrast(foreground, background)
        minimum = float(pair["minimum"])
        if ratio + 1e-9 < minimum:
            fail(
                f"Contrast failure for {theme_name} {pair['foreground']} on "
                f"{pair['background']}: {ratio:.2f}:1, requires {minimum:.1f}:1"
            )

    for theme_name, theme in tokens["themes"].items():
        surface = theme["color"]["surface_primary"]
        for status_name, status_color in theme["status"].items():
            ratio = contrast(status_color, surface)
            if ratio + 1e-9 < 4.5:
                fail(
                    f"Contrast failure for {theme_name} status {status_name} on surface: "
                    f"{ratio:.2f}:1, requires 4.5:1"
                )

    print("Design tokens are current and declared contrast pairs pass.")


if __name__ == "__main__":
    main()

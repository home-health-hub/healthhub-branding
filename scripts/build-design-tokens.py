#!/usr/bin/env python3
"""Generate deterministic CSS custom properties from brand.tokens.json."""

from __future__ import annotations

import json
from pathlib import Path


PROJECT_DIR = Path(__file__).resolve().parent.parent
SOURCE = PROJECT_DIR / "tokens" / "brand.tokens.json"
OUTPUT = PROJECT_DIR / "tokens" / "brand.css"


def flatten(prefix: str, value: object) -> list[tuple[str, str]]:
    """Return ordered CSS variable names and scalar values."""
    if isinstance(value, dict):
        result: list[tuple[str, str]] = []
        for key, child in value.items():
            result.extend(flatten(f"{prefix}-{key.replace('_', '-')}", child))
        return result
    if not isinstance(value, (str, int, float)):
        raise ValueError(f"Token {prefix} must be a scalar")
    return [(f"--hh-{prefix}", str(value))]


def declarations(groups: list[tuple[str, object]]) -> list[str]:
    lines: list[str] = []
    for prefix, group in groups:
        for name, value in flatten(prefix, group):
            lines.append(f"  {name}: {value};")
    return lines


def render(tokens: dict[str, object]) -> str:
    common_names = [
        "font",
        "spacing",
        "radius",
        "border",
        "focus",
        "target",
        "motion",
        "chart",
        "accent",
    ]
    themes = tokens["themes"]
    if not isinstance(themes, dict) or set(themes) != {"light", "dark"}:
        raise ValueError("themes must contain exactly light and dark")

    common = [(name, tokens[name]) for name in common_names]
    light = themes["light"]
    dark = themes["dark"]
    output = [
        "/* Generated from tokens/brand.tokens.json. Do not edit directly. */",
        ":root,",
        '[data-theme="light"] {',
        *declarations(common),
        *declarations([("color", light["color"]), ("status", light["status"])]),
        "  color-scheme: light;",
        "}",
        "",
        '[data-theme="dark"] {',
        *declarations([("color", dark["color"]), ("status", dark["status"])]),
        "  color-scheme: dark;",
        "}",
        "",
        "@media (prefers-reduced-motion: reduce) {",
        "  :root {",
        "    --hh-motion-duration-immediate: 0ms;",
        "    --hh-motion-duration-standard: 0ms;",
        "    --hh-motion-duration-large: 0ms;",
        "  }",
        "}",
        "",
    ]
    return "\n".join(output)


def main() -> None:
    tokens = json.loads(SOURCE.read_text(encoding="utf-8"))
    OUTPUT.write_text(render(tokens), encoding="utf-8")
    print("Generated tokens/brand.css.")


if __name__ == "__main__":
    main()

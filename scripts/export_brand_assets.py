"""Export launcher/favicon sizes from the approved generated PNG (Pillow)."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "branding" / "unimatch-logo.png"
logo = Image.open(SOURCE).convert("RGBA")
BACKGROUND = (255, 248, 250, 255)


def export(path: Path, size: int, *, opaque: bool, inset: float = 1.0):
    canvas = Image.new("RGBA", (size, size), BACKGROUND if opaque else (0, 0, 0, 0))
    side = round(size * inset)
    mark = logo.resize((side, side), Image.Resampling.LANCZOS)
    canvas.alpha_composite(mark, ((size - side) // 2, (size - side) // 2))
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, optimize=True)


for app in ("unimatch_user", "unimatch_admin"):
    export(ROOT / app / "assets/branding/unimatch_logo.png", 512, opaque=False)

res = ROOT / "unimatch_user/android/app/src/main/res"
for density, launcher, foreground in (
    ("mdpi", 48, 108), ("hdpi", 72, 162), ("xhdpi", 96, 216),
    ("xxhdpi", 144, 324), ("xxxhdpi", 192, 432),
):
    export(res / f"mipmap-{density}/ic_launcher.png", launcher, opaque=True)
    # Android's 108dp foreground includes an outer crop zone. Keep the mark
    # within the central safe region while preserving the source PNG's alpha.
    export(res / f"drawable-{density}/ic_launcher_foreground.png", foreground,
           opaque=False, inset=0.76)

web = ROOT / "unimatch_admin/web"
export(web / "favicon.png", 64, opaque=True)
for size in (192, 512):
    export(web / f"icons/Icon-{size}.png", size, opaque=True)
    export(web / f"icons/Icon-maskable-{size}.png", size, opaque=True, inset=0.9)
export(web / "unimatch-logo.png", 512, opaque=False)
export(ROOT / "branding/unimatch-icon.png", 512, opaque=True)
print("Brand exports ready for Android, Flutter, and Web.")

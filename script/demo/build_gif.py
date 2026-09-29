"""Assembles the frames captured by record.js into docs/images/dynaspan-demo.gif.

Requires Pillow (`pip install pillow`).
"""
import json
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
FRAMES = HERE / "frames"
OUTPUT = HERE.parent.parent / "docs" / "images" / "dynaspan-demo.gif"


def main():
    manifest = json.loads((FRAMES / "frames.json").read_text())
    images = [Image.open(FRAMES / frame["file"]).convert("RGB") for frame in manifest]

    # One shared palette keeps colours stable from frame to frame.
    sample = images[:: max(1, len(images) // 12)]
    width, height = sample[0].size
    sheet = Image.new("RGB", (width, height * len(sample)))
    for index, image in enumerate(sample):
        sheet.paste(image, (0, height * index))
    palette = sheet.quantize(colors=255, method=Image.Quantize.MEDIANCUT)

    frames = [image.quantize(palette=palette, dither=Image.Dither.NONE) for image in images]
    frames[0].save(
        OUTPUT,
        save_all=True,
        append_images=frames[1:],
        duration=[frame["duration"] for frame in manifest],
        loop=0,
        optimize=False,
        disposal=1,
    )
    print(f"Wrote {OUTPUT} ({OUTPUT.stat().st_size / 1024:.0f} KiB, {len(frames)} frames)")


if __name__ == "__main__":
    main()

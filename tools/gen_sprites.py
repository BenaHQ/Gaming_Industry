#!/usr/bin/env python3
"""Genera gli sprite pixel-art PLACEHOLDER del gioco.

Uso:  python3 tools/gen_sprites.py   (richiede Pillow)

Tutti i PNG finiscono in assets/sprites/. Sono segnaposto: gli artisti del
gruppo possono sostituirli con file con lo stesso nome e la stessa griglia
di frame senza toccare il codice.
"""
import os
import random
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
os.makedirs(OUT, exist_ok=True)

PAL = {
    ".": (0, 0, 0, 0),
    "k": (43, 15, 18, 255),     # contorno scuro
    "r": (216, 58, 46, 255),    # rosso granchio
    "o": (242, 120, 75, 255),   # luce arancio
    "d": (156, 36, 32, 255),    # ombra rossa
    "w": (255, 255, 255, 255),
    "b": (10, 10, 20, 255),
}


def grid(rows, pal=PAL):
    h, w = len(rows), len(rows[0])
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == w, f"riga {y} larga {len(row)} invece di {w}: {row!r}"
        for x, c in enumerate(row):
            img.putpixel((x, y), pal[c])
    return img


def sheet(frames):
    w, h = frames[0].size
    img = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        img.paste(f, (i * w, 0))
    return img


def save(img, name):
    img.save(os.path.join(OUT, name))
    print("  ", name, img.size)


def canvas(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img)


# --------------------------------------------------------------- granchietto
CRAB_TOP = [
    "................",
    "................",
    "....kk....kk....",
    "...kwwk..kwwk...",
    "...kwbk..kwbk...",
    "....kk....kk....",
    ".....k....k.....",
    "...kkkkkkkkkk...",
    "..koorrrrrrrrk..",
    ".korrrrrrrrrrrk.",
    ".krrrrrrrrrrrrk.",
    ".kdrrrrrrrrrrdk.",
    "..kddddddddddk..",
]
CRAB_LEGS = {
    "idle": ["..k.k.k..k.k.k..", ".k.k.k....k.k.k.", "................"],
    "walk1": ["...k.k.k..k.k.k.", "..k.k.k....k.k.k", "................"],
    "walk2": [".k.k.k..k.k.k...", "k.k.k....k.k.k..", "................"],
    "jump": ["..kk.kk..kk.kk..", "................", "................"],
}


def crab():
    frames = [grid(CRAB_TOP + CRAB_LEGS[k]) for k in ("idle", "walk1", "walk2", "jump")]
    save(sheet(frames), "crab.png")


def claws():
    save(grid([
        "..kkkk..",
        ".korrrk.",
        "krrrkkk.",
        "krrk....",
        "krrk....",
        "krrrkkk.",
        ".kdddddk",
        "..kkkkk.",
    ]), "claw_pinza.png")
    save(grid([
        "..kkkkkk..",
        ".kooorrrk.",
        "korrrrrrrk",
        "krrrrrrrrk",
        "krrrrrrrrk",
        "kdrrrrrrdk",
        ".kddddddk.",
        "..kkkkkk..",
        "...krrk...",
        "...kkkk...",
    ]), "claw_martello.png")
    save(grid([
        "......kkkkk.",
        ".kkkkkkoorrk",
        "krrrrrrkkkk.",
        "kdddddk.....",
        "krrrrrrkkkk.",
        ".kkkkkkddddk",
        "......kkkkk.",
        "............",
    ]), "claw_tenaglia.png")


def glider():
    img, d = canvas(24, 8)
    d.polygon([(0, 7), (12, 0), (23, 7)], fill=(80, 200, 220, 255), outline=(20, 60, 80, 255))
    d.line([(12, 0), (12, 7)], fill=(250, 240, 120, 255))
    d.line([(6, 4), (18, 4)], fill=(20, 60, 80, 255))
    save(img, "glider.png")


# ------------------------------------------------------------------- nemici
def pufferfish():
    frames = []
    for puffed in (False, True):
        img, d = canvas(24, 24)
        if puffed:
            for i in range(12):
                import math
                a = i * math.pi / 6
                x1, y1 = 12 + math.cos(a) * 9, 12 + math.sin(a) * 9
                x2, y2 = 12 + math.cos(a) * 11.5, 12 + math.sin(a) * 11.5
                d.line([(x1, y1), (x2, y2)], fill=(120, 80, 20, 255))
            d.ellipse([3, 3, 20, 20], fill=(240, 200, 70, 255), outline=(90, 60, 10, 255))
            d.ellipse([6, 12, 17, 19], fill=(250, 235, 180, 255))
            d.rectangle([14, 8, 15, 9], fill=(10, 10, 20, 255))
            d.point((13, 15), fill=(90, 60, 10, 255))
        else:
            d.polygon([(3, 9), (6, 12), (3, 15)], fill=(220, 170, 60, 255), outline=(90, 60, 10, 255))
            d.ellipse([6, 7, 19, 17], fill=(240, 200, 70, 255), outline=(90, 60, 10, 255))
            d.ellipse([8, 12, 17, 16], fill=(250, 235, 180, 255))
            d.rectangle([15, 10, 16, 11], fill=(10, 10, 20, 255))
            d.point((19, 13), fill=(90, 60, 10, 255))
        frames.append(img)
    save(sheet(frames), "pufferfish.png")


def jellyfish():
    frames = []
    for f in range(2):
        img, d = canvas(16, 16)
        d.pieslice([2, 1, 13, 12], 180, 360, fill=(240, 140, 200, 220), outline=(150, 60, 130, 255))
        d.line([(3, 6), (12, 6)], fill=(150, 60, 130, 255))
        d.point((5, 3), fill=(255, 230, 250, 255))
        for i, x in enumerate((4, 7, 10, 12)):
            off = (i + f) % 2
            d.line([(x, 7), (x + off, 10), (x, 13), (x + off, 15)], fill=(220, 120, 190, 255))
        frames.append(img)
    save(sheet(frames), "jellyfish.png")


def piranha():
    frames = []
    for f in range(2):
        img, d = canvas(16, 12)
        d.polygon([(0, 2), (4, 6), (0, 10)], fill=(110, 110, 140, 255), outline=(40, 40, 60, 255))
        d.ellipse([3, 1, 15, 11], fill=(140, 140, 170, 255), outline=(40, 40, 60, 255))
        d.ellipse([5, 6, 14, 11], fill=(210, 60, 60, 255))
        d.rectangle([11, 3, 12, 4], fill=(250, 220, 60, 255))
        d.point((12, 4), fill=(10, 10, 20, 255))
        if f == 1:
            d.polygon([(15, 6), (11, 7), (15, 9)], fill=(40, 10, 20, 255))
        d.point((13, 7), fill=(255, 255, 255, 255))
        d.point((14, 8), fill=(255, 255, 255, 255))
        frames.append(img)
    save(sheet(frames), "piranha.png")


# ------------------------------------------------------------------ oggetti
def small_things():
    img, d = canvas(8, 8)
    d.ellipse([1, 1, 6, 6], fill=(235, 230, 245, 255), outline=(150, 140, 180, 255))
    d.point((3, 2), fill=(255, 255, 255, 255))
    save(img, "pearl.png")

    img, d = canvas(16, 16)
    d.ellipse([0, 0, 15, 15], fill=(140, 220, 255, 70), outline=(190, 240, 255, 255))
    d.line([(4, 4), (6, 3)], fill=(255, 255, 255, 255))
    save(img, "bubble.png")

    img, d = canvas(12, 12)
    d.polygon([(2, 2), (8, 6), (2, 10)], fill=(250, 220, 60, 255), outline=(120, 80, 10, 255))
    d.line([(7, 3), (10, 6), (7, 9)], fill=(250, 250, 250, 255))
    save(img, "icon_dash.png")

    img, d = canvas(12, 12)
    d.polygon([(0, 8), (6, 2), (11, 8)], fill=(80, 200, 220, 255), outline=(20, 60, 80, 255))
    d.line([(6, 2), (6, 11)], fill=(120, 80, 40, 255))
    save(img, "icon_deltaplano.png")

    hearts = []
    for full in (True, False):
        h = grid([
            ".kk.kk..",
            "kffkffk.",
            "kfffffk.",
            "kfffffk.",
            ".kfffk..",
            "..kfk...",
            "...k....",
            "........",
        ], {".": (0, 0, 0, 0), "k": (40, 10, 20, 255),
            "f": (230, 50, 70, 255) if full else (70, 60, 80, 255)})
        hearts.append(h)
    save(sheet(hearts), "hearts.png")

    img, d = canvas(16, 16)
    for i in range(10):
        import math
        a = math.pi + i * math.pi / 9
        d.line([(8, 12), (8 + math.cos(a) * 8, 12 + math.sin(a) * 9)], fill=(60, 20, 70, 255))
    d.ellipse([2, 8, 13, 17], fill=(110, 40, 120, 255), outline=(40, 10, 50, 255))
    save(img, "urchin.png")

    frames = []
    for opened in (False, True):
        img, d = canvas(24, 16)
        if opened:
            d.pieslice([2, 0, 21, 14], 180, 360, fill=(250, 180, 190, 255), outline=(120, 50, 70, 255))
            d.ellipse([9, 6, 14, 11], fill=(245, 245, 255, 255), outline=(150, 140, 180, 255))
            d.rectangle([2, 12, 21, 15], fill=(240, 150, 170, 255), outline=(120, 50, 70, 255))
        else:
            d.pieslice([2, 2, 21, 26], 180, 360, fill=(250, 180, 190, 255), outline=(120, 50, 70, 255))
            for x in (6, 10, 14, 18):
                d.line([(12, 14), (x, 4)], fill=(200, 110, 130, 255))
            d.rectangle([2, 13, 21, 15], fill=(240, 150, 170, 255), outline=(120, 50, 70, 255))
        frames.append(img)
    save(sheet(frames), "shell.png")


# --------------------------------------------------------------- personaggi
def characters():
    frames = []
    for active in (False, True):
        img, d = canvas(12, 16)
        body = (250, 160, 60, 255) if active else (170, 130, 100, 255)
        out = (100, 50, 20, 255)
        d.ellipse([4, 1, 10, 6], fill=body, outline=out)        # testa
        d.polygon([(10, 3), (11, 4), (10, 5)], fill=out)          # muso
        d.ellipse([3, 5, 9, 12], fill=body, outline=out)         # corpo
        d.line([(6, 12), (7, 14), (5, 15), (4, 14)], fill=out)   # coda arricciata
        d.point((8, 3), fill=(10, 10, 20, 255))
        if active:
            d.point((1, 2), fill=(255, 255, 180, 255))
            d.point((11, 9), fill=(255, 255, 180, 255))
        frames.append(img)
    save(sheet(frames), "seahorse.png")

    img, d = canvas(32, 20)
    d.ellipse([24, 6, 31, 13], fill=(130, 190, 90, 255), outline=(40, 70, 30, 255))   # testa
    d.point((28, 8), fill=(10, 10, 20, 255))
    for x in (6, 20):
        d.rectangle([x, 14, x + 4, 19], fill=(130, 190, 90, 255), outline=(40, 70, 30, 255))
    d.pieslice([2, 2, 27, 26], 180, 360, fill=(120, 80, 40, 255), outline=(50, 30, 10, 255))
    for x in (8, 14, 20):
        d.rectangle([x - 2, 7, x + 2, 11], outline=(170, 120, 60, 255))
    d.rectangle([2, 13, 27, 15], fill=(210, 190, 120, 255), outline=(50, 30, 10, 255))
    save(img, "turtle.png")

    img, d = canvas(32, 12)
    d.polygon([(0, 6), (12, 1), (20, 1), (31, 6), (20, 9), (12, 9)],
              fill=(40, 60, 110, 255), outline=(15, 20, 45, 255))
    d.polygon([(10, 7), (16, 5), (22, 7), (16, 9)], fill=(220, 230, 240, 255))
    d.line([(16, 9), (16, 11)], fill=(15, 20, 45, 255))
    d.point((11, 3), fill=(255, 255, 255, 255))
    d.point((21, 3), fill=(255, 255, 255, 255))
    save(img, "manta.png")


# ------------------------------------------------------------------ tileset
def tiles():
    rnd = random.Random(7)
    img = Image.new("RGBA", (16 * 6, 16), (0, 0, 0, 0))

    def noise(x0, base, dark, light, n=18):
        for y in range(16):
            for x in range(16):
                img.putpixel((x0 + x, y), base)
        for _ in range(n):
            img.putpixel((x0 + rnd.randrange(16), rnd.randrange(16)), dark)
        for _ in range(n // 2):
            img.putpixel((x0 + rnd.randrange(16), rnd.randrange(16)), light)

    rock = ((70, 80, 110, 255), (45, 50, 75, 255), (100, 115, 150, 255))
    sand = ((225, 195, 125, 255), (190, 155, 90, 255), (245, 225, 170, 255))
    noise(0, *rock)                      # 0 roccia
    noise(16, *rock)                     # 1 roccia con alghe sopra
    for x in range(16):
        h = 2 + (x * 7 % 3)
        for y in range(h):
            img.putpixel((16 + x, y), (70, 170, 90, 255) if y < h - 1 else (40, 110, 60, 255))
    noise(32, *sand, n=10)               # 2 sabbia
    noise(48, *sand, n=10)               # 3 sabbia superficie
    for x in range(16):
        img.putpixel((48 + x, 0), (250, 240, 200, 255))
        img.putpixel((48 + x, 1), (245, 225, 170, 255))
    d = ImageDraw.Draw(img)              # 4 corallo (decorazione)
    d.line([(72, 15), (72, 6), (68, 2)], fill=(250, 110, 120, 255), width=2)
    d.line([(72, 9), (76, 4), (77, 1)], fill=(250, 110, 120, 255), width=2)
    d.line([(70, 12), (66, 8)], fill=(250, 110, 120, 255), width=1)
    for y in range(16):                  # 5 alga (decorazione)
        x = 88 + (1 if (y // 4) % 2 else -1)
        d.point((x, y), fill=(60, 160, 80, 255))
        d.point((x + 1, y), fill=(40, 120, 60, 255))
    save(img, "tiles.png")

    # roccia friabile (si rompe con la Chela Martello)
    r = img.crop((0, 0, 16, 16))
    d = ImageDraw.Draw(r)
    d.line([(3, 0), (6, 5), (4, 9), (8, 15)], fill=(20, 20, 30, 255))
    d.line([(6, 5), (12, 7), (15, 4)], fill=(20, 20, 30, 255))
    d.line([(4, 9), (0, 11)], fill=(20, 20, 30, 255))
    save(r, "rock_cracked.png")


if __name__ == "__main__":
    print("Genero sprite in", os.path.abspath(OUT))
    crab()
    claws()
    glider()
    pufferfish()
    jellyfish()
    piranha()
    small_things()
    characters()
    tiles()

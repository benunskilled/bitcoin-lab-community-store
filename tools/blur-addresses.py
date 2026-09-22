#!/usr/bin/env python3
"""Make peer addresses in a dashboard screenshot unreadable.

Every picture in the store uses the same blur, so they look alike:
a Gaussian blur, radius 9, over the address text only - the text's own
width plus 12 px on each side, and 26 px above and below the row centre.
Those numbers are for a 2940 px wide screenshot (a MacBook at 2x) and are
scaled to the picture's actual width.

The picture is saved as a full-colour PNG. Reducing it to a palette turned
the grey table rows green once, so that is not done here.

Usage:
  python3 blur-addresses.py IN.png OUT.png --rows X0:X1:Y [X0:X1:Y ...]
  python3 blur-addresses.py IN.png OUT.png --table X0:X1:YFIRST:YLAST:N

X0:X1 is the column the addresses sit in, Y the centre of one row, all in
pixels of IN.png. --table spreads N rows evenly from YFIRST to YLAST.
Both options can be repeated and mixed. Needs Pillow and numpy.
"""
import argparse
import sys

import numpy as np
from PIL import Image, ImageFilter

REF_WIDTH = 2940
PAD_X, HALF_H, RADIUS = 12, 26, 9


def text_extent(px, x0, x1, y0, y1):
    """Leftmost and rightmost column in the band that differs from the row
    background, or None if the band is empty."""
    band = px[y0:y1, x0:x1].astype(int)
    bg = np.median(band.reshape(-1, 3), axis=0)
    ink = np.abs(band - bg).sum(axis=2) > 60
    cols = np.where(ink.any(axis=0))[0]
    if cols.size == 0:
        return None
    return x0 + cols[0], x0 + cols[-1] + 1


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('src')
    ap.add_argument('dst')
    ap.add_argument('--rows', nargs='+', default=[], metavar='X0:X1:Y')
    ap.add_argument('--table', action='append', default=[], metavar='X0:X1:YFIRST:YLAST:N')
    a = ap.parse_args()

    rows = []
    for r in a.rows:
        x0, x1, y = map(int, r.split(':'))
        rows.append((x0, x1, y))
    for t in a.table:
        x0, x1, yf, yl, n = map(int, t.split(':'))
        step = (yl - yf) / (n - 1) if n > 1 else 0
        rows += [(x0, x1, round(yf + i * step)) for i in range(n)]
    if not rows:
        sys.exit('nothing to blur: give --rows or --table')

    im = Image.open(a.src).convert('RGB')
    s = im.width / REF_WIDTH
    pad, half, radius = round(PAD_X * s), round(HALF_H * s), RADIUS * s
    px = np.asarray(im)

    done = 0
    for x0, x1, y in rows:
        y0, y1 = max(0, y - half), min(im.height, y + half)
        ext = text_extent(px, x0, x1, y0, y1)
        if ext is None:
            print(f'no text found at y={y} in x {x0}-{x1}, skipped', file=sys.stderr)
            continue
        box = (max(0, ext[0] - pad), y0, min(im.width, ext[1] + pad), y1)
        im.paste(im.crop(box).filter(ImageFilter.GaussianBlur(radius)), box[:2])
        done += 1
        print('blurred', tuple(int(v) for v in box))

    im.save(a.dst, optimize=True)
    print(f'{done} of {len(rows)} rows blurred -> {a.dst}')


if __name__ == '__main__':
    main()

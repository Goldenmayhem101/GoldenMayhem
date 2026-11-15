#!/usr/bin/env python3
"""Build a single-file game: inline the Golden Mayhem kit and the offline fonts into the game's src.html.
usage: build.py <src.html> <out.html> <font-spec>...   font-spec = family:file.woff[:weight-range]"""
import base64, sys, pathlib
kit = pathlib.Path(__file__).parent
src, out, *fonts = sys.argv[1:]
faces = []
for spec in fonts:
    fam, f, *w = spec.split(':')
    b64 = base64.b64encode((kit / 'fonts' / f).read_bytes()).decode()
    weight = w[0] if w else '400'
    faces.append(f"@font-face{{font-family:'{fam}';src:url(data:font/woff;base64,{b64}) format('woff');font-weight:{weight};font-display:block}}")
html = pathlib.Path(src).read_text()
html = html.replace('/*FONTS*/', '\n'.join(faces), 1)
html = html.replace('/*KITCSS*/', (kit / 'kit.css').read_text(), 1)
html = html.replace('/*KITJS*/', (kit / 'kit.js').read_text(), 1)
pathlib.Path(out).write_text(html)
print(out, len(html) // 1024, 'KB')

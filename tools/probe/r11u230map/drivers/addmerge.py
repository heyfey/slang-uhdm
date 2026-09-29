#!/usr/bin/env python3
"""r11u230map addendum: the analysis at a later HEAD = the base analysis with every database the later integration
sweep moved re-analyzed (statejobs.py + analyze.py over that sweep against the base's HEAD sweep). Writes <add>/full/
corpus.jsonl + probe.jsonl (the later HEAD) and <add>/base_moved/ (the base's entries for the moved keys), so that
landing15.py <add>/full <add>/base_moved ... prints the later landings' movement, and report15.py can run on <add>/full.
Args: <base work W> <add dir>"""
import json, os, sys
W, A = sys.argv[1:3]
os.makedirs(f'{A}/full', exist_ok=True); os.makedirs(f'{A}/base_moved', exist_ok=True)
for f, mv, kf in (('corpus.jsonl', 'corpus_moved.jsonl', lambda r: (r['corpus'], r['mode'], r['test'])),
                  ('probe.jsonl', 'probe_moved.jsonl', lambda r: r['strict'])):
    moved = {kf(json.loads(l)): l for l in open(f'{A}/{mv}')}
    n = 0
    with open(f'{A}/full/{f}', 'w') as out, open(f'{A}/base_moved/{mv}', 'w') as bm:
        for l in open(f'{W}/{f}'):
            k = kf(json.loads(l))
            if k in moved: bm.write(l); continue
            out.write(l)
        for l in moved.values(): out.write(l); n += 1
    print(f, 'moved', n)

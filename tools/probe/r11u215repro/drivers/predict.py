#!/usr/bin/env python3
"""r11u215: the mover PREDICTION from a firing census (census.sh with R11U215_TRACE): every database on which a law
of this pass fired (`diag*` trace lines are diagnostics: a candidate seen, no byte written) is a predicted mover.
Keys: surelog/<mode>/<test>, uhdm2rtlil/<mode>/<test>, downstream/<test>, probe/<case>.
usage: predict.py <trace dir> <census workdir>  -> one line per predicted database: <key> <law>:<n> ..."""
import sys, os, collections
tr, wd = sys.argv[1:3]
rows = collections.defaultdict(collections.Counter)
for f in sorted(os.listdir(tr)):
    lines = open(os.path.join(tr, f)).read().splitlines()
    if not lines or not lines[0].startswith('OUT '):
        continue
    out = lines[0][4:]
    rel = os.path.relpath(out, wd).split('/')
    if rel[0] == 'probe':
        key = 'probe/' + rel[1][:-len('.uhdm')].replace('__', '/')
    elif rel[0] == 'downstream':
        key = 'downstream/' + rel[1]
    elif len(rel) >= 3:
        key = f"{rel[0]}/{rel[1]}/{rel[2].rsplit('-', 1)[0]}"
    else:
        key = out
    for l in lines[1:]:
        law = l.split(' ', 1)[0]
        if l.startswith('OUT ') or law.startswith('diag'):
            continue
        rows[key][law] += 1
for k in sorted(rows):
    print(k, ' '.join(f'{l}:{n}' for l, n in sorted(rows[k].items())))
print('PREDICTED', len(rows))

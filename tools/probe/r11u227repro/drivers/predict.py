#!/usr/bin/env python3
# (r11u227: copied from r11u224repro/drivers)
"""predict.py <trace dir> <census workdir> <out file>: the frozen mover prediction from the firing census
(census.sh, dscensus.py; r11u227repro: copied from r11u218dec, reads the .227 trace files). Each trace file's `OUT <db path>` names the database a process wrote; a process with at least one
firing predicts that database's row (corpus/mode/test, or probe/<case>) as a byte mover. Writes one line per
predicted mover: `<row> <law>:<count> ...`, sorted, then prints the file's md5 (the stamp). Fenced rows are
refused (fail-closed on $FENCED)."""
import os, re, sys, glob, collections, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict.py: source drivers/env.sh first')
TR, W, OUT = sys.argv[1:4]
rows = collections.defaultdict(collections.Counter)
for f in glob.glob(os.path.join(TR, "*.227")):
    lines = open(f).read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    out = lines[0][4:]
    rel = os.path.relpath(out, W)
    if rel.startswith('probe/'):
        row = 'probe/' + os.path.basename(out)[:-5].replace('__', '/')
    else:
        m = re.match(r'(surelog|uhdm2rtlil)/(default|testflags)/(.+)-[0-9a-f]{8}/slang\.uhdm$', rel)
        md = re.match(r'([^/]+)\.uhdm$', rel)  # dscensus.py's lanes
        if md and not m: row = 'downstream/' + md.group(1)
        elif not m: row = 'UNKNOWN:' + rel
        else: row = f'{m.group(1)}/{m.group(2)}/{m.group(3)}'
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(x)}(?![A-Za-z0-9_])', row) for x in F):
        sys.exit('predict.py: a fenced row in the census (refusing)')
    for l in lines[1:]:
        # § refChainDrainIdOrder227 writes one summary line per process; the database's bytes can move only when the
        # id order puts a loop's NEW symbols in another order than this run's address order (reorder > 0).
        if l.startswith('refChainDrainIdOrder227 ') and ' reorder=0' in l:
            continue
        rows[row][l.split(' ', 1)[0]] += 1
with open(OUT, 'w') as o:
    for r in sorted(rows):
        o.write(r + ' ' + ' '.join(f'{k}:{v}' for k, v in sorted(rows[r].items())) + '\n')
print(len(rows), 'predicted movers; md5', hashlib.md5(open(OUT, 'rb').read()).hexdigest())

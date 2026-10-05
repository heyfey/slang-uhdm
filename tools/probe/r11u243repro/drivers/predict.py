#!/usr/bin/env python3
# (r11u243: copied from r11u241repro/drivers)
# (r11u241: copied from r11u238repro/drivers)
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
"""predict.py <trace dir> <census workdir> <out file>: the frozen mover prediction from the firing census
(census.sh, dscensus.py; r11u243repro: copied from r11u218dec, reads the .243 trace files). Each trace file's `OUT <db path>` names the database a process wrote; a process with at least one
firing predicts that database's row (corpus/mode/test, or probe/<case>) as a byte mover. Writes one line per
predicted mover: `<row> <law>:<count> ...`, sorted, then prints the file's md5 (the stamp). Fenced rows are
refused (fail-closed on $FENCED)."""
import os, re, sys, glob, collections, hashlib
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict.py: source drivers/env.sh first')
TR, W, OUT = sys.argv[1:4]
rows = collections.defaultdict(collections.Counter)
for f in glob.glob(os.path.join(TR, "*.243")):
    lines = open(f).read().splitlines()
    if not lines or not lines[0].startswith('OUT '): continue
    out = lines[0][4:]
    rel = os.path.relpath(out, W)
    if rel.startswith('probe/'):
        row = 'probe/' + os.path.basename(out)[:-5].replace('__', '/')
    else:
        m = re.match(r'(surelog|uhdm2rtlil)/(default|testflags)/(.+)-[0-9a-f]{8}/slang\.uhdm$', rel)
        md = re.match(r'(?:ds/)?([^/]+)\.uhdm$', rel)  # dscensus.py's lanes (under <census workdir>/ds)
        if md and not m: row = 'downstream/' + md.group(1)
        elif not m: row = 'UNKNOWN:' + rel
        else: row = f'{m.group(1)}/{m.group(2)}/{m.group(3)}'
    if any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(x)}(?![A-Za-z0-9_])', row) for x in F):
        sys.exit('predict.py: a fenced row in the census (refusing)')
    for l in lines[1:]:
        # r11u238 (from r11u236repro): the memo-insert branch of pkgDefPatSubstShared236 (`first`) writes no byte by itself; it is
        # counted under its own tag so a database where only it fired is listed apart (not a mover).
        # r11u238: the drain's `_nohome` line writes nothing (the clone keeps its own binding).
        k = l.split(' ', 1)[0]
        if k.endswith('_nohome'): k += '.first'
        # r11u241: a `_shared` line is an abstention (the copy's object is bound outside the copy): it writes nothing.
        if k.endswith('_shared'): k += '.first'
        # r11u243: an `_abstain` or `_why` line of thisNetSurelogAnchor243 writes nothing (the old anchor stays).
        if k.endswith('_abstain') or k.endswith('_why'): k += '.first'
        rows[row][k] += 1
rows = {r: c for r, c in rows.items() if any(not k.endswith('.first') for k in c)}
with open(OUT, 'w') as o:
    for r in sorted(rows):
        o.write(r + ' ' + ' '.join(f'{k}:{v}' for k, v in sorted(rows[r].items())) + '\n')
print(len(rows), 'predicted movers; md5', hashlib.md5(open(OUT, 'rb').read()).hexdigest())

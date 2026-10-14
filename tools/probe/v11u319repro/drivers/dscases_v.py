#!/usr/bin/env python3
# (r11u319: copied from r11u317repro/drivers)
# (r11u317: copied from v11u315repro/drivers)
# v11u319 dscases_v.py (from r11u319repro dscases.py) <tag> <workroot> <case dir>...: the downstream verdict of each case (scripts/downstream_uhdm2rtlil.py
# one(), the slang lane on $SLANG_UHDM), one line per case: <rel> <tag> <verdict> <differs>. Fail-closed on $FENCED.
import os, re, sys
fz = os.environ.get('FENCED', '').split()
if len(fz) != 4: sys.exit('dscases.py: FENCED unset, refusing')
fr = re.compile(r'(?<![A-Za-z0-9_])(?:%s)(?![A-Za-z0-9_])' % '|'.join(map(re.escape, fz)))
here = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "r11u319repro", "drivers")
repo = os.path.abspath(os.path.join(here, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(repo, 'scripts'))
import downstream_uhdm2rtlil as ds
tag, wr = sys.argv[1], sys.argv[2]
for c in sys.argv[3:]:
    c = os.path.abspath(c)
    if fr.search(c): sys.exit('dscases.py: fenced path refused')
    rel = re.sub(r'.*/(?:v11u319repro|r11u319repro|[rv]11u317repro)/cases/', '', c)
    name = 'ds319_' + rel.replace('/', '_')
    r = ds.one(name, c, ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], os.path.join(wr, tag), 300)
    print(rel, tag, r['verdict'], 'differs=' + (r['differs'].replace(' ', ',') or '-'), 'sl=' + r['surelog_status'], 'sg=' + r['slang_status'], flush=True)

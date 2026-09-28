#!/usr/bin/env python3
"""r11u205 (copied from r11u203map/drivers/dsfaces.py; the fence read inline). r11u165 (r11u179: the fence from common.fenced()): the downstream-visible faces, measured with the gate's own machinery (scripts/downstream_uhdm2rtlil.py
one(): the Surelog lane is uhdm2rtlil's own Surelog with the downstream flags, the slang lane the translated command
line) on the evidence cases the passes left, with the binary in $SLANG_UHDM. Every case is a fresh repro under
tools/probe (none is a corpus test, none a slang-fenced one: the fence list is checked, fail closed). Use a fresh
GOLDEN_CACHE (the cache keys on directory + arguments, not content).
Args: <repo> <workroot> <out.csv> <case dir>..."""
import sys, os, re, csv
REPO, WORK, OUT = sys.argv[1:4]
sys.path.insert(0, os.path.join(REPO, 'scripts'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
FEN_LINE = [l for l in open(os.path.join(REPO, "tools/probe/r11u107repro/canaudit.sh")) if l.startswith("FENCED=")][0]
def fenced():
    n = re.sub(r"[\"']", "", FEN_LINE[len("FENCED="):]).split()
    assert len(n) == 4, "fence unreadable: refusing"
    return set(n)
fen = sorted(fenced())
import downstream_uhdm2rtlil as ds
rows = []
for d in sys.argv[4:]:
    assert not any(re.search(r'\b' + f + r'\b', d) for f in fen), d
    name = re.sub(r'[^A-Za-z0-9_]', '_', os.path.relpath(d, REPO))[-90:]
    r = ds.one(name, os.path.abspath(d), ['-parse', '-nobuiltin', '-nocache', '-sv', 'dut.sv'], WORK, 300)
    r['case'] = os.path.relpath(d, REPO); rows.append(r)
    print(r['case'], r['verdict'], r['surelog_status'], r['slang_status'], r['differs'], r['detail'][:80], flush=True)
with open(OUT, 'w', newline='') as f:
    w = csv.DictWriter(f, ['case', 'verdict', 'surelog_status', 'slang_status', 'surelog_gates', 'slang_gates', 'differs', 'detail', 'name'])
    w.writeheader(); [w.writerow(r) for r in rows]

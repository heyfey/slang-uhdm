#!/usr/bin/env python3
"""Job list for the strict map: every judge-equal row-mode whose strict cell is not `equal` (status STRICT_NOTEQUAL).
Args: <strict csv surelog> <strict csv u2r> <sweep workdir> <out.tsv>. The sweep workdir holds
<corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt}; cmds.txt names the golden cache dir and the binary.
Fence: a slang-fenced row is never dispatched and its databases are never opened (names from common.fenced(),
the FENCED= line of r11u107repro/canaudit.sh; fail closed); it is counted from the csv cell only."""
import csv, os, re, sys, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import fenced
FENCED = fenced()
sl, u2r, wd, out = sys.argv[1:5]
nfen = 0; dirs = {}
for c in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        for d in glob.glob(f'{wd}/{c}/{m}/*-*'):
            t = os.path.basename(d).rsplit('-', 1)[0]
            if t in FENCED: continue
            dirs[(c, m, t)] = d
n = bad = 0; bins = set()
with open(out, 'w') as f:
    for c, p in (('surelog', sl), ('uhdm2rtlil', u2r)):
        for r in csv.DictReader(open(p, newline='')):
            st = (r.get('strict') or '').strip()
            if r['status'].strip() not in ('CMP_EQUAL', 'STRICT_NOTEQUAL') or st in ('', 'equal'):
                continue
            if r['name'] in FENCED:
                nfen += 1; continue
            k = (c, r['mode'], r['name']); d = dirs.get(k)
            if not d: print('MISSING', k); bad += 1; continue
            cm = open(f'{d}/cmds.txt').read()
            g = re.search(r'golden cache (?:hit|stored?) (\S+?)\)', cm)
            b = re.search(r'^slang:\s+(\S+)', cm, re.M)
            bins.add(b.group(1) if b else '?')
            gp = f'{g.group(1)}/golden.uhdm' if g else ''
            if not os.path.exists(gp) or not os.path.exists(f'{d}/slang.uhdm'):
                print('NOFILE', k, gp); bad += 1; continue
            f.write('\t'.join([c, r['mode'], r['name'], gp, f'{d}/slang.uhdm', st]) + '\n'); n += 1
print('jobs', n, 'bad', bad, 'fenced_skipped', nfen, 'binaries', sorted(bins))

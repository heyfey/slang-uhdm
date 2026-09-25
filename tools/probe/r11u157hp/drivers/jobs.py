#!/usr/bin/env python3
"""Job list for the strict map (r11u138: since the strict flip c9e2923c a judge-equal,
strict-differ row reads STRICT_NOTEQUAL): every judge-equal row-mode whose strict cell is
not `equal`. Args: <strict csv surelog> <strict csv u2r> <sweep workdir> <out.tsv>.
The sweep workdir holds <corpus>/<mode>/<test>-<hash>/{slang.uhdm,cmds.txt};
cmds.txt names the golden cache dir (golden.uhdm inside it) and the binary."""
import csv, os, re, sys, glob
sl, u2r, wd, out = sys.argv[1:5]
# r11u156: fail-closed fence. The slang-fenced names are read from RESUME.md (never spelled here); a fenced row
# is never dispatched, its sweep databases are never read: it is listed FENCED from the committed csv cell only.
_R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'RESUME.md')
_t = open(_R).read()
FENCED = set(re.findall(r'`([A-Za-z_][A-Za-z0-9_]*)`', re.search(r'The four slang-fenced tests(.*?)are NEVER dispatched', _t, re.S).group(1)))
assert len(FENCED) == 4, 'fence list unreadable: refusing to run'
nfen = 0
dirs = {}
for c in ('surelog', 'uhdm2rtlil'):
    for m in ('default', 'testflags'):
        for d in glob.glob(f'{wd}/{c}/{m}/*-*'):
            t = os.path.basename(d).rsplit('-', 1)[0]
            dirs[(c, m, t)] = d
n = bad = 0
bins = set()
with open(out, 'w') as f:
    for c, p in (('surelog', sl), ('uhdm2rtlil', u2r)):
        for r in csv.DictReader(open(p, newline='')):
            st = (r.get('strict') or '').strip()
            if r['status'].strip() not in ('CMP_EQUAL', 'STRICT_NOTEQUAL') or st in ('', 'equal'):
                continue
            if r['name'] in FENCED:
                nfen += 1; continue
            k = (c, r['mode'], r['name'])
            d = dirs.get(k)
            if not d:
                print('MISSING', k); bad += 1; continue
            cm = open(f'{d}/cmds.txt').read()
            g = re.search(r'golden cache (?:hit|stored?) (\S+?)\)', cm)
            b = re.search(r'^slang:\s+(\S+)', cm, re.M)
            bins.add(b.group(1) if b else '?')
            gp = f'{g.group(1)}/golden.uhdm' if g else ''
            if not os.path.exists(gp) or not os.path.exists(f'{d}/slang.uhdm'):
                print('NOFILE', k, gp); bad += 1; continue
            f.write('\t'.join([c, r['mode'], r['name'], gp, f'{d}/slang.uhdm', st]) + '\n'); n += 1
print('jobs', n, 'bad', bad, 'fenced_skipped', nfen, 'binaries', sorted(bins))

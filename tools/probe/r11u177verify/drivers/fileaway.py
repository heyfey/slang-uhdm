#!/usr/bin/env python3
"""fileaway.py <wdA (off)> <wdB (on)> <corpus/mode/test>...: for one corpus row, the file facet order-blind: strict
records (uhdm-strictcmp --dump-a/--dump-b) of golden and of each sweep's database as multisets of (type, name, file);
a triple where the ON database holds MORE copies golden lacks than the OFF database is a facet moved AWAY (printed
with both excesses).  Fail-closed on $FENCED; a fenced row is refused unread."""
import os, re, sys, glob, subprocess, collections, tempfile
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('fileaway.py: source drivers/env.sh first')
SC = os.environ['STRICT_CMP']; A, B = sys.argv[1:3]
def recs(g, o):
    with tempfile.TemporaryDirectory(prefix='r11u177_fa') as t:
        subprocess.run([SC, '--max', '0', '--dump-a', f'{t}/a', '--dump-b', f'{t}/b', g, o], capture_output=True)
        def ms(p):
            c = collections.Counter()
            for l in open(p, errors='replace'):
                f = l.rstrip('\n').split('\t')
                if len(f) > 5: c[(f[1], f[2], f[5])] += 1
            return c
        return ms(f'{t}/a'), ms(f'{t}/b')
for r in sys.argv[3:]:
    t = r.split('/')[-1]
    if t in F: print(r, 'FENCED-REFUSED'); continue
    da = glob.glob(f'{A}/{r}-*')[0]; db = glob.glob(f'{B}/{r}-*')[0]
    cm = open(db + '/cmds.txt').read(); m = re.search(r'golden cache hit (\S+)\)', cm) or re.search(r'(/\S*slang-uhdm-goldens/[0-9a-f]+)', cm)
    g = m.group(1) + '/golden.uhdm'
    ga, oa = recs(g, da + '/slang.uhdm'); _, ob = recs(g, db + '/slang.uhdm')
    ea, eb = oa - ga, ob - ga
    away = {k: (ea[k], eb[k]) for k in eb if eb[k] > ea[k]}
    print(f'{r}: file-facet excess off={sum(ea.values())} on={sum(eb.values())}; triples moved AWAY: {len(away)} ({sum(b - a for a, b in away.values())} copies)', flush=True)
    for k, (x, y) in sorted(away.items(), key=lambda kv: -(kv[1][1] - kv[1][0]))[:8]: print('   ', k, 'off', x, 'on', y)

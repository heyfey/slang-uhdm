#!/usr/bin/env python3
# (v11u215: copied from tools/probe/r11u215repro/drivers; paths resolve through env.sh, scratch under /tmp/v11u215_*.)
"""r11u215: the chain-keyed away census of one database triple (the key of r11u211map's awayrows.py: each strict
record keyed by its ancestor chain `type:name < ...`, plus the flat record).  away = golden-agreeing records the
pristine database had and the law database lost; toward = the reverse.
usage: awaychain.py <golden.uhdm> <pristine.uhdm> <law.uhdm> [v]"""
import os, sys, subprocess, collections, tempfile
SC = os.environ.get('SCMP', '/tmp/v11u215_bin/uhdm-strictcmp')
def keyed(u):
    t = tempfile.mktemp(prefix='/tmp/v11u215_awc_')
    subprocess.run([SC, '--max', '0', '--dump-a', t, '--dump-b', '/dev/null', u, u], capture_output=True, timeout=3600)
    ck = collections.Counter(); st = []
    for l in open(t, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 3 or not f[0].isdigit(): continue
        d = int(f[0]); st = st[:d]
        ck[(' < '.join(reversed(st)), '|'.join(f[1:]))] += 1
        st.append(f'{f[1]}:{f[2]}')
    os.remove(t)
    return ck
G, O, N = (keyed(u) for u in sys.argv[1:4])
away = (O & G) - N; tow = (N & G) - O
print(f'chain away={sum(away.values())} toward={sum(tow.values())}')
if len(sys.argv) > 4:
    for k, v in away.items(): print('  AWAY', v, (k[1] + ' @ ' + k[0])[:300])

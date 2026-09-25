#!/usr/bin/env python3
# joint.py <corpus> <mode> <name> : the joint (two-landing) rows of the composition census, record by record.
# Strict records golden vs each of the four sweeps (P both on, A 145 off, B 146 off, O both off); the sets of
# differing record indices before any walk divergence. No cancellation: D_A and D_B are subsets of D_O (a
# landing alone never makes a record wrong that neither-landing had right) and D_P is a subset of D_A & D_B.
# Fail-closed on $FENCED.
import sys, os, subprocess, glob, re
FENCED = set(os.environ.get('FENCED', '').split())
if len(FENCED) != 4: sys.exit('joint.py: export FENCED first')
corpus, mode, name = sys.argv[1:4]
if name in FENCED: sys.exit(name + ' FENCED-SKIP')
SC = '/tmp/r11u153_bin/uhdm-strictcmp'; T = '/tmp/r11u153_joint'; os.makedirs(T, exist_ok=True)
R = {}
for w in 'PABO':
    d = glob.glob(f'/tmp/r11u153_sw{w}/{corpus}/{mode}/{name}-*')[0]
    g = re.search(r'golden cache hit (\S+)\)', open(d + '/cmds.txt').read()).group(1) + '/golden.uhdm'
    a, b = f'{T}/{name}.{mode}.{w}.a', f'{T}/{name}.{mode}.{w}.b'
    subprocess.run([SC, '--max', '1', '--dump-a', a, '--dump-b', b, g, d + '/slang.uhdm'], capture_output=True)
    R[w] = (open(a, errors='replace').read().split('\n'), open(b, errors='replace').read().split('\n'))
def div(ga, b):
    for i in range(min(len(ga), len(b))):
        if ga[i].split('\t')[:2] != b[i].split('\t')[:2]: return i
    return min(len(ga), len(b))
lim = min(div(*R[w]) for w in 'PABO')
D = {w: {i for i in range(lim) if R[w][0][i] != R[w][1][i]} for w in 'PABO'}
print(f'{name}/{mode} records<{lim}: |D_O|={len(D["O"])} |D_A|={len(D["A"])} |D_B|={len(D["B"])} |D_P|={len(D["P"])}',
      f'A-O={len(D["A"]-D["O"])} B-O={len(D["B"]-D["O"])} P-(A&B)={len(D["P"]-(D["A"]&D["B"]))}',
      f'O-A(fixed by 146 alone)={len(D["O"]-D["A"])} O-B(fixed by 145 alone)={len(D["O"]-D["B"])} overlap={len((D["O"]-D["A"])&(D["O"]-D["B"]))}',
      'NO-CANCELLATION' if not (D['A']-D['O']) and not (D['B']-D['O']) and not (D['P']-(D['A']&D['B'])) else 'CHECK')

#!/usr/bin/env python3
# v11u237: keepfold.py <case store dir>... : for golden, pri and law (case.sh outputs) print the kind and value of
# every ELABORATED cont_assign Rhs (the uhdm-dump block whose parent is a module_inst with a hierarchical name
# work@top.<inst>): func_call (the call kept) or constant (folded) with its value. Fail-closed on $FENCED.
import os, re, sys, glob, subprocess
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('keepfold.py: FENCED unset (source drivers/env.sh)')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, F)) + r')\b')
D = os.environ.get('UHDM_DUMP', '')
if not os.access(D, os.X_OK): sys.exit('keepfold.py: UHDM_DUMP not executable')
tags = os.environ.get('TAGS', 'pri law').split()
def rhs(u):
    out = subprocess.run([D, u], capture_output=True, text=True, errors='replace').stdout.split('\n')
    res = []
    for i, l in enumerate(out):
        if re.search(r'\\_(module_inst|interface_inst): \S+ \(work@top\.', l) and i + 1 < len(out) and out[i+1].strip() == '|vpiRhs:':
            k = out[i+2].strip()
            v = ''
            for j in range(i+3, min(i+9, len(out))):
                m = re.search(r'\|(UINT|INT|BIN|HEX|DEC):(\S+)', out[j])
                if m: v = m.group(0)[1:]; break
            res.append(k.split(',')[0].replace('\\_', '') + (' ' + v if v else ''))
    return '; '.join(res) or '-'
for d in sys.argv[1:]:
    if fre.search(d): sys.exit('keepfold.py: fenced path refused')
    g = glob.glob(d + '/gold_*/golden.uhdm')
    row = [d.split('/g/')[-1], 'gold=' + (rhs(g[0]) if g else 'NONE')]
    for t in tags:
        p = f'{d}/{t}.uhdm'
        row.append(f'{t}=' + (rhs(p) if os.path.exists(p) else 'NONE'))
    print(' | '.join(row))

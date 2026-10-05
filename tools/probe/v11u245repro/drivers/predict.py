#!/usr/bin/env python3
# (v11u245: copied from r11u245repro/drivers)
"""(r11u245) predict.py <pristine sweep workdir> <out>: the byte-mover predictor of pass 245, written after the last law
and frozen before the law sweep.  Every r11u245 law reads a COMPILATION-UNIT ($unit) typedef: the listing writers
(§ unitPredefTd245, § unitPredefAliasOfAlias245, § unitArrTd245) fire on a $unit typedef of a predefined kind or a fixed
unpacked array; the binding laws (§ unitTdLawS245, § unitTdRetVarAtTypeToken245, § unitRealTdElabShares245) rebind
uses of a $unit typedef's design listing object.  Trigger, read from the PRISTINE database: the design lists a
top-level typedef (`|vpiTypedef:` under the design) whose vpiInstance is the design itself (a file-scope import's
package typedef is listed there too but its vpiInstance is its package) of a kind the laws read (logic, bit, the
integer atoms, string, real, shortreal, time, array; a nettype of such a kind is over-predicted), or the pristine run
exited with the
unsupported `typedef target:` note (no listing at all: the predefined and array kinds).  Every corpus (surelog,
uhdm2rtlil), probe and downstream slang-lane database is read; a path naming a fenced test is skipped unread
(fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess
from concurrent.futures import ThreadPoolExecutor
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict.py: source drivers/env.sh first (FENCED)')
D = os.environ.get('UHDM_DUMP', '')
if not os.access(D, os.X_OK): sys.exit('predict.py: UHDM_DUMP not executable')
W, OUT = sys.argv[1:3]
# the listing kinds the laws read (§ unitTdLawS245's set; a struct, enum, union or class typedef is untouched)
KINDS = {'logic_typespec', 'bit_typespec', 'int_typespec', 'integer_typespec', 'byte_typespec', 'short_int_typespec',
         'long_int_typespec', 'string_typespec', 'real_typespec', 'short_real_typespec', 'time_typespec', 'array_typespec'}
def fenced(p): return any(re.search(rf'(?<![A-Za-z0-9_]){re.escape(f)}(?![A-Za-z0-9_])', p) for f in F)
jobs = []
for p in sorted(glob.glob(f'{W}/probe/*.uhdm')): jobs.append(('probe/' + os.path.basename(p)[:-5].replace('__', '/'), p, None))
for c in ('surelog', 'uhdm2rtlil'):
    for d in sorted(glob.glob(f'{W}/{c}/*/*/')):
        rel = os.path.relpath(d, W)
        if fenced(rel): continue
        p = d + 'slang.uhdm'
        if os.path.exists(p): jobs.append((re.sub(r'-[0-9a-f]+$', '', rel), p, d + 'cmds.txt'))
for d in sorted(glob.glob(f'{W}/downstream/*/')):
    rel = os.path.relpath(d, W)
    if fenced(rel): continue
    p = d + 'slang.uhdm'
    if os.path.exists(p): jobs.append((rel, p, None))
def one(j):
    name, p, log = j
    why = []
    for lg in ([log] if log else []) + [p[:-5] + '.log']:
        try:
            if lg and 'typedef target:' in open(lg, errors='replace').read(): why.append('note'); break
        except OSError: pass
    try:
        out = subprocess.run(f'"{D}" "{p}" 2>/dev/null | awk \'/^\\|uhdmtopModules:/{{exit}} {{print}}\'',
                             shell=True, capture_output=True, text=True, timeout=1800).stdout.split('\n')
    except subprocess.TimeoutExpired:
        return (name, 'TIMEOUT')
    i = 0
    while i < len(out):
        if out[i] == '|vpiTypedef:' and i + 1 < len(out) and out[i + 1].startswith('\\_'):
            hdr = out[i + 1]; k = i + 2; inst = None
            while k < len(out) and out[k].startswith('  '):
                if out[k] == '  |vpiInstance:' and k + 1 < len(out): inst = out[k + 1]
                k += 1
            kind = hdr[2:].split(':')[0]
            if inst and inst.startswith('  \\_design:') and kind in KINDS:
                why.append(hdr.split(',')[0][2:])
            i = k
        else: i += 1
    return (name, ' '.join(why)) if why else None
with ThreadPoolExecutor(int(os.environ.get('J', '3'))) as ex:
    res = [r for r in ex.map(one, jobs) if r]
with open(OUT, 'w') as f:
    for n, w in sorted(res): f.write(f'{n}\t{w}\n')
print(f'read={len(jobs)} predicted={len(res)}')

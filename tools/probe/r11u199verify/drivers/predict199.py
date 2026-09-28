#!/usr/bin/env python3
"""predict199.py <trace dir> <out>: the PREDICTION (clone refinements from the pass-193 trace; the call-root refinement
from the pass-192 trace: every database where § genForWholeLhsNestedKeep192v declined) of the r11u199 clone refinements' byte movers, from the HEAD binary's
pass-193 trace (census193.sh) and the HEAD databases it wrote, BEFORE any fix sweep.  The two refinements act only inside
§ caUnsizedRhsClonePerInst193's drain, on a cloned continuous assignment whose tree holds (a) a var_select (UCVARSEL) or
(b) a constant / operation typespec reference named exactly a definition's full name, no `.` after `work@...`
(UCOWNER).  Per database where the clone law fired: uhdm-dump, every elaborated cont_assign at a traced line:col under
any instance (the instance name is not matched: an upper bound); a database is predicted when such a block holds (a) or (b).  An upper bound
(a clone whose var_select is not definition-named moves nothing).  Fenced paths are refused (fail-closed on $FENCED)."""
import os, re, sys, glob, subprocess, collections
FEN = os.environ.get('FENCED', '').split()
if len(FEN) != 4: sys.exit('predict199.py: source drivers/env.sh first')
DUMP = os.environ['UHDM_DUMP']
tr, out = sys.argv[1:3]
fires = collections.defaultdict(set)
for f in glob.glob(f'{tr}/*.193'):
    L = open(f, errors='replace').read().splitlines()
    if not L or not L[0].startswith('OUT '): continue
    db = L[0][4:].strip()
    for l in L[1:]:
        p = l.split()
        if p and p[0] == 'caUnsizedRhsClonePerInst193' and len(p) >= 3: fires[db].add((p[1], p[2]))
# § genForWholeLhsCallRootOwner199v acts only where § genForWholeLhsNestedKeep192v declines (the pass-192 trace).
wl = set()
for f in glob.glob(f'{tr}/*.EX192'):
    L = open(f, errors='replace').read().splitlines()
    if L and L[0].startswith('OUT ') and any(l.strip() == 'genForWholeLhsNestedKeep192v' for l in L[1:]): wl.add(L[0][4:].strip())
res = []; nfen = 0
for db in sorted(wl):
    if any(re.search(rf'\b{re.escape(n)}\b', db) for n in FEN): nfen += 1; continue
    res.append((db, 'PREDICTED', 'GFCALLROOT(192v fired)'))
for db, sites in sorted(fires.items()):
    if any(re.search(rf'\b{re.escape(n)}\b', db) for n in FEN): nfen += 1; continue
    if not os.path.exists(db): res.append((db, 'MISSING', '')); continue
    L = subprocess.run([DUMP, db], capture_output=True, text=True, errors='replace').stdout.splitlines()
    hits = collections.Counter(); stack = []
    for i, l in enumerate(L):
        ind = len(l) - len(l.lstrip())
        while stack and stack[-1][0] >= ind: stack.pop()
        s = l.strip()
        m = re.match(r'\\_module_inst: \S+ \((\S+)\)', s) or re.match(r'\\_interface_inst: \S+ \((\S+)\)', s)
        if m: stack.append((ind, 'inst', m.group(1))); continue
        m = re.match(r'\\_cont_assign: , line:(\d+):(\d+)', s)
        if m:
            insts = [x[2] for x in stack if x[1] == 'inst']
            ok = bool(insts) and f'{m.group(1)}:{m.group(2)}' in {x[1] for x in sites}
            stack.append((ind, 'ca' if ok else 'caX', '')); continue
        if any(x[1] == 'ca' for x in stack):
            if s.startswith('\\_var_select:'): hits['UCVARSEL'] += 1
            if re.match(r'\\_ref_typespec: \(work@[^.)]*\)$', s): hits['UCOWNER'] += 1
    res.append((db, 'PREDICTED' if hits else 'no', ' '.join(f'{k}={v}' for k, v in sorted(hits.items()))))
with open(out, 'w') as o:
    for db, v, h in res: o.write(f'{v} {db} {h}\n')
    o.write(f'wholelhs192v_fired_databases={len(wl)} clone_fired_databases={len(fires)} fenced_skipped={nfen} predicted={sum(1 for r in res if r[1]=="PREDICTED")}\n')
print(open(out).read().splitlines()[-1])

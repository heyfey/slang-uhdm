#!/usr/bin/env bash
# r10buvm8repro/attrib8.sh — ATTRIBUTE ONE MOVER: the golden <-> pristine <->
# patched join over the ELABORATED package listing's call arguments, restricted
# to the cell the law claims.
#
#   usage: attrib8.sh <patched_wd> <pristine_wd> <relpath-of-slang.uhdm>
#
# LHS is ALWAYS golden.  Every argument is keyed on (line:col, callee, formal
# position) so the three databases join without any id assumption.
#
# The four verdicts, and why each is separate:
#   CONVERTED     golden TS, pristine bare, patched TS      -> distance DOWN
#   REPOINTED     all three TS, our ACTUAL's ROLE corrected -> distance DOWN,
#                 invisible to a dump (both copies print the same file:line)
#   EXTRA         golden bare, patched TS                   -> distance UP
#   NOGOLDEN      golden has NO row here at all (its elab copy of the call
#                 folded to a constant) -> the object was ALREADY extra; the
#                 stamp changes nothing about that
# A verdict that cannot be computed prints UNJOINED and is COUNTED.
set -u
A=${1:?patched wd}; B=${2:?pristine wd}; R=${3:?relpath}
CEN=${R10BUVM8CEN:-/tmp/r10buvm8cen}
d=$(dirname "$A/$R")
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "FATAL: no golden for $R"; exit 3; }
"$CEN" "$G"    G > /tmp/r10buvm8_at_g.txt 2>/dev/null
"$CEN" "$B/$R" P > /tmp/r10buvm8_at_p.txt 2>/dev/null
"$CEN" "$A/$R" Q > /tmp/r10buvm8_at_q.txt 2>/dev/null
python3 - "$R" <<'PY'
import sys, collections
rel=sys.argv[1]
CELL='ELABPKG/RETTOP/PKGFN/BOUND'
def load(f):
    d={}
    for l in open(f):
        if not l.startswith('ARG '): continue
        kv=dict(x.split('=',1) for x in l.split() if '=' in x)
        if kv.get('cell')!=CELL: continue
        if kv.get('call')!='func_call': continue
        d[(l.split()[2],kv['callee'],kv['pos'])]=kv
    return d
G=load('/tmp/r10buvm8_at_g.txt'); P=load('/tmp/r10buvm8_at_p.txt'); Q=load('/tmp/r10buvm8_at_q.txt')
# THE FORMAL-SIDE ROLE OF AN ACTUAL: which task_func's io_decl owns the typespec
# the actual points at, and whether THAT task_func lives in the same (elab)
# listing.  This is what makes REPOINTED measurable without ids.
def roles(f):
    r={}
    for l in open(f):
        if not l.startswith('IODECL '): continue
        kv=dict(x.split('=',1) for x in l.split() if '=' in x)
        r.setdefault(kv['actid'],[]).append((kv['tf'],kv['tfid'],kv['pos']))
    return r
RG=roles('/tmp/r10buvm8_at_g.txt'); RP=roles('/tmp/r10buvm8_at_p.txt'); RQ=roles('/tmp/r10buvm8_at_q.txt')
v=collections.Counter()
lines=[]
for k in sorted(set(list(G)+list(P)+list(Q))):
    g=G.get(k); p=P.get(k); q=Q.get(k)
    gt = g and g['TS']=='yes'; pt = p and p['TS']=='yes'; qt = q and q['TS']=='yes'
    if g is None:
        verdict='NOGOLDEN' if qt and not pt else ('NOGOLDEN-REPOINT' if qt and pt else 'NOGOLDEN-bare')
    elif gt and not pt and qt: verdict='CONVERTED'
    elif gt and pt and qt:
        verdict='REPOINTED' if p['actid']!=q['actid'] else 'ALREADY'
    elif gt and not qt: verdict='RESIDUE'
    elif (not gt) and qt: verdict='EXTRA'
    else: verdict='BARE-BOTH'
    v[verdict]+=1
    lines.append("%-14s %-28s %-5s %-11s g=%-4s p=%-4s q=%-4s grole=%s qrole=%s %s"%(
        k[0],k[1],k[2], (q or p or g)['arg'],
        'TS' if gt else '-', 'TS' if pt else '-', 'TS' if qt else '-',
        RG.get(g['actid'],'-') if g and gt else '-',
        RQ.get(q['actid'],'-') if q and qt else '-', verdict))
print("== %s   cells=%d"%(rel,len(lines)))
for l in lines: print("   "+l)
print("   VERDICTS: "+" ".join("%s=%d"%(a,b) for a,b in sorted(v.items())))
PY

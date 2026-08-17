#!/usr/bin/env bash
# r10buvm8repro/grid8.sh — THE GRID: golden vs PRISTINE vs PATCHED, one row per
# call ARGUMENT of an arm source, joined on the argument's own line:col.
#
#   usage: PRISTINE=/abs/pristine PATCHED=/abs/patched ./grid8.sh v1_argts8.sv
#
# GUARDS:
#   * BOTH binaries are named explicitly and their md5s printed; there is no
#     default, because a stale-binary reading has burned this campaign.
#   * each binary gets its OWN arm workdir, so the two databases can never be
#     the same file.
#   * a cell present on one side and not the other prints MISSING and is
#     COUNTED — a join that silently dropped rows would read as agreement.
#   * the census instrument is REBUILT here, so the table can never come from an
#     older r10buvm8cen than the source in this directory.
set -u
D=$(cd "$(dirname "$0")" && pwd)
SRC=${1:?arm source}
B=$(basename "$SRC"); B=${B%.*}
: "${PRISTINE:?set PRISTINE}"; : "${PATCHED:?set PATCHED}"
"$D/build8.sh" >/dev/null || exit 3
echo "PRISTINE $PRISTINE md5=$(md5sum "$PRISTINE" | cut -d' ' -f1)"
echo "PATCHED  $PATCHED  md5=$(md5sum "$PATCHED"  | cut -d' ' -f1)"
SLANG_UHDM=$PRISTINE "$D/arm8.sh" "$SRC" "/tmp/r10buvm8_grid_${B}_pri" >/dev/null || exit 4
SLANG_UHDM=$PATCHED  "$D/arm8.sh" "$SRC" "/tmp/r10buvm8_grid_${B}_pat" >/dev/null || exit 4
/tmp/r10buvm8cen "/tmp/r10buvm8_grid_${B}_pri/slpp_all/surelog.uhdm" G > "/tmp/r10buvm8_grid_${B}_g.txt"
/tmp/r10buvm8cen "/tmp/r10buvm8_grid_${B}_pri/slang.uhdm"            P > "/tmp/r10buvm8_grid_${B}_p.txt"
/tmp/r10buvm8cen "/tmp/r10buvm8_grid_${B}_pat/slang.uhdm"            Q > "/tmp/r10buvm8_grid_${B}_q.txt"
python3 - "$B" <<'PY'
import sys, collections
b=sys.argv[1]
def load(tag,f):
    d={}
    for l in open(f):
        if not l.startswith('ARG '): continue
        kv=dict(x.split('=',1) for x in l.split() if '=' in x)
        loc=l.split()[2]
        # ONE ROW PER (loc, callee, pos): a def/elab twin pair shares all three,
        # so the two views are folded into ONE cell whose value is the SET of
        # the two views' answers -- printed as `TS`/`-`/`TS+-` so a view-only
        # stamp can never be read as a whole-cell stamp.
        k=(loc,kv['callee'],kv['pos'])
        d.setdefault(k,[]).append('TS' if kv['TS']=='yes' else '-')
        d[k+('arg',)]=kv['arg']
        d[k+('act',)]=kv.get('act','-')
    return d
G=load('G','/tmp/r10buvm8_grid_%s_g.txt'%b)
P=load('P','/tmp/r10buvm8_grid_%s_p.txt'%b)
Q=load('Q','/tmp/r10buvm8_grid_%s_q.txt'%b)
def lk(k):
    # loc is `<l>:<c>-<l>:<c>`; sort by the START line then the START column.
    a=k[0].split('-')[0].split(':')
    return (int(a[0]), int(a[1]), k[1], k[2])
keys=sorted({k for k in list(G)+list(P)+list(Q) if len(k)==3}, key=lk)
def cell(d,k):
    if k not in d: return 'MISSING'
    return '+'.join(sorted(set(d[k])))
print("%-14s %-22s %-6s %-13s %-9s %-9s %-9s %s"%("LOC","CALLEE","POS","ARG","GOLDEN","PRISTINE","PATCHED","ACT(golden)"))
conv=hold=over=miss=0
for k in keys:
    g,p,q=cell(G,k),cell(P,k),cell(Q,k)
    mark=''
    if g!=p and g==q: conv+=1; mark='  <= CONVERTED'
    elif g!=q and g==p: over+=1; mark='  <= MOVED AWAY'
    elif 'MISSING' in (g,p,q): miss+=1; mark='  (missing side)'
    print("%-14s %-22s %-6s %-13s %-9s %-9s %-9s %s%s"%(k[0],k[1],k[2],
          G.get(k+('arg',),P.get(k+('arg',),'-')),g,p,q,G.get(k+('act',),'-'),mark))
print("-- cells=%d CONVERTED=%d MOVED-AWAY=%d missing-side=%d"%(len(keys),conv,over,miss))
PY

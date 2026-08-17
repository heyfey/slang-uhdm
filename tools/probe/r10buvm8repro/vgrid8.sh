#!/usr/bin/env bash
# vbuvm8 verifier grid, SAME-CWD variant: a UHDM database records the source's
# ABSOLUTE path, so the two binaries MUST run in one directory or every cmp log
# differs on the path alone (the trap bndarms8.sh also hit).
set -u
SRC=${1:?arm source}
SRC=$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")
B=$(basename "$SRC"); B=${B%.*}
: "${PRISTINE:?}"; : "${PATCHED:?}"
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=${CEN:-/tmp/vbuvm8_cen}; VCEN=${VCEN:-/tmp/vbuvm8_vcen}
D=/tmp/vbuvm8_wd_$B
rm -rf "$D"; mkdir -p "$D"; cp "$SRC" "$D/"
cd "$D" || exit 9
"$SURELOG" -parse -nocache -mt 0 -mp 0 "$B.sv" >sl.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -5 sl.log; exit 5; }
"$PRISTINE" "$B.sv" -o pri.uhdm >pri.log 2>&1
"$PATCHED"  "$B.sv" -o pat.uhdm >pat.log 2>&1
for f in pri.uhdm pat.uhdm; do [ -f $f ] || { echo "NO_OUTPUT $B $f"; exit 6; }; done
PL=$($CMP slpp_all/surelog.uhdm pri.uhdm 2>&1); QL=$($CMP slpp_all/surelog.uhdm pat.uhdm 2>&1)
PH=$(printf '%s\n' "$PL" | grep -c '^LHS:'); QH=$(printf '%s\n' "$QL" | grep -c '^LHS:')
[ -z "$PL" ] && PH=0; [ -z "$QL" ] && QH=0
printf '%s\n' "$PL" > cmp_pri.log; printf '%s\n' "$QL" > cmp_pat.log
V=SAME; [ "$PL" != "$QL" ] && V=DIFF
echo "ARM $B  cmp heads pri=$PH pat=$QH  lines pri=$(printf '%s' "$PL"|grep -c '' ) pat=$(printf '%s' "$QL"|grep -c '')  cmplog=$V"
if [ "$PH" = 0 ] && [ "$QH" != 0 ]; then echo "  *** REGRESSION: pristine CMP_EQUAL -> patched CMP_NOTEQUAL ***"; fi
if [ "$QH" = 0 ] && [ "$PH" != 0 ]; then echo "  +++ FIXED: pristine CMP_NOTEQUAL -> patched CMP_EQUAL +++"; fi
$DUMP slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
$DUMP pri.uhdm 2>/dev/null | sed 1d > p.dump
$DUMP pat.uhdm 2>/dev/null | sed 1d > q.dump
echo "  dump-vs-golden: pri $(diff g.dump p.dump | grep -cE '^[<>]') lines, pat $(diff g.dump q.dump | grep -cE '^[<>]') lines"
$CEN slpp_all/surelog.uhdm G > g.cen; $CEN pri.uhdm P > p.cen; $CEN pat.uhdm Q > q.cen
$VCEN slpp_all/surelog.uhdm G > g.vcen; $VCEN pri.uhdm P > p.vcen; $VCEN pat.uhdm Q > q.vcen
python3 - <<'PY'
def load(f):
    d={}
    for l in open(f):
        if not l.startswith('ARG '): continue
        kv=dict(x.split('=',1) for x in l.split() if '=' in x)
        loc=l.split()[2]; k=(loc,kv['callee'],kv['pos'])
        d.setdefault(k,[]).append('TS' if kv['TS']=='yes' else '-')
        d[k+('arg',)]=kv['arg']; d[k+('cell',)]=kv.get('cell','-')
    return d
G=load('g.cen'); P=load('p.cen'); Q=load('q.cen')
def lk(k):
    a=k[0].split('-')[0].split(':'); return (int(a[0]),int(a[1]),k[1],k[2])
keys=sorted({k for k in list(G)+list(P)+list(Q) if len(k)==3}, key=lk)
def cell(d,k): return 'MISSING' if k not in d else '+'.join(sorted(set(d[k])))
conv=away=miss=0; rows=[]
for k in keys:
    g,p,q=cell(G,k),cell(P,k),cell(Q,k); m=''
    if g!=p and g==q: conv+=1; m='  <=CONVERTED'
    elif g!=q and g==p: away+=1; m='  <=MOVED-AWAY'
    elif 'MISSING' in (g,p,q): miss+=1; m='  (missing side)'
    rows.append("  %-14s %-20s %-4s %-12s G=%-8s P=%-8s Q=%-8s%s"%(k[0],k[1],k[2],
        G.get(k+('arg',),P.get(k+('arg',),'-')),g,p,q,m))
print('\n'.join(rows))
print("  -- cells=%d CONVERTED=%d MOVED-AWAY=%d missing-side=%d"%(len(keys),conv,away,miss))
PY
echo "  WD=$D"

#!/usr/bin/env bash
# v80_arm.sh <arm.sv> — golden + pris + pat in ONE scratch dir, then the
# AUTHORITATIVE per-object join: R10UVM80_LIST=1 census on all three, joined on
# (line:col, fullname) as a MULTISET, printing every cell's vpiAutomatic on all
# three sides.  A cell present on one side only is printed, never dropped.
set -u
SRC=${1:?arm source}
PAT=${PAT:?}
PRI=${PRI:?}
CEN=${CEN:-/tmp/v80cen}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v80_arm_$B
rm -rf "$D"; mkdir -p "$D" || exit 9
cp "$SRC" "$D/" || exit 9
LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; grep -iE 'error|fatal' surelog.log | head -12; exit 5; }
grep -cE '^\[(ERR|FTL)' surelog.log >/dev/null
echo "== $B  surelog errors: $(grep -cE '\[(ERR|FTL):' surelog.log; true)"
for tag in pris pat; do
  bin=$PRI; [ $tag = pat ] && bin=$PAT
  "$bin" "$LEAF" -o $tag.uhdm > $tag.log 2>&1
  if [ ! -f $tag.uhdm ]; then echo "NO_OUTPUT $B/$tag"; tail -5 $tag.log; continue; fi
  res=$("$CMP" slpp_all/surelog.uhdm $tag.uhdm >$tag.cmp 2>&1 && echo PASS_CMP || echo CMP_FAIL)
  "$DUMP" $tag.uhdm 2>/dev/null | sed 1d > $tag.dump
  echo "$B/$tag: $res cmpheads=$(grep -c '^LHS:' $tag.cmp; true)"
done
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed 1d > g.dump
for tag in g pris pat; do
  f=slpp_all/surelog.uhdm; [ $tag = pris ] && f=pris.uhdm; [ $tag = pat ] && f=pat.uhdm
  [ -f "$f" ] || continue
  R10UVM80_LIST=1 "$CEN" "$f" $tag 2>/dev/null | grep '^VAR' > cen.$tag
done
echo "-- counts: g=$(wc -l < cen.g) pris=$(wc -l < cen.pris) pat=$(wc -l < cen.pat)"
python3 - "$D" <<'PY'
import sys, collections
d=sys.argv[1]
def load(t):
    m=collections.Counter(); info={}
    for ln in open(f"{d}/cen.{t}"):
        p=ln.rstrip("\n").split("\t")
        # VAR tag file line:col auto kind parentkind fullname
        key=(p[3], p[7])
        m[(key,p[4],p[5])]+=1
        info.setdefault(key,[]).append((p[4],p[5],p[6]))
    return m,info
G,gi=load("g"); P,pi=load("pris"); A,ai=load("pat")
keys=sorted(set(k for (k,_,_) in G)|set(k for (k,_,_) in P)|set(k for (k,_,_) in A),
            key=lambda x:(x[1],x[0]))
def fmt(info,k):
    v=info.get(k)
    if v is None: return "-"
    return ",".join(f"{a}/{kd}" for a,kd,_ in sorted(v))
hdr=f"{'loc':>10} {'golden':>22} {'pris':>22} {'pat':>22}  fullname"
print(hdr); print("-"*len(hdr))
bad=0; fixed=0; same=0
for k in keys:
    g,p,a=fmt(gi,k),fmt(pi,k),fmt(ai,k)
    mark=""
    if g!=a: mark=" <<< PAT!=GOLDEN"
    if p==g and a!=g: mark=" <<<<<< REGRESSION pris-right pat-wrong"; bad+=1
    elif p!=g and a==g: fixed+=1
    elif g==a: same+=1
    print(f"{k[0]:>10} {g:>22} {p:>22} {a:>22}  {k[1]}{mark}")
print(f"\nSUMMARY {d}: agree={same} fixed={fixed} REGRESSIONS={bad} total_keys={len(keys)}")
PY
echo "WD=$D"

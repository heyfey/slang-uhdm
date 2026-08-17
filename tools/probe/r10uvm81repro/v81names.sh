#!/usr/bin/env bash
# r10uvm81 VERIFIER — per-NAME arm judge (law 2's instrument), plus a per-name
# CLASSIFICATION so a "distance went down" can never hide a name golden lacks.
#   PAT=.. PRI=.. v81names.sh <arm.sv> [name-substring-filter]
set -u
SRC=${1:?arm source}
FILT=${2:-}
PAT=${PAT:?patched}; PRI=${PRI:?pristine}
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CEN=${CEN:-/tmp/r10uvm81cen}
B=$(basename "$SRC"); B=${B%.*}
D=/tmp/v81_names_$B
rm -rf "$D"; mkdir -p "$D"; cp "$SRC" "$D/"; LEAF=$(basename "$SRC")
cd "$D" || exit 9
"$SURELOG" -parse -nocache "$LEAF" >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo "SURELOG_FAIL $B"; tail -8 surelog.log; exit 5; }
"$PRI" "$LEAF" -o pris.uhdm >pris.log 2>&1 || true
"$PAT" "$LEAF" -o pat.uhdm  >pat.log  2>&1 || true
for f in pris.uhdm pat.uhdm; do [ -f "$f" ] || { echo "NO_OUTPUT $f"; tail -5 "${f%.uhdm}.log"; exit 6; }; done
R10UVM81_NAMES=1 "$CEN" slpp_all/surelog.uhdm g > g.n 2>/dev/null
R10UVM81_NAMES=1 "$CEN" pris.uhdm            a > a.n 2>/dev/null
R10UVM81_NAMES=1 "$CEN" pat.uhdm             b > b.n 2>/dev/null
python3 - "$B" "$FILT" <<'PY'
import collections,sys
tag,filt=sys.argv[1],sys.argv[2]
def rd(p):
    c=collections.Counter()
    for ln in open(p,errors='replace'):
        if ln.startswith('NAME\t'): c[ln[5:].rstrip('\n')]+=1
    return c
g,a,b=rd('g.n'),rd('a.n'),rd('b.n')
d=lambda x,y: sum(abs(x[k]-y[k]) for k in set(x)|set(y))
newbad=sorted(k for k in b if b[k]>g.get(k,0) and b[k]>a.get(k,0))
fixed=sorted(k for k in g if g[k]>a.get(k,0) and b.get(k,0)>a.get(k,0))
still=sorted(k for k in g if g[k]>b.get(k,0))
print(f"{tag}: objects g={sum(g.values())} pris={sum(a.values())} pat={sum(b.values())} "
      f"| NAME-dist pris={d(g,a)} pat={d(g,b)} | new-names-golden-LACKS={len(newbad)} "
      f"| golden-names-newly-produced={len(fixed)}")
for k in newbad: print("   NEWBAD ",k)
for k in fixed:  print("   FIXED  ",k)
if filt:
    print("  --- names matching %r ---"%filt)
    for k in sorted(set(g)|set(a)|set(b)):
        if filt not in k: continue
        if g.get(k,0)==a.get(k,0)==b.get(k,0): continue
        print(f"    g={g.get(k,0)} pris={a.get(k,0)} pat={b.get(k,0)}  {k}")
PY
echo "WD=$D"

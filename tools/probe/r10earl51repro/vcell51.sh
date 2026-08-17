#!/usr/bin/env bash
# v51 VERIFIER cell reader: run ONE arm source with BOTH binaries and print, per
# elaborated cont_assign span, GOLDEN / PRISTINE / PATCHED rhs shape.
#
#   usage: vcell.sh /abs/x.sv <tag>
#
# GUARDS: a missing dump is FATAL (never "no rows"); golden is read from the
# PATCHED run's workdir AND from the PRISTINE run's workdir and the two are
# required to agree (Surelog is run twice; a golden that differs between the two
# runs would silently make every reading meaningless).
set -u
SRC=${1:?src}; TAG=${2:?tag}
PAT=${PAT:-/tmp/wt_v51/build/slang-uhdm}
PRIS=${PRIS:-/tmp/wt_v51pris/build/slang-uhdm}
HERE=$(cd "$(dirname "$0")" && pwd)
CG=${CG:-$HERE/castgrid51.py}
VARM=${VARM:-$HERE/varm.sh}
VIEW=${VIEW:---view=top}
Dp=/tmp/v51_run/${TAG}_pat; Dq=/tmp/v51_run/${TAG}_pris
mkdir -p /tmp/v51_run
SLANG_UHDM=$PAT  "$VARM" "$SRC" "$Dp" > "$Dp.arm" 2>&1
SLANG_UHDM=$PRIS "$VARM" "$SRC" "$Dq" > "$Dq.arm" 2>&1
for f in "$Dp/g.dump" "$Dp/o.dump" "$Dq/g.dump" "$Dq/o.dump"; do
  [ -s "$f" ] || { echo "FATAL missing $f"; sed -n '1,12p' "$Dp.arm" "$Dq.arm"; exit 7; }
done
if ! diff -q <(sed "s#${TAG}_pat#WD#g" "$Dp/g.dump") <(sed "s#${TAG}_pris#WD#g" "$Dq/g.dump") >/dev/null; then
  echo "FATAL: golden differs between the two Surelog runs for $TAG"; exit 8
fi
python3 "$CG" "$Dp/g.dump" $VIEW > "$Dp/g.cells"
python3 "$CG" "$Dp/o.dump" $VIEW > "$Dp/o.cells"
python3 "$CG" "$Dq/o.dump" $VIEW > "$Dq/o.cells"
echo "== $TAG =="
echo "  arm(pat):  $(grep -E 'PASS_CMP|CMP_FAIL' "$Dp.arm") $(grep -E '^cmp heads' "$Dp.arm")"
echo "  arm(pris): $(grep -E 'PASS_CMP|CMP_FAIL' "$Dq.arm") $(grep -E '^cmp heads' "$Dq.arm")"
python3 - "$Dp/g.cells" "$Dq/o.cells" "$Dp/o.cells" <<'PY'
import sys
def load(p):
    d={}
    for l in open(p):
        l=l.rstrip('\n')
        if not l: continue
        head,rhs=l.split(' | ',1)
        parts=head.split(' ',2)
        key=(parts[1],parts[2])   # scope, span
        d.setdefault(key,[]).append(rhs)
    return d
g,pr,pa=[load(x) for x in sys.argv[1:4]]
keys=sorted(set(g)|set(pr)|set(pa), key=lambda k:(k[1],k[0]))
print("  %-26s %-30s %-30s %-30s %s"%("SCOPE","GOLDEN","PRISTINE","PATCHED","V"))
for k in keys:
    G=';'.join(g.get(k,['--MISSING--']))
    P=';'.join(pr.get(k,['--MISSING--']))
    Q=';'.join(pa.get(k,['--MISSING--']))
    def cls(x):
        return 'op' if x.startswith('operation') else ('const' if x.startswith('constant') else x)
    v=''
    if cls(P)==cls(G) and cls(Q)!=cls(G): v='*** REGRESSION ***'
    elif cls(P)!=cls(G) and cls(Q)==cls(G): v='FIXED'
    elif cls(P)!=cls(G): v='resid'
    import re as _re
    mm=_re.search(r'line:(\d+):(\d+)',k[1])
    loc=(mm.group(1)+':'+mm.group(2)) if mm else '?'
    print("  %-24s %-30s %-30s %-30s %s"%(loc+' '+k[0][-14:],G,P,Q,v))
PY

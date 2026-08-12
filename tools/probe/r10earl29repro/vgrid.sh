#!/usr/bin/env bash
# verifier grid driver: run one arm with BOTH binaries, extract cells against the
# SAME golden, and report the per-cell verdict transition base -> patched.
# An over-fire is a cell EQ at base and DIFFER at patched.
set -u
R=${REPRO:?repro dir}
PAT=${PAT:?patched binary}
PRIS=${PRIS:?pristine binary}
SRC=${1:?arm}
B=$(basename "$SRC"); B=${B%.*}
OUTROOT=${OUTROOT:-/tmp/e29v_grid}
mkdir -p "$OUTROOT"
SLANG_UHDM=$PRIS  bash "$R/arm.sh" "$SRC" "$OUTROOT/${B}_pris" > "$OUTROOT/${B}_pris.arm" 2>&1
SLANG_UHDM=$PAT   bash "$R/arm.sh" "$SRC" "$OUTROOT/${B}_pat"  > "$OUTROOT/${B}_pat.arm"  2>&1
echo "==== $B"
echo "  base:    $(tr '\n' ' ' < "$OUTROOT/${B}_pris.arm")"
echo "  patched: $(tr '\n' ' ' < "$OUTROOT/${B}_pat.arm")"
# goldens from the two runs must be identical (same surelog, same input)
cmp -s "$OUTROOT/${B}_pris/g.dump" "$OUTROOT/${B}_pat/g.dump" || echo "  !! GOLDEN DUMPS DIFFER BETWEEN RUNS -- readings not comparable"
python3 "$R/cells.py" "$OUTROOT/${B}_pris/g.dump" "$OUTROOT/${B}_pris/o.dump" "$R/$SRC" > "$OUTROOT/${B}.cells.base" 2>&1
python3 "$R/cells.py" "$OUTROOT/${B}_pat/g.dump"  "$OUTROOT/${B}_pat/o.dump"  "$R/$SRC" > "$OUTROOT/${B}.cells.pat"  2>&1
echo "  base    $(tail -1 "$OUTROOT/${B}.cells.base")"
echo "  patched $(tail -1 "$OUTROOT/${B}.cells.pat")"
# per-cell transition
python3 - "$OUTROOT/${B}.cells.base" "$OUTROOT/${B}.cells.pat" <<'PY'
import sys,re
def load(p):
    d={}; key=None
    for ln in open(p):
        m=re.match(r'^(\S+)\s+(\S+)\s+(EQ|DIFFER|MISSING)$', ln.rstrip())
        if m: key=(m.group(1),m.group(2)); d[key]=[m.group(3),'','','']; continue
        if key:
            if ln.startswith('    SRC'):    d[key][1]=ln.strip()[4:].strip()
            elif ln.startswith('    GOLDEN'):d[key][2]=ln.strip()[7:].strip()
            elif ln.startswith('    OURS'):  d[key][3]=ln.strip()[5:].strip()
    return d
b=load(sys.argv[1]); p=load(sys.argv[2])
ofire=[];fixed=[];still=[]
for k in sorted(set(b)|set(p), key=lambda k:k[1]):
    bv=b.get(k,['-ABSENT-','','',''])[0]; pv=p.get(k,['-ABSENT-','','',''])[0]
    if bv=='EQ' and pv!='EQ': ofire.append((k,b.get(k),p.get(k)))
    elif bv!='EQ' and pv=='EQ': fixed.append((k,b.get(k),p.get(k)))
    elif bv!='EQ' and pv!='EQ': still.append((k,b.get(k),p.get(k)))
print(f"  TRANSITIONS: fixed(base!=EQ -> EQ)={len(fixed)}  OVER-FIRE(base EQ -> not EQ)={len(ofire)}  still-not-EQ={len(still)}")
for tag,lst in (("OVER-FIRE",ofire),):
    for k,bb,pp in lst:
        print(f"  !! {tag} {k[0]} {k[1]}")
        print(f"       SRC    {pp[1] if pp else bb[1]}")
        print(f"       GOLDEN {pp[2] if pp else bb[2]}")
        print(f"       BASE-OURS  {bb[3] if bb else '-ABSENT-'}")
        print(f"       PATCH-OURS {pp[3] if pp else '-ABSENT-'}")
PY

#!/usr/bin/env bash
# r10uvm130repro/pred130.sh — THE MOVER PREDICTOR, written from PRISTINE
# databases and from OUR SIDE ALONE (no golden is opened).  MEASUREMENT ONLY.
#
#   pred130.sh <sweep workdir> <cen bin> <out.tsv>
#
# A database can only move if it holds a reference that
#   * sits in a DYNAMIC-ARRAY `new[...]` ARGUMENT LIST — CTX=NEWARG, i.e. the
#     reference's vpiParent chain DIES on an unparented `method_func_call`
#     named `new` (Surelog CompileHelper.cpp:4482-4497 never parents it),
#   * is not a hier_path element (the hier_path builder never enters Surelog's
#     late-binding pool — § classPropNewLhsNoHoist109),
#   * carries NO actual today (ACT=NONE), and
#   * is written inside a subroutine whose HOME can hoist: an OUT-OF-BODY
#     method of a PACKAGE class (OOB/CLS, § oobRefVarLocalHoistNet107) or a
#     FREE PACKAGE subroutine (IB/PKG, § pkgFreeSubRefVarHoistNet117).  The
#     NEWARG reference has no owner column of its own — its chain is dead —
#     so the owner is found by LINE CONTAINMENT against the LV rows' owner
#     spans, joined on the reference's NAME.
# MAY-MOVE is the exact shape; OUTER drops the HOME test (an IN-BODY class
# method's identical `new[...]` argument, which golden leaves bare).
set -u
W=$1; CEN=$2; OUT=$3
: > "$OUT"
TMPD=$(mktemp -d /tmp/r10uvm130_pred.XXXXXX)
trap 'rm -rf "$TMPD"' EXIT
tests=0; skip=0
while IFS= read -r d; do
  o="$d/slang.uhdm"
  [ -f "$o" ] || { skip=$((skip+1)); continue; }
  name=$(basename "$d"); mode=$(basename "$(dirname "$d")")
  tests=$((tests+1))
  "$CEN" "$o" O > "$TMPD/p130.o" 2>/dev/null
  awk -F'\t' -v M="$mode" -v N="$name" '
    function lo(sp,  a){ split(sp,a,":"); return a[1]+0 }
    function hi(sp,  a,b){ split(sp,a,"-"); split(a[2],b,":"); return b[1]+0 }
    $2=="LV" {
      # owner span is the LAST column; hoisting homes only
      # THE HOME TEST, spelled from OUR OWN database.  Our emitter names an
      # OUT-OF-BODY definition with the qualified VpiName Surelog uses (so the
      # OOB column reads OOB on the package-scope copies) and gives an IN-BODY
      # class method a bare VpiName with a CLS home; a FREE PACKAGE subroutine
      # is (IB, PKG).  An in-body class method therefore has NO (OOB,*) row at
      # all, which is exactly the population golden leaves bare.
      host = ($4=="OOB") || ($4=="IB" && $5=="PKG")
      key=$7
      n=split(own[key],x,";")
      own[key]=own[key] $10 "," host "," $6 ";"
      next
    }
    $2!="REF" { next }
    $15=="NEWARG" && $11!="hier_path" && $9=="NONE" {
      shape="OUTER"; ownr="-"
      if ($8 in own) {
        c=split(own[$8],parts,";")
        for (i=1;i<=c;i++) {
          if (parts[i]=="") continue
          split(parts[i],f,",")
          if (lo($7) >= lo(f[1]) && lo($7) <= hi(f[1])) {
            ownr=f[3]
            if (f[2]==1) { shape="MAY-MOVE"; break }
          }
        }
      }
      print shape"\t"M"\t"N"\t"$7"\t"$8"\t"$11"\t"ownr
    }' "$TMPD/p130.o" | sort -u >> "$OUT"
done < <(find "$W" -mindepth 2 -maxdepth 2 -type d | sort)
mm=$(grep -c '^MAY-MOVE' "$OUT"); ou=$(grep -c '^OUTER' "$OUT")
echo "MEASURED=$tests SKIP=$skip MAY-MOVE=$mm OUTER=$ou"
echo "databases with the exact shape:"
grep '^MAY-MOVE' "$OUT" | cut -f2,3 | sort -u

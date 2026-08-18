#!/usr/bin/env bash
# r10uvm94 — THE GOLDEN-vs-GOLDEN ORACLE, run FIRST and on GOLDEN ONLY.
#
# ct94cen widens uvm92's oracle from "elements whose index is an OPERATION" to
# EVERY select-bearing path element (bit_select / part_select /
# indexed_part_select / var_select, any operand kinds).  It transcribes
# `CompileHelper::decompileHelper` (CompileHelper.cpp:2544) and LINKS the real
# `UHDM::ExprEval::prettyPrint` for the operation row, applies the composition
# to each path element of a golden database's OWN tree and compares it to the
# bracket text that database's hier_path NAME actually carries.
#
# A single EXPM=N anywhere REFUTES the transcription.
#   usage: gvg94.sh <dir-of-goldens|workdir-root> [outfile]
# With a workdir root it follows each cmds.txt's `golden cache hit`; with a
# plain directory it takes every */golden.uhdm underneath.
set -u
SRC=${1:?golden dir or workdir root}
OUT=${2:-/tmp/r10uvm94_gvg.txt}
CEN=${CEN:-/tmp/r10uvm94_ct94cen}
JOBS=${JOBS:-4}
LIST=$(mktemp /tmp/r10uvm94_gvglist.XXXX)
if [ -d "$SRC/default" ] || [ -d "$SRC/testflags" ]; then
  for d in "$SRC"/default/*/ "$SRC"/testflags/*/; do
    [ -d "$d" ] || continue
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
    [ -n "$G" ] && [ -f "$G/golden.uhdm" ] && echo "$G/golden.uhdm"
  done | sort -u > "$LIST"
else
  find "$SRC" -name golden.uhdm | sort > "$LIST"
fi
echo "goldens=$(wc -l < "$LIST")"
: > "$OUT"
xargs -a "$LIST" -P "$JOBS" -I{} sh -c '
  L=$('"$CEN"' "{}" --sel 2>&1 >/dev/null | tail -1)
  echo "{} $L"' >> "$OUT"
awk '{ for(i=1;i<=NF;i++){ split($i,a,"=");
         if(a[1]=="EXPM_Y")y+=a[2]; if(a[1]=="EXPM_N")n+=a[2];
         if(a[1]=="RNG_Y")ry+=a[2]; if(a[1]=="RNG_N")rn+=a[2];
         if(a[1]=="IPS_Y")iy+=a[2];
         if(a[1]=="IPS_N"){iN+=a[2]; if(a[2]>0){bad++; print "REFUTED(ips)",$1}}
         if(a[1]=="ips")ips+=a[2]; if(a[1]=="ps")ps+=a[2]; if(a[1]=="bs")bs+=a[2];
         if(a[1]=="vs")vs+=a[2]; if(a[1]=="hier_path")hp+=a[2] } }
     END{ printf "-- dbs=%d hier_path=%d  elems ips=%d ps=%d bs=%d vs=%d\n   ALLSEL  EXPM_Y=%d EXPM_N=%d\n   RANGE   RNG_Y=%d RNG_N=%d\n   IDXPSEL IPS_Y=%d IPS_N=%d  refuting dbs=%d\n",
          NR, hp, ips, ps, bs, vs, y, n, ry, rn, iy, iN, bad+0 }' "$OUT"
rm -f "$LIST"

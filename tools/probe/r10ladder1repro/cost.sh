#!/bin/bash
# r10ladder1/cost.sh — the COST MODEL, read off the artifacts rather than
# estimated.
#
# The campaign's standing cost figure (r10sd4) is ~1.5 ms per ABORTED whole-
# design Compare with |m_visited| ~1650.  A ladder is not one aborted compare,
# it is hundreds of increasingly DEEP ones, so the old figure does not transfer
# and this script recomputes it per row from the ladder itself:
#
#   compares = 1 (final)                 the coverage re-walk
#            + one per rung               the head measurement
#            + one per mask TRIAL         masklvl+1 candidates were tried
#            + the BI counts              bisection compares, printed per rung
#
#   usage: cost.sh <ladder-dir>
set -u
D=${1:?ladder-dir}
ls "$D"/ladder_*.txt >/dev/null 2>&1 || { echo "FATAL: no ladder_*.txt in $D"; exit 3; }
printf "%-30s %7s %8s %8s %9s %8s %10s\n" ROW RUNGS TRIALS BISECT COMPARES SECS MS/COMPARE
for f in "$D"/ladder_*.txt; do
  awk -F'\t' '
    /^RUNG/{r++; for(i=1;i<=NF;i++) if($i ~ /^masklvl=/){split($i,a,"="); lv=a[2]+0;
              if(lv>=0 && lv<1000) t+=lv+1}}
    /^   BI /{split($0,b," "); bi+=b[2]}
    /^\[S\]/{for(i=1;i<=NF;i++);  if(match($0,/secs=[0-9.]+/)) s=substr($0,RSTART+5,RLENGTH-5)}
    END{c=r+t+bi+1; n=split(FILENAME,p,"/"); nm=p[n];
        printf "%-30s %7d %8d %8d %9d %8s %10.2f\n", nm, r, t, bi, c, s, (s*1000)/(c?c:1)}
  ' "$f"
done

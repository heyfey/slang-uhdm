#!/usr/bin/env bash
# r10buvm13repro/predict13.sh — PREDICT THE MOVERS BY NAME, from the PRISTINE
# databases ALONE (never the patched ones, never golden).
#
#   usage: predict13.sh <pristine workdir root> [outfile]
#
# § formalDefaultBindsLikeBody13 moves exactly two shapes, and both have an
# exact UHDM shadow readable out of a pristine database:
#
#   CAND A (GAIN a vpiActual) — a ref inside a formal's DEFAULT VALUE that
#     names an EARLIER FORMAL of the same task_func, currently UNBOUND, whose
#     owner is NOT an in-class listing.
#   CAND B (LOSE a vpiActual) — a ref inside a formal's DEFAULT VALUE that
#     currently CARRIES an actual and whose owner IS an in-class listing
#     (parented at a class_defn with vpiMethod 1: an in-body method, an
#     `extern` PROTOTYPE listing, or a `pure virtual`).
#
#   CAND C — the CONTROL, not a prediction: every other bound default-value
#     ref (package/module free subroutine, out-of-body definition).  Any CAND C
#     object that moves is an OVER-FIRE.
#
# A database is predicted to MOVE iff CAND A + CAND B > 0.
set -u
W=${1:?pristine workdir root}
O=${2:-/tmp/r10buvm13_predict.txt}
CEN=/tmp/r10buvm13cen
[ -x "$CEN" ] || { echo "FATAL no census $CEN"; exit 3; }
: > "$O"
n=0; A=0; B=0; C=0; ndb=0
for c in "$W"/*/*/cmds.txt; do
  [ -f "$c" ] || continue
  d=$(dirname "$c"); o=$d/slang.uhdm
  [ -f "$o" ] || continue
  n=$((n+1))
  r=$("$CEN" "$o" P 2>/dev/null | awk '
    $1=="DV" {
      act=""; home=""; meth=""; ear="";
      for(i=1;i<=NF;i++){
        if($i ~ /^act=/)     act=substr($i,5);
        else if($i ~ /^home=/) home=substr($i,6);
        else if($i ~ /^meth=/) meth=substr($i,6);
        else if($i ~ /^earlier=/) ear=substr($i,9);
      }
      incls = (home ~ /^class_defn\(/ && meth=="1");
      if (act=="0" && ear=="1" && !incls) a++;
      else if (act=="1" && incls) b++;
      else if (act=="1") c++;
    }
    END { printf "%d %d %d\n", a+0, b+0, c+0 }')
  set -- $r
  A=$((A+$1)); B=$((B+$2)); C=$((C+$3))
  if [ $(($1+$2)) -gt 0 ]; then
    ndb=$((ndb+1))
    echo "MOVER-PREDICTED $(basename "$(dirname "$d")")/$(basename "$d" | sed 's/-[^-]*$//')  CANDA=$1 CANDB=$2 CANDC=$3" >> "$O"
  fi
done
echo "predict13: databases=$n  CAND A(gain)=$A  CAND B(lose)=$B  CAND C(control)=$C  predicted MOVERS=$ndb  -> $O"
[ "$n" -gt 0 ] || { echo "FATAL: reached NO databases"; exit 5; }
sort "$O" | sed 's/^/   /'

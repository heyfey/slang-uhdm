#!/usr/bin/env bash
# r10v201 (VERIFIER) adversarial grid.  MEASUREMENT ONLY; uhdm-cmp is the judge.
# For each arm: one REAL Surelog v1.86 golden per view (parse / elab), then
# both binaries' databases, then (a) golden-vs-golden CALIBRATION, (b) the
# param_assign Rhs-constant typespec census on each binary, (c) the OFFICIAL
# uhdm-cmp golden-vs-ours on each binary (cmp lines + head count + rc).
set -u
PRIS=${PRIS:?}; PAT=${PAT:?}; CEN=${CEN:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
ARMS=${1:?armdir}; SCR=${2:?scratch}; OUT=${3:?out}
mkdir -p "$SCR" || exit 1
: > "$OUT"
for f in "$ARMS"/*.sv; do
  b=$(basename "$f" .sv)
  for ev in parse elab; do
    d=$SCR/$b.$ev
    rm -rf "$d"; mkdir -p "$d" || exit 1
    cp "$f" "$d/" || exit 1
    ex=""; [ "$ev" = elab ] && ex="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $ex "$b.sv" > sl.log 2>&1 ); grc=$?
    ( cd "$d" && timeout 300 "$PRIS" "$b.sv" -o pris.uhdm > pris.log 2>&1 ); prc=$?
    ( cd "$d" && timeout 300 "$PAT"  "$b.sv" -o pat.uhdm  > pat.log  2>&1 ); qrc=$?
    g=$d/slpp_all/surelog.uhdm
    echo "ARM $b $ev rc_surelog=$grc rc_pris=$prc rc_pat=$qrc golden=$([ -f "$g" ] && echo yes || echo NO)" >> "$OUT"
    [ -f "$g" ] || continue
    "$CEN" --cen "$g" "$g" "CALIB:$b.$ev" >> "$OUT" 2>&1
    "$CEN" --list "$g" "GOLD:$b.$ev" > "$d/gold.list" 2>&1
    if [ -f "$d/pris.uhdm" ]; then
      "$CEN" --cen "$g" "$d/pris.uhdm" "PRIS:$b.$ev" >> "$OUT" 2>&1
      "$CEN" --list "$d/pris.uhdm" "PRISL:$b.$ev" > "$d/pris.list" 2>&1
      "$CMP" "$g" "$d/pris.uhdm" > "$d/pris.cmp" 2>&1; c1=$?
      echo "CMP PRIS:$b.$ev lines=$(wc -l < "$d/pris.cmp") heads=$(grep -c '^LHS:' "$d/pris.cmp"; true) rc=$c1" >> "$OUT"
    fi
    if [ -f "$d/pat.uhdm" ]; then
      "$CEN" --cen "$g" "$d/pat.uhdm" "PATCHED:$b.$ev" >> "$OUT" 2>&1
      "$CEN" --list "$d/pat.uhdm" "PATL:$b.$ev" > "$d/pat.list" 2>&1
      "$CMP" "$g" "$d/pat.uhdm" > "$d/pat.cmp" 2>&1; c2=$?
      echo "CMP PATCHED:$b.$ev lines=$(wc -l < "$d/pat.cmp") heads=$(grep -c '^LHS:' "$d/pat.cmp"; true) rc=$c2" >> "$OUT"
    fi
  done
done
sum () {
  echo "-- $1  $(grep -c "^CENSUM $1:" "$OUT"; true) arm-views  TS-DIFF $(awk -F'TS-DIFF=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  ONLY-GOLDEN $(awk -F'ONLY-GOLDEN=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  ONLY-OURS $(awk -F'ONLY-OURS=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")  AGREE $(awk -F'AGREE=' '/^CENSUM '"$1"':/{split($2,a," ");s+=a[1]}END{print s+0}' "$OUT")"
}
{ sum CALIB; sum PRIS; sum PATCHED
  echo "-- NONZERO RCs: $(awk '/^ARM /{for(i=1;i<=NF;i++) if($i ~ /^rc_/ && $i !~ /=0$/) print}' "$OUT" | wc -l)"
  echo "-- CMP LINE DELTAS (pat-pris) per arm-view:"
  awk '/^CMP /{split($2,t,":"); k=t[2]; v=$3; sub("lines=","",v); if(t[1]=="PRIS") p[k]=v; else q[k]=v} END{for(k in q) printf "   %-24s pris=%-8s pat=%-8s delta=%s\n", k, p[k], q[k], q[k]-p[k]}' "$OUT" | sort
} >> "$OUT"
tail -30 "$OUT"

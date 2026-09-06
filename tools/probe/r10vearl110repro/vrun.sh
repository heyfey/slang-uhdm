#!/usr/bin/env bash
# r10vearl110 INDEPENDENT arm driver. MEASUREMENT ONLY; uhdm-cmp is the judge.
# usage: vrun.sh <outdir> <arm.sv> <top>
set -u
PRIS=/tmp/v110_bin_pris
PAT=/tmp/v110_bin_fix
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
CEN=/tmp/v110_arms/cen110
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
OUT=${1:?outdir}; F=${2:?arm}; TOP=${3:-}
arm=$(basename "$F" .sv)
T=""; U=""; [ -n "$TOP" ] && { T="-top $TOP"; U="--top $TOP"; }
for view in plain elab; do
  case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
  d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
  ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl $T "$F" > sl.log 2>&1 </dev/null ); slrc=$?
  G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
  ( cd "$d" && "$PRIS" $SUF $U "$F" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
  ( cd "$d" && "$PAT"  $SUF $U "$F" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
  if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
    echo "$arm $view SLRC=$slrc PRC=$prc ARC=$arc REJECT"; continue
  fi
  "$CMP" "$G" "$d/pris.uhdm"    > "$d/pris.cmp" 2>&1
  "$CMP" "$G" "$d/patched.uhdm" > "$d/patch.cmp" 2>&1
  pc=$(wc -l < "$d/pris.cmp");  ac=$(wc -l < "$d/patch.cmp")
  echo "$arm $view SLRC=$slrc PRC=$prc ARC=$arc cmp_pris=$pc cmp_patch=$ac"
  "$CEN" "$G"              > "$d/cen.gold.txt"  2>&1
  "$CEN" "$d/pris.uhdm"    > "$d/cen.pris.txt"  2>&1
  "$CEN" "$d/patched.uhdm" > "$d/cen.patch.txt" 2>&1
  for c in gold pris patch; do
    r=$(sed -n 's/^CENRC //p' "$d/cen.$c.txt")
    [ "$r" = "0" ] || echo "  CENRC-BAD $arm $view $c rc=${r:-none}"
  done
  python3 /tmp/v110_arms/vscore.py "$d/cen.gold.txt" "$d/cen.pris.txt" "$d/cen.patch.txt" "${arm}_${view}"
done

#!/usr/bin/env bash
# r10vearl110 CALIBRATION -- build each arm's Surelog golden TWICE in two DIFFERENT
# directories and score the two censuses against each other.  Any cell that
# differs here is noise and cannot carry a verdict.
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/v110_arms/cen110
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
tot=0; bad=0
for F in "$@"; do
  arm=$(basename "$F" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse";; elab) SLF="-parse -elabuhdm";; esac
    for r in r1 r2; do
      d=/tmp/v110_calib/${arm}_${view}_$r; rm -rf "$d"; mkdir -p "$d"
      ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl -top "$arm" "$F" > sl.log 2>&1 </dev/null )
      G=$(find "$d/sl" -name '*.uhdm' | head -1)
      [ -n "$G" ] && "$CEN" "$G" > "$d/cen.txt" 2>&1
    done
    a=/tmp/v110_calib/${arm}_${view}_r1/cen.txt
    b=/tmp/v110_calib/${arm}_${view}_r2/cen.txt
    if [ -f "$a" ] && [ -f "$b" ]; then
      n=$(grep -vc '^CENRC' "$a"; true); dif=$(diff "$a" "$b" | grep -c '^[<>]'; true)
      tot=$((tot+n)); bad=$((bad+dif))
      echo "CALIB $arm $view cells=$n DIFF=$dif"
    else
      echo "CALIB $arm $view NO-GOLDEN"
    fi
  done
done
echo "CALIB TOTAL cells=$tot DIFF=$bad"

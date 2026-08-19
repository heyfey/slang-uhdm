#!/usr/bin/env bash
# Run g25.sv through golden Surelog and one slang-uhdm binary in both views.
# MEASUREMENT ONLY: official uhdm-cmp remains the acceptance judge.
set -u
BIN=$1
W=$2
CEN=${3:-/tmp/r10buvm25cen}
D=$(cd "$(dirname "$0")" && pwd)
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
rm -rf "$W"
mkdir -p "$W"
cp "$D/g25.sv" "$W/"
(
  cd "$W" || exit 1
  "$SURELOG" -parse -noprecompiledcache g25.sv -mt 0 -mp 0 -o gd >gd.log 2>&1
  echo "GD_RC=$?"
  "$SURELOG" -parse -elabuhdm -noprecompiledcache g25.sv -mt 0 -mp 0 -o ge >ge.log 2>&1
  echo "GE_RC=$?"
  "$BIN" g25.sv --single-unit -o od.uhdm >od.log 2>&1
  echo "OD_RC=$?"
  "$BIN" g25.sv --single-unit --elabuhdm -o oe.uhdm >oe.log 2>&1
  echo "OE_RC=$?"
  "$CEN" gd/slpp_all/surelog.uhdm GD >cen.GD.txt
  "$CEN" ge/slpp_all/surelog.uhdm GE >cen.GE.txt
  "$CEN" od.uhdm OD >cen.OD.txt
  "$CEN" oe.uhdm OE >cen.OE.txt
)
python3 "$D/cencmp25.py" "$W/cen.GD.txt" "$W/cen.OD.txt" --noloc
python3 "$D/cencmp25.py" "$W/cen.GE.txt" "$W/cen.OE.txt" --noloc

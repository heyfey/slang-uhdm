set -u
PAT=/tmp/v64_bin/pat; PRIS=/tmp/v64_bin/pris
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
CEN=/tmp/wt_v64/tools/probe/r10v64repro/cen64.py
SC=/tmp/wt_v64/tools/probe/r10v64repro/sc64.py
rel=$1; view=${2:-plain}; ROOT=/tmp/v64_probe
key=$(echo "${rel}_$view" | tr '/' '_')
d=/tmp/v64_dscore/$key; rm -rf "$d"; mkdir -p "$d"; cp "$ROOT/$rel"/*.sv "$d/" 2>/dev/null
case $view in plain) SLF=""; SGF="";; elab) SLF="--elabuhdm"; SGF="-elabuhdm";; esac
( cd "$d" && $SL -parse -nobuiltin -nocache -sv $SGF -d uhdm *.sv >sl.log 2>&1 </dev/null )
G=""; for c in "$d/slpp_all/surelog.uhdm" "$d/slpp_unit/surelog.uhdm"; do [ -f "$c" ] && G="$c"; done
[ -n "$G" ] || { echo "$rel $view SURELOG_FAIL"; exit 0; }
( cd "$d" && "$PRIS" $SLF *.sv -o pris.uhdm >p1.log 2>&1 </dev/null )
( cd "$d" && "$PAT"  $SLF *.sv -o pat.uhdm  >p2.log 2>&1 </dev/null )
[ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ] || { echo "$rel $view NO_DB"; exit 0; }
for pr in "$G g" "$d/pris.uhdm o" "$d/pat.uhdm p"; do set -- $pr
  $DUMP "$1" 2>/dev/null | sed '1d' | sed "s#$d#WD#g" > "$d/$2.raw"
  python3 "$CEN" "$d/$2.raw" > "$d/$2.cen"; done
echo "$rel $view $(python3 "$SC" "$d/g.cen" "$d/o.cen" "$d/p.cen" 0)"

#!/bin/bash
# bndscore111.sh <bnd-out> <score-out> <tagA>=<binA> <tagB>=<binB> [probe-root]: for every MOVED arm of a
# bnd111.sh run, build golden with the pinned Surelog (same single-file form: -parse -nobuiltin -nocache
# -sv), rebuild both tags (rc recorded), run uhdm-cmp (LHS golden) and hand the dirs to score111.sh.
B=${1:?}; O=${2:?}; A=${3:?}; C=${4:?}; ROOT=${5:-$(cd "$(dirname "$0")/.." && pwd)}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog; CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
ta=${A%%=*}; ba=${A#*=}; tc=${C%%=*}; bc=${C#*=}
mkdir -p "$O"
grep '^MOVED' "$B/result.txt" | awk '{print $2}' | while read -r rel; do
  d=$(dirname "$rel"); f=$(basename "$rel"); key=$(echo "$rel" | sed 's#^\./##; s#/#__#g'); w="$O/$key"; mkdir -p "$w"
  if [ ! -f "$w/gold.uhdm" ]; then
    (cd "$ROOT/$d" && timeout 300 "$SL" -parse -nobuiltin -nocache -sv "$f" -mt 0 -mp 0 -o "$w/goldwd" </dev/null >"$w/gold.log" 2>&1); echo "rc=$?" > "$w/gold.rc"
    g=$(ls "$w"/goldwd/slpp_*/*.uhdm 2>/dev/null | head -1); [ -n "$g" ] && cp "$g" "$w/gold.uhdm"; rm -rf "$w/goldwd"
  fi
  for tb in "$ta=$ba" "$tc=$bc"; do t=${tb%%=*}; b=${tb#*=}
    (cd "$ROOT/$d" && timeout 120 "$b" "$f" --single-unit --nobuiltin -o "$w/$t.uhdm" </dev/null >/dev/null 2>&1); echo "rc=$?" > "$w/$t.rc"
    [ -f "$w/gold.uhdm" ] && [ -f "$w/$t.uhdm" ] && "$CMP" "$w/gold.uhdm" "$w/$t.uhdm" > "$w/$t.cmp" 2>&1
  done
  echo "$rel gold=$(cat "$w/gold.rc") $ta=$(cat "$w/$ta.rc") $tc=$(cat "$w/$tc.rc") golddb=$([ -f "$w/gold.uhdm" ] && echo yes || echo NO)"
done

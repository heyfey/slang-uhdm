#!/usr/bin/env bash
# r10vrgg18repro/vcell18.sh — build golden + BOTH binaries for one cell dir and
# emit the three censuses.  usage: vcell18.sh <cell-dir> <tag> [extra surelog args...]
set -u
D=$(cd "$1" && pwd); TAG=$2; shift 2
W=/tmp/vrgg18_cell_$TAG; rm -rf "$W"; mkdir -p "$W"
SELF=$(cd "$(dirname "$0")" && pwd)
mapfile -t SRCS < <(cd "$D" && ls *.sv *.v 2>/dev/null)
( cd "$D" && ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv \
    "$@" "${SRCS[@]}" -mt 0 -mp 0 -o "$W" > "$W/surelog.log" 2>&1 )
echo "surelog rc=$?"
G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
for B in base pat; do
  ( cd "$D" && /tmp/vrgg18_bin/slang-uhdm-$B "${SRCS[@]}" -o "$W/$B.uhdm" \
      > "$W/$B.log" 2>&1 ); echo "slang-$B rc=$?"
  [ -f "$W/$B.uhdm" ] && ~/.local/bin/uhdm-dump "$W/$B.uhdm" > "$W/$B.dump" 2>&1
  [ -f "$W/$B.dump" ] && python3 "$SELF/vcen18.py" "$W/$B.dump" "$B" > "$W/$B.cen"
done
[ -n "${G:-}" ] && ~/.local/bin/uhdm-dump "$G" > "$W/golden.dump" 2>&1
[ -f "$W/golden.dump" ] && python3 "$SELF/vcen18.py" "$W/golden.dump" G > "$W/golden.cen"
echo "work=$W golden=$G"

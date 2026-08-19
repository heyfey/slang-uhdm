#!/usr/bin/env bash
# r10uvm101: three-way event_stmt field census for the nine UVM mover DBs.
set -u
PATCHED=${1:?patched workdir}
PRISTINE=${2:?pristine workdir}
OUT=${3:?output directory}
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
NAMES=${NAMES:-"BuildUVMPkg MiniAmiq Scoreboard SeqDriver SimpleUVM"}
mkdir -p "$OUT"
for mode in default testflags; do
  for name in $NAMES; do
    for dir in "$PATCHED/$mode/$name"-*/; do
      [ -d "$dir" ] || continue
      rel=${dir#$PATCHED/}
      ours="$dir/slang.uhdm"
      old="$PRISTINE/$rel/slang.uhdm"
      cmds="$dir/cmds.txt"
      golden=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$cmds" | head -1)
      [ -d "$golden" ] && golden="$golden/golden.uhdm"
      if [ ! -f "$golden" ] || [ ! -f "$old" ] || [ ! -f "$ours" ]; then
        echo "$mode/$name SKIP-NOFILE golden=${golden:-none}"
        continue
      fi
      key=${mode}_${name}
      "$DUMP" "$golden" 2>/dev/null | "$HERE/ev101.py" > "$OUT/$key.g.ev"
      "$DUMP" "$old" 2>/dev/null | "$HERE/ev101.py" > "$OUT/$key.p.ev"
      "$DUMP" "$ours" 2>/dev/null | "$HERE/ev101.py" > "$OUT/$key.q.ev"
      printf "%s/%s records G/P/Q %s/%s/%s " "$mode" "$name" \
        "$(wc -l < "$OUT/$key.g.ev")" \
        "$(wc -l < "$OUT/$key.p.ev")" \
        "$(wc -l < "$OUT/$key.q.ev")"
      "$HERE/evscore101.py" "$OUT/$key.g.ev" "$OUT/$key.p.ev" \
        "$OUT/$key.q.ev" | tee "$OUT/$key.score" | tail -1
    done
  done
done

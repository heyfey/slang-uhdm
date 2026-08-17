#!/usr/bin/env bash
# vbuvm8 verifier: for every BYTE MOVER, run the OFFICIAL uhdm-cmp against that
# test's own golden with BOTH binaries' databases and byte-compare the LOGS.
set -u
CMP=$HOME/.local/bin/uhdm-cmp
[ -x "$CMP" ] || CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
for pair in "$@"; do
  A=${pair%%::*}; rel=${pair##*::}
  B=$(echo "$A" | sed 's/_v1$/_pri/;s/wds_v1/wds_pri/;s/wdu_v1/wdu_pri/')
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$A/$rel/cmds.txt" | head -1)
  [ -n "$g" ] || { echo "NO_GOLDEN $rel"; continue; }
  gu=$g/golden.uhdm
  lp=/tmp/vbuvm8_wall_$(echo "$rel"|tr / _)_pri.log
  lq=/tmp/vbuvm8_wall_$(echo "$rel"|tr / _)_v1.log
  "$CMP" "$gu" "$B/$rel/slang.uhdm" > "$lp" 2>&1
  "$CMP" "$gu" "$A/$rel/slang.uhdm" > "$lq" 2>&1
  hp=$(grep -c '^LHS:' "$lp"); hq=$(grep -c '^LHS:' "$lq")
  v=BYTE-IDENTICAL; cmp -s "$lp" "$lq" || v="LOGS-DIFFER"
  printf '%-52s heads %s -> %s   lines %s -> %s   %s\n' "$rel" "$hp" "$hq" "$(wc -l <"$lp")" "$(wc -l <"$lq")" "$v"
done

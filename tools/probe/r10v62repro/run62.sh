#!/usr/bin/env bash
# v62 verifier arm driver: runs one .sv with BOTH frozen binaries, BOTH views,
# reports cmp verdict/heads/lines and the golden-vs-ours dump diff size.
set -u
ARM=$1; B=$(basename "$ARM" .sv)
A=${ARM62:?set ARM62 to <worktree>/tools/probe/r10earl62repro/arm62.sh}
for view in plain elab; do
  EL=""; [ $view = elab ] && EL="--elab"
  for side in pris pat; do
    D=/tmp/v62_run/${B}_${view}_${side}
    out=$(SLANG_UHDM=/tmp/v62_bin/$side.bin bash $A "$ARM" "$D" $EL 2>&1)
    v=$(echo "$out" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT|NO_GOLDEN_DUMP|NO_OURS_DUMP)')
    h=$(echo "$out" | grep '^cmp heads=')
    d=$(echo "$out" | grep -E '^(DUMP_MATCH|DUMP_DIFF)')
    printf "%-22s %-5s %-4s %-9s %-40s %s\n" "$B" "$view" "$side" "$v" "$h" "$d"
  done
done

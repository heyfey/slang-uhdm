#!/bin/bash
# § ifaceOwnCallCalleeFormRoutes222 — the ARM SCORER.
#
# For every CALL-KIND object in an arm's two dumps, print
#     <kind> <line:col> <name> [prefix=<vpiName of vpiPrefix>]
# so that golden and ours can be read side by side per SOURCE LINE, which is
# the arm cell's own key.  Kinds: func_call, method_func_call, task_call,
# method_task_call, hier_path (the expression-position shape).
#
# The dump is a nested tree; a call's `vpiPrefix` child follows it, so the
# prefix is picked up by a small state machine rather than by a regex over one
# line.  Names are printed as the dump spells them.
#
#   usage: bash score222.sh <griddir> [arm ...]
set -u
G=${1:?griddir}
shift || true
ARMS=${*:-$(cd "$G" && ls -d */ 2>/dev/null | tr -d /)}
for a in $ARMS; do
    for side in golden ours; do
        f="$G/$a/$side.dump"
        [ -f "$f" ] || { echo "$a $side MISSING-DUMP"; continue; }
        awk -v arm="$a" -v side="$side" '
          match($0, /\\_(func_call|method_func_call|task_call|method_task_call)/) {
            k=$0; sub(/^[^\\]*\\_/, "", k); sub(/:.*/, "", k);
            nm=$0; sub(/^[^(]*\(/, "", nm); sub(/\).*/, "", nm);
            ln=$0; sub(/.*line:/, "", ln); sub(/,.*/, "", ln); sub(/ .*/, "", ln);
            printf "%s %s CALL %-18s %-14s %s\n", arm, side, k, ln, nm;
            next
          }
          /\|vpiPrefix:/ { want=1; next }
          want && match($0, /\\_/) {
            nm=$0; sub(/^[^(]*\(/, "", nm); sub(/\).*/, "", nm);
            ln=$0; sub(/.*line:/, "", ln); sub(/,.*/, "", ln); sub(/ .*/, "", ln);
            printf "%s %s   PREFIX %-14s %s\n", arm, side, ln, nm;
            want=0; next
          }
        ' "$f"
    done
done

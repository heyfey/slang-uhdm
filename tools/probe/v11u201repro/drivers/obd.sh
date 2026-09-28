#!/bin/bash
# obd.sh <golden.uhdm> <ours.uhdm> -> order-blind dump distance (lines only in one side, ids and paths normalised)
. "$(cd "$(dirname "$0")" && pwd)/env.sh"
n() { "$UHDM_DUMP" "$1" 2>/dev/null | sed -E 's/id:[0-9]+//g; s#/[^ ,]*/##g' | sort; }
diff <(n "$1") <(n "$2") | grep -c '^[<>]'

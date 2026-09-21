#!/bin/bash
# r11u81 — THE OFFICIAL JUDGE ON A GRID ARM.  `ts78.py` cannot print
# `vpiSigned` or an `int_typespec`'s `Ranges` on the constant-operand visitor
# path (r11v78's RV-3), and `int_typespec::Compare` READS BOTH — so a grid
# score alone is blind on exactly the fields this pass writes.  `uhdm-cmp` is
# not: it walks the same Compare the acceptance gate walks.
#
# LHS is ALWAYS golden.  Heads are counted with `grep -c '^LHS:'` anchored at
# column 0 (cmp prints `decompile:` twice per side for ONE head) and cmp writes
# the head to STDERR.
#
#   usage: cmp81.sh <griddir> <tag> <arm> [<arm> ...]
set -u
G=${1:?griddir}; TAG=${2:?tag}; shift 2
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp"; exit 3; }
printf "%-16s %8s %6s %s\n" ARM CMPLINES HEADS NOTE
for a in "$@"; do
  GU=$(ls "$G"/g_$a/slpp_all/*.uhdm 2>/dev/null | head -1)
  OU="$G/o_${a}_$TAG/ours.uhdm"
  if [ ! -f "$GU" ] || [ ! -f "$OU" ]; then
    printf "%-16s %8s %6s %s\n" "$a" - - "SKIP-NOFILE g=$([ -f "$GU" ] && echo y || echo n) o=$([ -f "$OU" ] && echo y || echo n)"
    continue
  fi
  out=$("$CMP" "$GU" "$OU" 2>&1)
  n=$(printf '%s\n' "$out" | grep -c . ; true)
  h=$(printf '%s\n' "$out" | grep -c '^LHS:' ; true)
  printf "%-16s %8s %6s\n" "$a" "$n" "$h"
done

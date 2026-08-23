#!/bin/bash
# r10vbuvm28 THREE-WAY arm runner — MEASUREMENT ONLY.  Mirrors verify_golden.py's
# `default` mode invocation exactly (surelog `-parse <srcs>`; ours
# `<srcs> --single-unit`), plus the -elabuhdm view.  LHS is ALWAYS golden.
# usage: PRI=<bin> PAT=<bin> MODE=def|elab bash v3run.sh <file.sv> [...]
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
MODE=${MODE:-def}
PRI=${PRI:?}; PAT=${PAT:?}
W=$(mktemp -d /tmp/vbuvm28_arm_XXXXXX)
FILES=""
for f in "$@"; do cp "$f" "$W"/; FILES="$FILES $(basename "$f")"; done
cd "$W" || exit 1
if [ "$MODE" = elab ]; then SL="-elabuhdm"; SU="--elabuhdm"; else SL=""; SU=""; fi
$SURELOG -parse -sv -nocache -nowritecache $SL $FILES > sl.log 2>&1; echo "SURELOG rc=$?" >> rc.txt
G=$(find . -name '*.uhdm' | head -1)
for K in PRI PAT; do
  B=$(eval echo \$$K)
  "$B" $SU $FILES --single-unit -o $K.uhdm > $K.log 2>&1
  echo "$K rc=$?" >> rc.txt
done
for K in PRI PAT; do
  $CMP "$G" $K.uhdm > $K.cmp 2>&1
  echo "$MODE $K cmplines=$(grep -c . $K.cmp; true) heads=$(grep -c '^LHS:' $K.cmp; true)"
done
$DUMP "$G" > G.dump 2>&1
$DUMP PRI.uhdm > PRI.dump 2>&1
$DUMP PAT.uhdm > PAT.dump 2>&1
cat rc.txt
echo "WORKDIR $W"

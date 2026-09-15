#!/bin/bash
# r11u45/togold45.sh — DIRECTION OF EVERY BYTE MOVER.
#
# A mover is not a result; the DIRECTION is.  For each named row this prints
# the ORDER-BLIND whole-dump diff against the row's OWN golden (the cache path
# read out of that workdir's cmds.txt, so the wrong golden cannot be compared),
# before and after, split into:
#
#   MISSING-OURS  lines golden has that we do not  ('<' side)
#   EXTRA-OURS    lines we have that golden does not ('>' side)
#
# and then the per-line delta:  TO-GOLDEN  = lines that STOPPED differing,
#                               AWAY-GOLDEN= lines that STARTED differing.
# Dump paths embed the workdir, so both sides are normalised first (RESUME §9).
#
#   usage: togold45.sh <pristine_wd> <patched_wd> <mode> <name> [<name> ...]
set -u
WP=${1:?pristine workdir}; WQ=${2:?patched workdir}; MODE=${3:?mode}
shift 3
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
norm() {  # $1 = test dir, $2 = uhdm file
  "$DUMP" "$2" 2>&1 | sed "s#$1##g; s#/golden.uhdm##; s#slang.uhdm##" | sort
}
tot_to=0; tot_away=0; rows=0
for n in "$@"; do
  DP=$(ls -d "$WP/$MODE/$n"-*/ 2>/dev/null | head -1)
  DQ=$(ls -d "$WQ/$MODE/$n"-*/ 2>/dev/null | head -1)
  if [ -z "$DP" ] || [ -z "$DQ" ]; then echo "$n $MODE SKIP-NODIR"; continue; fi
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$DQ/cmds.txt" | head -1)
  if [ -z "$G" ] || [ ! -f "$G/golden.uhdm" ]; then echo "$n $MODE SKIP-NOGOLDEN"; continue; fi
  norm "$G" "$G/golden.uhdm" > /tmp/.tg45.g.$$
  norm "$DP" "$DP/slang.uhdm" > /tmp/.tg45.p.$$
  norm "$DQ" "$DQ/slang.uhdm" > /tmp/.tg45.q.$$
  # the DIFFERING line multisets, before and after
  diff /tmp/.tg45.g.$$ /tmp/.tg45.p.$$ | grep -E '^[<>]' | sort > /tmp/.tg45.dp.$$
  diff /tmp/.tg45.g.$$ /tmp/.tg45.q.$$ | grep -E '^[<>]' | sort > /tmp/.tg45.dq.$$
  bp=$(grep -c . /tmp/.tg45.dp.$$; true); bq=$(grep -c . /tmp/.tg45.dq.$$; true)
  to=$(comm -23 /tmp/.tg45.dp.$$ /tmp/.tg45.dq.$$ | grep -c .; true)
  aw=$(comm -13 /tmp/.tg45.dp.$$ /tmp/.tg45.dq.$$ | grep -c .; true)
  printf "%-30s %-9s before=%-5s after=%-5s TO-GOLDEN=%-4s AWAY-GOLDEN=%s\n" \
         "$n" "$MODE" "$bp" "$bq" "$to" "$aw"
  if [ "${VERBOSE:-0}" = 1 ]; then
    echo "  -- lines that STOPPED differing (TO-GOLDEN):"
    comm -23 /tmp/.tg45.dp.$$ /tmp/.tg45.dq.$$ | sed 's/^/     /'
    echo "  -- lines that STARTED differing (AWAY-GOLDEN):"
    comm -13 /tmp/.tg45.dp.$$ /tmp/.tg45.dq.$$ | sed 's/^/     /'
  fi
  tot_to=$((tot_to+to)); tot_away=$((tot_away+aw)); rows=$((rows+1))
  rm -f /tmp/.tg45.g.$$ /tmp/.tg45.p.$$ /tmp/.tg45.q.$$ /tmp/.tg45.dp.$$ /tmp/.tg45.dq.$$
done
echo "== rows=$rows  TO-GOLDEN=$tot_to  AWAY-GOLDEN=$tot_away"

#!/usr/bin/env bash
# r10uvm170repro/copies170.sh — THE PER-COPY TALLY.  MEASUREMENT ONLY.
#
#   CT170CEN=<ct170cen> PK170=<pk170> copies170.sh <workdir> <row-regex> <span-regex>
#
# A corpus database holds BOTH package views in ONE file (`design::AllPackages`
# = the DEF copy, `design::TopPackages` = the ELAB copy), so a span-keyed census
# cannot say WHICH COPY agreed.  This script joins each cast row's owner
# package UhdmId against `pk170`'s ALL/TOP listing and prints one line per
# (design, package, view) copy — which is the granularity the SeqDriver /
# SimpleUVM residue is stated at.
set -u
WD=${1:?workdir}; ROWS=${2:?row regex}; SPAN=${3:?span regex}
CEN=${CT170CEN:?}; PK=${PK170:?}
for mode in default testflags; do
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    row=$(basename "$d"); echo "$row" | grep -qE "$ROWS" || continue
    C=$d/cmds.txt; O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
    [ -n "$G" ] && G=$G/golden.uhdm
    [ -f "$G" ] && [ -f "$O" ] || { echo "SKIP $mode/$row"; continue; }
    for side in g o; do
      case $side in g) DB=$G;; o) DB=$O;; esac
      "$PK" "$DB" | awk '{print $2" "$3" "$1}' > /tmp/.copies170.$$
      "$CEN" "$DB" --casts 2>/dev/null | grep -E "$SPAN" |
      while IFS=$'\t' read -r _ span kind name rest; do
        own=$(echo "$rest" | awk -F'\t' '{print $NF}')
        pid=${own##*#}
        view=$(awk -v p="#$pid" '$2==p {print $3}' /tmp/.copies170.$$ | head -1)
        printf "%-10s %-24s %-4s %-14s %-22s %s\n" "$mode" "$row" "$side" \
               "${view:-?}" "${own%%#*}" "$kind($name)"
      done
    done
    rm -f /tmp/.copies170.$$
  done
done

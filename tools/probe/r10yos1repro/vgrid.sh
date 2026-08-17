#!/usr/bin/env bash
# r10yos1repro/vgrid.sh — the VERIFIER's adversarial grid for
# § dottedTopNameBareElab (33 arms in vgrid/, every one a real Surelog run).
#
#   usage: ./vgrid.sh <slang-uhdm binary> <tag> [outroot]
#          (outroot default /tmp/vyos1_vgrid)
#
# The implementer's grid.sh answers ONE question per arm (is the topModules
# entry bare or full?) on plain-module arms only.  This one runs the WHOLE
# comparison — the OFFICIAL uhdm-cmp (golden LHS, ours RHS) plus a span-stripped
# uhdm-dump diff — over the arm families the law's own domain contains and the
# implementer's grid never entered: a dotted top BESIDE plain tops (sharing a
# child or not, in both source orders), TWO dotted tops, dotted tops with
# param-dependent net ranges / packages / structs / processes / hier refs /
# binds / generates / INTERFACE instances, dotted PROGRAM and INTERFACE
# declarations, and the plain-only controls that make each reading falsifiable.
#
# GUARDS (each one paid for during this verification):
#   * the DUMP verdict is taken TWICE — raw and SPAN-STRIPPED.  Surelog's column
#     numbers on a line that carries an escaped identifier are offset by the
#     escaped name's length, so EVERY dotted arm reads `dump differ` on spans
#     alone; a raw-dump reading would have called 12 byte-perfect arms broken.
#     uhdm-cmp (which reads per-kind fields, never spans) stays the judge.
#   * uhdm-cmp's own exit status is captured immediately (a later command
#     substitution overwrites $?).
#   * a REJECT (no database) is printed and counted, never skipped: two arms
#     legitimately reject (slang cannot name an escaped top on --top, and
#     `interface`-ported dotted tops are not valid tops), and one arm makes
#     SURELOG itself segfault (v1_pkgonly, a dotted PACKAGE name) — that arm has
#     NO golden and therefore no verdict at all, which the table must say out
#     loud rather than leave blank.
set -u
OURS=${1:?our slang-uhdm binary}
TAG=${2:?tag}
ROOT=${3:-/tmp/vyos1_vgrid}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
ARMS=$HERE/vgrid
OUT=$ROOT/out_$TAG
[ -x "$SURELOG" ] || { echo "FATAL: no surelog at $SURELOG"; exit 3; }
[ -x "$OURS" ] || { echo "FATAL: no binary at $OURS"; exit 3; }
mkdir -p "$OUT" || exit 1
nsum=0
printf "%-24s %-8s %-8s %-6s %-8s %s\n" ARM SURELOG OURS CMP NOSPAN NOTE
for f in "$ARMS"/*; do
  arm=$(basename "$f"); arm=${arm%.*}
  d=$OUT/$arm; rm -rf "$d"; mkdir -p "$d"
  ( cd "$ARMS" && "$SURELOG" -parse "$f" -mt 0 -mp 0 -o "$d/sl" > "$d/sl.log" 2>&1 )
  n=$(find "$d/sl" -name surelog.uhdm 2>/dev/null | wc -l)
  g=$(find "$d/sl" -name surelog.uhdm 2>/dev/null | head -1)
  if [ "$n" != 1 ]; then
    printf "%-24s %-8s %-8s %-6s %-8s %s\n" "$arm" "NODB($n)" - - - \
      "no golden: surelog produced $n databases"
    continue
  fi
  ( cd "$ARMS" && "$OURS" "$f" --single-unit -o "$d/ours.uhdm" > "$d/ours.log" 2>&1 )
  orc=$?
  if [ ! -f "$d/ours.uhdm" ]; then
    printf "%-24s %-8s %-8s %-6s %-8s %s\n" "$arm" ok "REJECT($orc)" - - \
      "$(grep -im1 error "$d/ours.log" | cut -c1-58)"
    continue
  fi
  "$CMP" "$g" "$d/ours.uhdm" > "$d/cmp.txt" 2>&1
  crc=$?
  "$DUMP" "$g" | tail -n +2 > "$d/g.dump"
  "$DUMP" "$d/ours.uhdm" | tail -n +2 > "$d/o.dump"
  raw=match; cmp -s "$d/g.dump" "$d/o.dump" || raw=differ
  for s in g o; do
    sed -E 's/, ?line:[0-9]+:[0-9]+//g; s/, ?endln:[0-9]+:[0-9]+//g' \
        "$d/$s.dump" > "$d/$s.nospan"
  done
  ns=$(diff "$d/g.nospan" "$d/o.nospan" | grep -c '^[<>]' || true)
  nsum=$((nsum+ns))
  printf "%-24s %-8s %-8s %-6s %-8s %s\n" "$arm" ok ok \
    "$([ "$crc" = 0 ] && echo EQUAL || echo NE)" "$ns" \
    "heads=$(grep -c '^LHS:' "$d/cmp.txt") rawdump=$raw"
done
echo "TOTAL span-stripped dump-diff lines over all arms: $nsum"

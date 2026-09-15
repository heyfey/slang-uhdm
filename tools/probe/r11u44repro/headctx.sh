#!/bin/bash
# r11u44repro/headctx.sh — the head's OBJECT, its PARENT and its SOURCE LINE.
#
# `facediff.py` blinds the source location on purpose: no generated Compare
# reads VpiFile/line/col, so a location-only difference is noise IN THE FACE.
# But the location is exactly what names the CONSTRUCT a face sits on, and a
# cluster claim is only readable with the construct quoted.  This prints, per
# row: the head object kind, the `\_parent` kind directly under `|vpiParent:`,
# golden's `line:L:C`, and the SOURCE TEXT of line L in the test's own sources.
#
# LHS is ALWAYS golden.  When the head fired with `LHS: <null>` (golden has
# nothing where we emit), the location is read from the RHS block instead and
# the row is marked OURS-SIDE.
#
#   usage: headctx.sh <cmpdir> <corpus-root> <name> [<name> ...]
#     <corpus-root>  the directory holding <name>/ (uhdm2rtlil) — pass '-' to
#                    skip the source quote (the surelog suite spreads its
#                    sources over many trees).
set -u
CMPD=${1:?cmpdir}; ROOT=${2:?corpus root or -}; shift 2
for n in "$@"; do
  f=$CMPD/$n.default.cmp
  [ -f "$f" ] || { echo "$n NO-CMP"; continue; }
  side=LHS
  # the first decompile block after LHS:; if it is <null>, read RHS instead
  blk=$(awk '/^LHS:/{p=1;next} /^RHS:/{exit} p' "$f" | grep -v '^decompile:$' | grep -v '^$')
  if [ -z "$blk" ] || [ "$(printf '%s\n' "$blk" | head -1)" = "<null>" ]; then
    side=RHS
    blk=$(awk '/^RHS:/{p=1;next} p' "$f" | grep -v '^decompile:$' | grep -v '^$')
  fi
  head=$(printf '%s\n' "$blk" | head -1)
  par=$(printf '%s\n' "$blk" | awk '/^\|vpiParent:/{getline; print; exit}')
  loc=$(printf '%s\n' "$head" | grep -oE 'line:[0-9]+:[0-9]+' | head -1)
  ln=${loc#line:}; ln=${ln%%:*}
  echo "== $n   side=$side  $loc"
  echo "   HEAD  : $head"
  echo "   PARENT: ${par:-<none>}"
  if [ "$ROOT" != "-" ] && [ -n "${ln:-}" ] && [ -d "$ROOT/$n" ]; then
    for s in "$ROOT/$n"/*.sv "$ROOT/$n"/*.v; do
      [ -f "$s" ] || continue
      t=$(sed -n "${ln}p" "$s" 2>/dev/null)
      [ -n "$t" ] && echo "   SRC[$(basename "$s"):$ln]: $t"
    done
  fi
done

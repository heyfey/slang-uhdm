#!/bin/bash
# r11u4 — THE ANTI-REGRESSION SCORER FOR § ifacePortViewPaFoldsDeclDefault.
#
#   usage: pagree.sh <pristine-workdir> <patched-workdir> <name>...
#
# WHY r11v1's agree.sh IS NOT ENOUGH HERE, said out loud: its census
# (r11u1repro/ifcen.py) renders an AGGREGATE param_assign Rhs as the bare word
# `operation` with NO value, so a port view holding the WRONG struct value and
# one holding the right one produce the SAME census row.  Measured on this
# pass's own converting test: `agree.sh <patched> <pristine>
# iface_array_elem_cfg_param` — the POSITIVE CONTROL, arguments swapped, which
# must read the conversion back as a loss — scores LOST=0 and prints PASS.  It
# is blind, exactly as residue R1b warned.
#
# This scorer keys on the param_assign GRID instead (pagrid.py): per
# (interface_inst fullname, parameter name) it records the vpiOverriden stamp,
# the Rhs object kind and span, the Rhs value lines, and whether the Rhs
# carries a vpiTypespec ref — every field the law writes.  LOST is the number
# of rows that matched GOLDEN before the patch and do not after.
set -u
P=${1:?pristine workdir}; Q=${2:?patched workdir}; shift 2
HERE=$(dirname "$(readlink -f "$0")")
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
T=$(mktemp -d); tot=0; seen=0
printf "%-34s %8s %8s %6s\n" TEST agree_p agree_q LOST
for n in "$@"; do for m in default testflags; do
  dp=$(ls -d "$P/$m/$n"-*/ 2>/dev/null|head -1); dq=$(ls -d "$Q/$m/$n"-*/ 2>/dev/null|head -1)
  [ -z "$dp" ] || [ -z "$dq" ] && continue
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$dp/cmds.txt"|head -1)
  [ -n "$G" ] && G=$G/golden.uhdm
  [ -f "$G" ] && [ -f "$dp/slang.uhdm" ] && [ -f "$dq/slang.uhdm" ] || {
      printf "%-34s %8s %8s %6s\n" "$n/$m" - - SKIP-NOFILE; continue; }
  $DUMP "$G" > "$T/g.d" 2>/dev/null
  $DUMP "$dp/slang.uhdm" > "$T/p.d" 2>/dev/null
  $DUMP "$dq/slang.uhdm" > "$T/q.d" 2>/dev/null
  for x in g p q; do python3 "$HERE/pagrid.py" "$T/$x.d" | sort > "$T/$x.cen"; done
  ap=$(comm -12 "$T/g.cen" "$T/p.cen"|grep -c .; true)
  aq=$(comm -12 "$T/g.cen" "$T/q.cen"|grep -c .; true)
  comm -23 <(comm -12 "$T/g.cen" "$T/p.cen") <(comm -12 "$T/g.cen" "$T/q.cen") > "$T/lost"
  lost=$(grep -c . "$T/lost"; true)
  printf "%-34s %8s %8s %6s\n" "$n/$m" "$ap" "$aq" "$lost"
  [ "$lost" != 0 ] && sed 's/^/    LOST /' "$T/lost"
  tot=$((tot+lost)); seen=$((seen+1))
done; done
echo "---- scored=$seen  TOTAL-LOST=$tot"
rm -rf "$T"
[ "$seen" = 0 ] && { echo "FAIL: nothing scored (a zero here is NOT a pass)"; exit 8; }
[ "$tot" = 0 ] && echo "PASS: no param-grid row that matched golden stopped matching." \
               || echo "FAIL: rows moved AWAY from golden -- read them above."

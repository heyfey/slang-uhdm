#!/usr/bin/env bash
# r10yos1repro/grid.sh — the § dottedTopNameBareElab GRID.
#
# Runs Surelog on 10 purpose-built arms and reports, for each, the ONE thing
# the law is about: does the design's uhdmtopModules entry come back FULLY
# ELABORATED or as a BARE SHELL?
#
#   usage: ./grid.sh [outdir]           (default: /tmp/r10yos1_grid)
#
# The arms are chosen to separate four candidate discriminators:
#   * escaping vs the DOT           d_escnodot / f_escbracket / g_escdollar
#                                   are escaped-but-dotless and elaborate FULLY
#   * top vs child                  h_dotchild puts the dotted name on the
#                                   CHILD and elaborates FULLY
#   * whole design vs per top       i_/j_ mix a dotted top with a plain one and
#                                   show the plain one still elaborates
#   * "has children" vs "is a top"  e_escdot_nochild has NO child instance and
#                                   is STILL bare, so it is not a child-walk
#                                   failure but the top instance itself
#
# GUARDS:
#   * every arm is a REAL Surelog run into its own directory; nothing is cached
#     or reused, so a stale database can never be read as a result;
#   * BARE/FULL is decided by counting the module_inst's own child fields in
#     uhdm-dump (vpiNet/vpiPort/vpiContAssign/vpiModule/vpiProcess/vpiParameter)
#     rather than by eyeballing, and the raw counts are printed;
#   * Surelog's own "Nb instances" line is printed beside it as an INDEPENDENT
#     witness — the two must agree or the reading is not trustworthy.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-/tmp/r10yos1_grid}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$SURELOG" ] || { echo "FATAL: no surelog at $SURELOG"; exit 3; }
[ -x "$UHDM_DUMP" ] || { echo "FATAL: no uhdm-dump at $UHDM_DUMP"; exit 3; }
mkdir -p "$OUT" || exit 1

printf "%-24s %-28s %5s %5s %s\n" ARM TOP NBINST KIDS VERDICT
for f in "$HERE"/grid/*.v; do
  arm=$(basename "$f" .v)
  d=$OUT/run_$arm
  rm -rf "$d"; mkdir -p "$d"
  ( cd "$d" && "$SURELOG" -parse -nopython -fileunit "$f" -o . > sl.log 2>&1 )
  db=$d/slpp_unit/surelog.uhdm
  if [ ! -f "$db" ]; then
    printf "%-24s %-28s %5s %5s %s\n" "$arm" - - - NO-DATABASE
    continue
  fi
  "$UHDM_DUMP" "$db" > "$OUT/$arm.dump" 2>&1
  nb=$(sed -n 's/.*Nb instances: \([0-9]*\).*/\1/p' "$d/sl.log" | head -1)
  # The topModules section: everything from |uhdmtopModules: to the
  # weaklyReferenced tail.  Each entry is a col-0 \_module_inst.
  awk '/^\|uhdmtopModules:/{p=1;next} /^\\_weaklyReferenced:/{p=0} p' \
      "$OUT/$arm.dump" > "$OUT/$arm.tops"
  # Report each top separately: name, then how many of ITS OWN child fields
  # (indent 2) exist.  A bare shell has zero.
  awk -v arm="$arm" '
    /^\\_module_inst:/ { if (nm != "") emit(); nm=$0; sub(/^\\_module_inst: /,"",nm);
                         sub(/ .*/,"",nm); kids=0; next }
    /^  \|vpi(Net|Port|ContAssign|Module|Process|Parameter|ParamAssign|TaskFunc|Variables|GenScopeArray|RefModule|Primitive|Interface|InstanceArray):/ { kids++ }
    END { if (nm != "") emit() }
    function emit() {
      printf "%-24s %-28s %5s %5s %s\n", arm, nm, NB, kids,
             (kids == 0 ? "BARE-SHELL" : "FULL-ELAB")
    }
  ' NB="$nb" "$OUT/$arm.tops"
done
echo
echo "LAW § dottedTopNameBareElab: a design top whose module NAME contains a"
echo "'.' is NOT elaborated — its uhdmtopModules entry is a bare module_inst"
echo "(vpiName/vpiDefName/vpiTop/vpiTopModule + source range and nothing else)."
echo "The def view (uhdmallModules) is unaffected.  Per-top, not per-design."

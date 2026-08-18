#!/usr/bin/env bash
# r10rgg8/attrib8.sh — ORDER-BLIND attribution of a byteverify MOVER.
#
#   usage: attrib8.sh <workdir> <mode>/<dir> <base-bin> <pat-bin>
#
# WHY.  `default/Scoreboard` is a documented ~50/50 COIN of this campaign (the
# emitter compares SourceLocations across macro buffers and the answer flips per
# run under parallel parse).  A raw base-vs-patched byte diff CANNOT tell that
# coin apart from a real move, so the attribution runs the SAME BASE BINARY
# TWICE and reports whether the two runs of one program already differ.  If they
# do, base-vs-patched byte inequality on that row is NOT ATTRIBUTABLE to the
# patch, and the row's own uhdm-cmp status (measured by the corpus gate) is the
# judge.
# GUARD: a run that produces no database is NORUN and the script exits 3, so a
# missing measurement can never read as "the coin".
set -u
WD=${1:?workdir}; ROW=${2:?mode/dir}; A=${3:?base}; B=${4:?pat}
C=$WD/$ROW/cmds.txt
[ -f "$C" ] || { echo "FATAL: no $C"; exit 3; }
line=$(sed -n 's/^slang:  *//p' "$C" | head -1)
[ -n "$line" ] || { echo "FATAL: no slang line"; exit 3; }
set -- $line
shift
argv=("$@")
# The recorded argv is RELATIVE TO THE TEST DIRECTORY (verify_golden.py runs it
# with cwd=dirpath), so a re-run from anywhere else finds no sources and produces
# no database -- which is exactly the NORUN this script exits 3 on.  The test dir
# is recovered from the row name via verify_golden.py's own discovery.
NAME=$(basename "$ROW"); NAME=${NAME%-*}
CORPUS=${CORPUS:-surelog}
DIR=$(python3 - "$NAME" "$CORPUS" <<'PYX'
import importlib.util, os, sys
here = os.path.dirname(os.path.abspath('.'))
spec = importlib.util.spec_from_file_location(
    'vg', os.path.join(os.environ.get('WT', '/tmp/wt_r10rgg8'),
                       'scripts', 'verify_golden.py'))
vg = importlib.util.module_from_spec(spec); spec.loader.exec_module(vg)
t = (vg.discover_surelog(None) if sys.argv[2] == 'surelog'
     else vg.discover_uhdm2rtlil(None))
print(t[sys.argv[1]][0] if sys.argv[1] in t else '')
PYX
)
[ -n "$DIR" ] || { echo "FATAL: cannot locate test dir for $NAME"; exit 3; }
echo "TESTDIR $DIR"
cd "$DIR" 
run() { # $1 = binary, $2 = out
  local i; local -a a=("${argv[@]}")
  for i in "${!a[@]}"; do [ "${a[$i]}" = "-o" ] && a[$((i+1))]=$2; done
  "$1" "${a[@]}" > /dev/null 2>&1
  [ -f "$2" ] || { echo "NORUN $1"; exit 3; }
}
run "$A" /tmp/r10rgg8_at_a1.uhdm
run "$A" /tmp/r10rgg8_at_a2.uhdm
run "$B" /tmp/r10rgg8_at_b1.uhdm
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
echo "ROW $ROW"
cmp -s /tmp/r10rgg8_at_a1.uhdm /tmp/r10rgg8_at_a2.uhdm \
  && echo "  base-run1 vs base-run2 : IDENTICAL  (no coin here)" \
  || echo "  base-run1 vs base-run2 : DIFFER     -> THE COIN, this row is not attributable to the patch"
cmp -s /tmp/r10rgg8_at_a1.uhdm /tmp/r10rgg8_at_b1.uhdm \
  && echo "  base-run1 vs pat-run1  : IDENTICAL" || echo "  base-run1 vs pat-run1  : DIFFER"
for f in a1 a2 b1; do "$DUMP" /tmp/r10rgg8_at_$f.uhdm 2>&1 | tail -n +2 > /tmp/r10rgg8_at_$f.dump; done
echo "  DUMP a1 vs a2 : $(cmp -s /tmp/r10rgg8_at_a1.dump /tmp/r10rgg8_at_a2.dump && echo same || echo differ)"
echo "  DUMP a1 vs b1 : $(cmp -s /tmp/r10rgg8_at_a1.dump /tmp/r10rgg8_at_b1.dump && echo same || echo differ)"
echo "  DUMP a2 vs b1 : $(cmp -s /tmp/r10rgg8_at_a2.dump /tmp/r10rgg8_at_b1.dump && echo same || echo differ)"
rm -f /tmp/r10rgg8_at_*.uhdm

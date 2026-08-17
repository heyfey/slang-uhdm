#!/bin/bash
# r10uvm55repro/canaudit.sh — AUDIT THE CANARY SCRIPTS AGAINST THE BRIEF.
#
# The dominant failure mode of this campaign is a CITED GUARD THAT DOES NOT
# COVER WHAT THE CITATION CLAIMS — first a typo'd name that "can never read as
# green" and silently was skipped, then 52 rows across three FAMILIES named in
# every brief and carried by no script.  Both were found by AUDITING the guard's
# own list.  This script does that audit mechanically, so the claim "every name
# the brief protects is checked" is a RUN, not a sentence.
#
#   usage: canaudit.sh <canaries.sh> <ctcan2.sh>
#
# For each brief-protected NAME it reports which script carries it (NAMES list or
# EXACT list or a PREFIX pattern), and for each of the four SLANG-FENCED names it
# asserts that NO driver in this directory mentions it at all.
#
# GUARDS: a name covered by NEITHER script is UNCOVERED and exit 5; a fenced name
# found in ANY driver is FENCE-BREACH and exit 6.  A run with zero brief names
# would be vacuous, so the brief-name count is printed and a count of 0 is exit 4.
set -u
CAN=${1:?path to canaries.sh}
CT=${2:?path to ctcan2.sh}
HERE=$(cd "$(dirname "$0")" && pwd)
[ -f "$CAN" ] || { echo "FATAL: no $CAN"; exit 3; }
[ -f "$CT" ]  || { echo "FATAL: no $CT"; exit 3; }

# The standing brief's protected list, transcribed verbatim from the r10uvm55
# brief's CANARIES paragraph.
BRIEF="InterfaceModPort BlackParrotComplex YosysBigSimReed YosysOldOpen YosysOldOr
SVSwitch TypespecExpr ClogCast 2DFunctionArg PartSelect4 ClassParamAsParam
ClassTypeParam SimpleConstraint ApbSlave InterfaceBinding InterfaceModExp
BindHierPath EnumConcat LowMemPkg Scr1SvTests BasicOh ClassExtends FuncStruct
FuncStructVal FuncIoTypespec Earlgrey_0_1"
# The three FAMILIES the brief names with their row counts.
FAMS="EvalFunc ParamFile Black"
# NEVER dispatch these four.
FENCED="UnsignedParam HierPathEval FileLocalParam TopParam"

n=0; uncovered=0
echo "== brief-protected NAMES =="
for b in $BRIEF; do
  n=$((n+1))
  where=""
  grep -q "\b$b\b" "$CAN" && where="$where canaries.sh:NAMES"
  grep -q "\b$b\b" "$CT"  && where="$where ctcan2.sh:EXACT"
  # a family PREFIX in ctcan2.sh covers a name that starts with it
  for p in $FAMS; do
    case "$b" in "$p"*) grep -q "PREFIX=.*$p" "$CT" && where="$where ctcan2.sh:PREFIX($p)";; esac
  done
  if [ -z "$where" ]; then
    printf '  %-22s UNCOVERED\n' "$b"; uncovered=$((uncovered+1))
  else
    printf '  %-22s covered by:%s\n' "$b" "$where"
  fi
done
echo "== brief-named FAMILIES =="
for p in $FAMS; do
  n=$((n+1))
  if grep -q "PREFIX=.*$p" "$CT"; then
    printf '  %-22s covered by: ctcan2.sh:PREFIX\n' "$p*"
  else
    printf '  %-22s UNCOVERED\n' "$p*"; uncovered=$((uncovered+1))
  fi
done
# ---------------------------------------------------------------- FENCE CHECK
# CORRECTED AT r10buvm5, and the correction is the same class of defect this
# script was written to catch.  The old test was a bare `grep -rl`: ANY mention
# of a fenced name in ANY driver was a FENCE-BREACH.  That cannot tell a
# DISPATCH from the FENCE ITSELF — r10buvm5's census driver and its TSV builder
# both have to NAME the four tests in order to REFUSE to run them, and the old
# check reported FENCE-BREACH=4 for a directory that dispatches none of them.
# An instrument that flags the guard as the violation is unusable in exactly the
# direction that matters: the next author silences it.
#
# THE RULE, and it is auditable: an EXCLUSION LIST IS EXHAUSTIVE.  A line that
# names ALL FOUR fenced tests together is a fence (`UnsignedParam|HierPathEval|
# FileLocalParam|TopParam)` in a shell `case`, `{'UnsignedParam', ...}` in a
# python set).  A line that names SOME of them is a dispatch, or a fence with a
# hole in it, and either way it is a BREACH.
# The SELF-TEST below proves the corrected check still fires: it plants a real
# one-name dispatch in a scratch directory and requires exactly that report.
fence_scan() {   # fence_scan <dir> <self-name>; prints one line per breach
  local dir=$1 self=$2 f hits
  for f in $FENCED; do
    hits=$(grep -rn "\b$f\b" "$dir" 2>/dev/null \
             | grep -v "/README.md:" | grep -v "/$self:" \
             | awk -F: -v a="$1" '{ line=$0; sub(/^[^:]*:[0-9]*:/, "", line);
                   n=0
                   if (line ~ /UnsignedParam/)  n++
                   if (line ~ /HierPathEval/)   n++
                   if (line ~ /FileLocalParam/) n++
                   if (line ~ /TopParam/)       n++
                   if (n < 4) print $1":"$2 }' || true)
    [ -n "$hits" ] && printf '%s\t%s\n' "$f" "$(echo "$hits" | tr '\n' ' ')"
  done
  return 0
}
echo "== SLANG-FENCED names: no DISPATCH in any driver here =="
SELF=$(basename "$0")
breach=0
fscan=$(fence_scan "$HERE" "$SELF")
for f in $FENCED; do
  line=$(printf '%s\n' "$fscan" | awk -F'\t' -v n="$f" '$1==n {print $2}')
  if [ -n "$line" ]; then
    printf '  %-22s FENCE-BREACH at: %s\n' "$f" "$line"; breach=$((breach+1))
  else
    printf '  %-22s not dispatched by any driver (OK)\n' "$f"
  fi
done
# SELF-TEST (negative control): a planted DISPATCH must be reported.  Without it
# the corrected check could be silently over-permissive — which is precisely how
# the FIRST version of this guard failed.
FT=$(mktemp -d)
printf 'run_test TopParam --single-unit\n' > "$FT/planted_driver.sh"
ctl=$(fence_scan "$FT" "$SELF")
if printf '%s' "$ctl" | grep -q '^TopParam'; then
  echo "  SELF-TEST: planted one-name dispatch REPORTED (guard is live)"
else
  echo "  SELF-TEST FAILED: planted dispatch not reported"; rm -rf "$FT"; exit 7
fi
printf 'case "$n" in UnsignedParam|HierPathEval|FileLocalParam|TopParam) skip;; esac\n' \
    > "$FT/planted_driver.sh"
ctl2=$(fence_scan "$FT" "$SELF")
if [ -z "$ctl2" ]; then
  echo "  SELF-TEST: a full four-name EXCLUSION is not a breach (no false alarm)"
else
  echo "  SELF-TEST FAILED: exclusion list reported as a breach"; rm -rf "$FT"; exit 7
fi
rm -rf "$FT"
echo "---- audited=$n  UNCOVERED=$uncovered  FENCE-BREACH=$breach"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: audited 0 names"; exit 4; }
[ "$breach" -eq 0 ] || exit 6
[ "$uncovered" -eq 0 ] || exit 5
echo "PASS: every brief-protected name and family is carried by a script that RUNS here."

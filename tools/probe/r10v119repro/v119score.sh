#!/usr/bin/env bash
# r10v119repro — see README.md §"How to re-run". MEASUREMENT ONLY.
# Owner-keyed, Compare-visible-payload score of the LAW'S OWN CELLS against golden.
# For each mover database: extract every dump line that mentions one of the law's
# source positions (a sorted MULTISET), then classify per row:
#   TO-GOLDEN  : golden has it, pristine did not, patched does
#   AWAY       : golden has it, pristine did, patched does NOT
#   STILL-WRONG: patched has it, golden does not, pristine did not have it either (new surplus)
#   RESIDUE    : golden has it, neither pristine nor patched
set -u
PAT=${PAT:?patched verify_golden workdir root (…/sl)}
PRIS=${PRIS:?pristine verify_golden workdir root (…/sl)}
DUMP=$HOME/.local/bin/uhdm-dump
O=${OUT:-/tmp/v119_score}; mkdir -p $O
tot_to=0; tot_away=0; tot_new=0
printf "%-26s %9s %6s %9s %9s\n" CELL TO-GOLDEN AWAY NEW-SURPL GOLD-RESID
for rel in default/SeqDriver default/SimpleUVM default/Scoreboard default/MiniAmiq default/BuildUVMPkg testflags/SeqDriver testflags/SimpleUVM testflags/MiniAmiq testflags/BuildUVMPkg; do
  d=$(ls -d $PAT/${rel}-*/ | head -1); base=$(basename $d)
  gc=$(grep -oE '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-z]+' $d/cmds.txt | head -1)
  g="$gc/golden.uhdm"
  [ -f "$g" ] || { echo "$rel NO-GOLDEN($g)"; continue; }
  tag=$(echo $rel | tr / .)
  case $rel in *BuildUVMPkg*) POS='line:56967:|line:56980:';; *) POS='line:299:|line:204:';; esac
  $DUMP "$g" 2>/dev/null | sed 's/, id:[0-9]*//g; s/^[[:space:]]*//' | grep -E "$POS" | sort > $O/$tag.g
  $DUMP "$d/slang.uhdm" 2>/dev/null | sed 's/, id:[0-9]*//g; s/^[[:space:]]*//' | grep -E "$POS" | sort > $O/$tag.b
  $DUMP "$PRIS/$rel-${base#*-}/slang.uhdm" 2>/dev/null | sed 's/, id:[0-9]*//g; s/^[[:space:]]*//' | grep -E "$POS" | sort > $O/$tag.a
  to=$(comm -23 <(comm -12 $O/$tag.g $O/$tag.b) $O/$tag.a | wc -l)
  away=$(comm -23 <(comm -12 $O/$tag.g $O/$tag.a) $O/$tag.b | wc -l)
  new=$(comm -23 <(comm -13 $O/$tag.g $O/$tag.b) <(comm -13 $O/$tag.g $O/$tag.a) | wc -l)
  resid=$(comm -23 $O/$tag.g $O/$tag.b | wc -l)
  printf "%-26s %9s %6s %9s %9s\n" $rel $to $away $new $resid
  tot_to=$((tot_to+to)); tot_away=$((tot_away+away)); tot_new=$((tot_new+new))
  if [ "$away" != 0 ]; then echo "  --- AWAY rows:"; comm -23 <(comm -12 $O/$tag.g $O/$tag.a) $O/$tag.b | sed 's/^/    /'; fi
  if [ "$new" != 0 ]; then echo "  --- NEW-SURPLUS rows:"; comm -23 <(comm -13 $O/$tag.g $O/$tag.b) <(comm -13 $O/$tag.g $O/$tag.a) | sed 's/^/    /'; fi
done
echo "TOTAL TO-GOLDEN=$tot_to AWAY=$tot_away NEW-SURPLUS=$tot_new"

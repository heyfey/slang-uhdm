#!/bin/bash
# r11u44repro/survey2.sh — the WHOLE second triage, reproducible from a pristine tree.
#
# MEASUREMENT ONLY.  No production file is touched.  The judge is the official
# uhdm-cmp; everything this script writes is a reading of its output, plus the
# order-blind whole-dump distance beside it.
#
# WHAT IT DOES, in the order the report's numbers were made:
#   0. builds the FENCED exclusion list from a COMMITTED driver's own FENCED=
#      line (the fenced test names are never spelled in this pass);
#   1. reads the not-equal ROW SET out of the READ-ONLY baseline CSVs and
#      turns it into an ANCHORED --filter regex, so only those tests are swept;
#   2. sweeps both corpora, both modes, --jobs 2, into this pass's OWN workdirs
#      with SLANG_UHDM exported to a FROZEN md5-verified copy of the pinned
#      binary (the harness silently defaults to the MAIN-TREE binary);
#   3. one uhdm-cmp head per row through the committed rowheads.sh;
#   4. proves the default and testflags heads are the SAME head id-blind;
#   5. decodes each head to its FACE (facediff.py) and to its CONSTRUCT
#      (headctx.sh: object, parent, source line);
#   6. measures the order-blind whole-dump distance per row (dumpdist.sh);
#   7. runs BOTH positive controls: known-EQUAL rows must read 0 heads, and
#      must read the distance instrument's FLOOR (2) and nothing more.
#
#   usage: survey2.sh <scratchdir>            (default /tmp/r11u44_scratch)
#   env:   SLANG_UHDM_SRC  the pinned binary to freeze and use
#          REPO           the slang-uhdm worktree holding scripts/verify_golden.py
set -u
S=${1:-/tmp/r11u44_scratch}
REPO=${REPO:-$(cd "$(dirname "$0")/../../.." && pwd)}
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=${SLANG_UHDM_SRC:-$REPO/build/slang-uhdm}
PIN=${PIN_MD5:-68790dddaa8db9c045ceeef4330527ec}
mkdir -p "$S/out" || exit 1

# 2. freeze the binary and VERIFY it against the pin before anything runs.
cp "$SRC" "$S/slang-uhdm" && chmod 555 "$S/slang-uhdm"
got=$(md5sum "$S/slang-uhdm" | cut -d' ' -f1)
[ "$got" = "$PIN" ] || { echo "FATAL: binary md5 $got != pin $PIN"; exit 3; }
export SLANG_UHDM=$S/slang-uhdm

# 0. the fence list, from a committed driver — never spelled here.
sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/../r10sd4repro/canaudit.sh" | tr ' ' '\n' | grep -c . >/dev/null
sed -n 's/^FENCED="\(.*\)"$/\1/p' "$HERE/../r10sd4repro/canaudit.sh" | tr ' ' '\n' > "$S/fenced.txt"

# 1. the row set, from the READ-ONLY baselines.
awk -F, 'NR>1 && $3=="CMP_NOTEQUAL"{print $1}' "$REPO/results/golden_surelog.csv" | sort -u \
  | grep -vFf "$S/fenced.txt" > "$S/sl_tests.txt"
awk -F, 'NR>1 && $3=="CMP_NOTEQUAL"{print $1}' "$REPO/results/golden_uhdm2rtlil.csv" | sort -u > "$S/u2r_tests.txt"
echo "tests: surelog $(grep -c . "$S/sl_tests.txt")  uhdm2rtlil $(grep -c . "$S/u2r_tests.txt")"

for c in u2r sl; do
  [ $c = u2r ] && { corpus=uhdm2rtlil; L=$S/u2r_tests.txt; } || { corpus=surelog; L=$S/sl_tests.txt; }
  RE="^($(paste -sd'|' "$L"))\$"
  mkdir -p "$S/wd_$c"
  python3 "$REPO/scripts/verify_golden.py" --corpus "$corpus" --mode both --jobs 2 \
      --filter "$RE" --workdir "$S/wd_$c" --out "$S/out/$c.csv" > "$S/out/$c.log" 2>&1
  bash "$HERE/../r10uvm67repro/rowheads.sh" "$S/wd_$c" "$S/out/cmp_$c" $(cat "$L") > "$S/out/rowheads_$c.txt" 2>&1
  for m in default testflags; do
    bash "$HERE/dumpdist.sh" "$S/wd_$c" "$m" "$S/out/dump" $(cat "$L") > "$S/out/dumpdist_$c.$m.txt" 2>&1
  done
done

# 4. mode identity, id-blind
: > "$S/out/mode_identity.txt"
for d in "$S/out/cmp_u2r" "$S/out/cmp_sl"; do
  for f in "$d"/*.default.cmp; do
    n=$(basename "$f" .default.cmp); t="$d/$n.testflags.cmp"
    if [ ! -f "$t" ]; then echo "$n ONE-MODE-ONLY" >> "$S/out/mode_identity.txt"; continue; fi
    if diff -q <(sed -E 's/id:[0-9]+/id:#/g' "$f") <(sed -E 's/id:[0-9]+/id:#/g' "$t") >/dev/null
    then echo "$n IDBLIND-SAME" >> "$S/out/mode_identity.txt"
    else echo "$n MODE-SPLIT"  >> "$S/out/mode_identity.txt"; fi
  done
done
echo "MODE-SPLIT rows: $(grep -c MODE-SPLIT "$S/out/mode_identity.txt" || true)"

# 5. faces and constructs
python3 "$HERE/../r11u29repro/facediff.py" --key "$S/out"/cmp_*/*.default.cmp > "$S/out/faces.key.txt"
python3 "$HERE/../r11u29repro/facediff.py"       "$S/out"/cmp_*/*.default.cmp > "$S/out/faces.full.txt"
bash "$HERE/headctx.sh" "$S/out/cmp_u2r" "$HOME/git-repos/uhdm2rtlil/test" $(cat "$S/u2r_tests.txt") > "$S/out/headctx_u2r.txt"
bash "$HERE/headctx.sh" "$S/out/cmp_sl"  -                                 $(cat "$S/sl_tests.txt")  > "$S/out/headctx_sl.txt"

# 7. BOTH positive controls, on rows the baselines call CMP_EQUAL.
for c in u2r sl; do
  [ $c = u2r ] && { corpus=uhdm2rtlil; base=$REPO/results/golden_uhdm2rtlil.csv; } \
                || { corpus=surelog;   base=$REPO/results/golden_surelog.csv; }
  CTL=$(awk -F, 'NR>1 && $3=="CMP_EQUAL"{print $1}' "$base" | sort -u | head -2)
  RE="^($(printf '%s\n' $CTL | paste -sd'|'))\$"
  mkdir -p "$S/wd_ctl_$c"
  python3 "$REPO/scripts/verify_golden.py" --corpus "$corpus" --mode both --jobs 2 \
      --filter "$RE" --workdir "$S/wd_ctl_$c" --out "$S/out/ctl_$c.csv" > "$S/out/ctl_$c.log" 2>&1
  echo "== POSITIVE CONTROL heads ($corpus): must read 0"
  bash "$HERE/../r10uvm67repro/rowheads.sh" "$S/wd_ctl_$c" "$S/out/cmp_ctl" $CTL
  echo "== POSITIVE CONTROL distance ($corpus): must read the floor, 2"
  bash "$HERE/dumpdist.sh" "$S/wd_ctl_$c" default "$S/out/dumpctl" $CTL
done

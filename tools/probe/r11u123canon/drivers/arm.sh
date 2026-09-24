#!/bin/bash
# arm.sh <arm dir> [<variant golden dir>]: build the arm's golden with the pinned Surelog
# (check_probe.py SL_ARGS) and ours with the frozen 1fc087af binary, then run uhdm-cmp and
# the strict comparator raw (--no-canon) and canonical, with record dumps.
# Scratch: /tmp/r11u123_arm/<arm>/ ; evidence: <repro>/evidence/<arm>/{cmp,raw,canon}.txt
# Every golden is built fresh (no cache: edited arms must never read a stale golden).
set -u
A=$(realpath "$1"); N=$(basename "$A")
R=$(realpath "$(dirname "$0")/..")
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
UHDM_CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SLANG_UHDM=${SLANG_UHDM:-/tmp/r11u123_bin/slang-uhdm}
SC=${SC:-/tmp/r11u123_bin/uhdm-strictcmp}
S=/tmp/r11u123_arm/$N; E=$R/evidence/$N
rm -rf "$S"; mkdir -p "$S/gold" "$E"
F=dut.sv; [ -n "${FILE_:-}" ] && F=$FILE_
(cd "$A" && "$SURELOG" -parse -nobuiltin -nocache -sv $F -mt 0 -mp 0 -o "$S/gold" > "$S/surelog.log" 2>&1)
G=$(find "$S/gold" -name '*.uhdm' | head -1)
rm -f "$S/ours.uhdm"
(cd "$A" && "$SLANG_UHDM" $F --single-unit --nobuiltin -o "$S/ours.uhdm" > "$S/slang.log" 2>&1); src=$?
{ echo "surelog: $SURELOG ($G)"; echo "slang: $SLANG_UHDM rc=$src"; echo "strictcmp: $SC"; } > "$E/cmds.txt"
"$UHDM_CMP" "$G" "$S/ours.uhdm" > "$E/cmp.txt" 2>&1; echo "uhdm-cmp rc=$?" >> "$E/cmp.txt"
run() { # tag, extra args, a, b
  local t=$1; shift; local x=$1; shift
  local t0=$(date +%s.%N)
  "$SC" --max 8 $x --dump-a "$S/$t.A" --dump-b "$S/$t.B" "$1" "$2" > "$E/$t.txt" 2>&1
  local rc=$?
  awk -v a=$t0 -v b=$(date +%s.%N) 'BEGIN{printf "wall=%.2f\n", b-a}' > "$S/$t.time"
  echo "rc=$rc records A=$(wc -l < "$S/$t.A" 2>/dev/null || echo -) B=$(wc -l < "$S/$t.B" 2>/dev/null || echo -) $(tail -1 "$S/$t.time")" >> "$E/$t.txt"
}
run raw --no-canon "$G" "$S/ours.uhdm"
run canon "" "$G" "$S/ours.uhdm"
# content adversary: v/dut.sv = dut.sv with a judge-blind edit (whitespace inside one
# declaration). Its golden differs from ours in CONTENT on top of any identity difference.
if [ -f "$A/v/dut.sv" ]; then
  mkdir -p "$S/goldv"
  (cd "$A/v" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$S/goldv" > "$S/surelogv.log" 2>&1)
  GV=$(find "$S/goldv" -name '*.uhdm' | head -1)
  echo "variant golden: $GV" >> "$E/cmds.txt"
  run vraw --no-canon "$GV" "$S/ours.uhdm"
  run vcanon "" "$GV" "$S/ours.uhdm"
  run ggraw --no-canon "$G" "$GV"
  run ggcanon "" "$G" "$GV"
  for t in vraw vcanon ggraw ggcanon; do
    printf '   %-8s %s\n' $t "$(grep -E '^STRICT_|^NOT_EQUAL|^canon overflow' "$E/$t.txt" | tail -1) [$(tail -1 "$E/$t.txt" | cut -d' ' -f1-3)] first: $(grep -m1 -A2 '^#' "$E/$t.txt" | tr '\n\t' '  ' | cut -c1-150)"
  done
fi
# self pairs: stage 1 is equal by construction, so stage 2 (both walks) always runs;
# gives each producer's raw and canonical record count and proves termination
: > "$E/self.txt"
for side in gold ours; do
  db=$G; [ $side = ours ] && db=$S/ours.uhdm
  for t in raw canon; do x=; [ $t = raw ] && x=--no-canon
    t0=$(date +%s.%N)
    timeout 600 "$SC" --max 0 $x "$db" "$db" > "$S/self.out" 2>&1; rc=$?
    echo "$side $t: $(tail -1 "$S/self.out") rc=$rc wall=$(awk -v a=$t0 -v b=$(date +%s.%N) 'BEGIN{printf "%.2f", b-a}')" >> "$E/self.txt"
  done
done
printf '%-28s raw: %-40s canon: %s\n' "$N" "$(grep -E '^STRICT_|^NOT_EQUAL|^canon overflow' "$E/raw.txt" | tail -1) [$(tail -1 "$E/raw.txt" | cut -d' ' -f1-3)]" "$(grep -E '^STRICT_|^NOT_EQUAL|^canon overflow' "$E/canon.txt" | tail -1) [$(tail -1 "$E/canon.txt" | cut -d' ' -f1-3)]"

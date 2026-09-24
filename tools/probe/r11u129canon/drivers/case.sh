#!/bin/bash
# case.sh <case dir> : build the case's golden with the pinned Surelog (check_probe.py SL_ARGS) and ours
# with the frozen 9c839593 binary, then uhdm-cmp and uhdm-strictcmp (SC, the r11u129 build) in modes
# MODES (default 2 3 4; 4 is the default reading), plus any extra comparator in
# SC_EXTRA="tag:path[,arg,...] ..." (e.g. the committed 9c839593 binary), with record dumps. If <case>/v/dut.sv exists (a content variant),
# its golden (gv) and ours (ov) are built too and the pairs g-gv, g-ov, o-ov are compared as well.
# Every golden is built fresh (no cache). Scratch /tmp/r11u129_case/<name>/, evidence <repro>/evidence/<name>/.
set -u
A=$(realpath "$1"); N=$(basename "$A")
R=$(realpath "$(dirname "$0")/..")
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
UHDM_CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SLANG_UHDM=${SLANG_UHDM:-/tmp/r11u129_bin/slang-uhdm}
SC=${SC:-/tmp/r11u129_bin/sc_m4g}
S=/tmp/r11u129_case/$N; E=$R/evidence/cases/$N
rm -rf "$S"; mkdir -p "$S" "$E"
build() { # dir tag
  mkdir -p "$S/$2.gold"
  (cd "$1" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$S/$2.gold" > "$S/$2.surelog.log" 2>&1)
  cp "$(find "$S/$2.gold" -name '*.uhdm' | head -1)" "$S/g$2.uhdm"
  rm -f "$S/o$2.uhdm"
  (cd "$1" && "$SLANG_UHDM" dut.sv --single-unit --nobuiltin -o "$S/o$2.uhdm" > "$S/$2.slang.log" 2>&1)
  echo "$2: surelog $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 (in $1); slang $SLANG_UHDM dut.sv --single-unit --nobuiltin rc=$?" >> "$E/cmds.txt"
}
: > "$E/cmds.txt"; echo "strictcmp: $SC $(md5sum < $SC | cut -c1-12)" >> "$E/cmds.txt"
build "$A" ""
[ -f "$A/v/dut.sv" ] && build "$A/v" v
pair() { # tag a b
  local t=$1 a=$2 b=$3
  "$UHDM_CMP" "$a" "$b" > "$E/$t.cmp.txt" 2>&1; local crc=$?
  local line="$t: uhdm-cmp rc=$crc"
  for m in ${MODES:-2 3 4}; do
    "$SC" --max 6 --canon-fullname $m --dump-a "$S/$t.m$m.A" --dump-b "$S/$t.m$m.B" "$a" "$b" > "$E/$t.m$m.txt" 2>&1
    line="$line | m$m rc=$? $(grep -E '^STRICT_|^NOT_EQUAL|^canon overflow' "$E/$t.m$m.txt" | tail -1)"
  done
  for x in ${SC_EXTRA:-}; do
    local tg=${x%%:*} p=${x#*:}
    "${p%%,*}" $(echo "${p#*,}" | tr , " " | sed "s|^/.*||") --max 6 --dump-a "$S/$t.$tg.A" --dump-b "$S/$t.$tg.B" "$a" "$b" > "$E/$t.$tg.txt" 2>&1
    line="$line | $tg rc=$? $(grep -E '^STRICT_|^NOT_EQUAL|^canon overflow' "$E/$t.$tg.txt" | tail -1)"
  done
  echo "$line"
}
{
pair g-o "$S/g.uhdm" "$S/o.uhdm"
if [ -f "$A/v/dut.sv" ]; then
  pair g-gv "$S/g.uhdm" "$S/gv.uhdm"
  pair g-ov "$S/g.uhdm" "$S/ov.uhdm"
  pair o-ov "$S/o.uhdm" "$S/ov.uhdm"
fi
} | tee "$E/verdicts.txt" | sed "s/^/$N /"

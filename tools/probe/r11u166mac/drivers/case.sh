#!/bin/bash
# case.sh <case dir holding dut.sv> <slang-uhdm binary> <tag>
#   golden: the pinned Surelog, `-parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0` (the probe arguments),
#           cached per case under $R166_SCRATCH keyed by the md5 of EVERY file of the case dir (no stale goldens);
#   ours:   `dut.sv --single-unit --nobuiltin`;
#   prints: <case> rc=<ours rc> cmp=<uhdm-cmp lines> <strictcmp verdict>; records in <scratch>/<key>/{g,<tag>}.rec
# Env: SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP R166_SCRATCH (all absolute).  Refuses a dir outside tools/probe/r11u166mac
# or /tmp/r11u166_*: the fenced corpus sources are never an input.
set -u
d=$(realpath "$1"); bin=$2; tag=$3
case "$d" in */tools/probe/r11u166mac/*|/tmp/r11u166_*) ;; *) echo "REFUSE $d"; exit 3;; esac
: "${R166_SCRATCH:?}" "${SURELOG:?}" "${UHDM_CMP:?}" "${STRICT_CMP:?}"
key=$(cd "$d" && find . -type f ! -name LAW -print0 | sort -z | xargs -0 md5sum | md5sum | cut -c1-16)
w=$R166_SCRATCH/$key; mkdir -p "$w"
echo "$d" > "$w/case.txt"
if [ ! -s "$w/golden.uhdm" ]; then
  rm -rf "$w/sl"; mkdir -p "$w/sl"
  (cd "$d" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w/sl" >"$w/sl.log" 2>&1)
  cp "$w/sl/slpp_all/surelog.uhdm" "$w/golden.uhdm" 2>/dev/null
  "$UHDM_DUMP" "$w/golden.uhdm" > "$w/golden.dump" 2>/dev/null
fi
rm -f "$w/$tag.uhdm"
(cd "$d" && "$bin" dut.sv --single-unit --nobuiltin -o "$w/$tag.uhdm" >/dev/null 2>"$w/$tag.err"); rc=$?
"$UHDM_DUMP" "$w/$tag.uhdm" > "$w/$tag.dump" 2>/dev/null
cmpn=$("$UHDM_CMP" "$w/golden.uhdm" "$w/$tag.uhdm" 2>&1 | wc -l)
st=$("$STRICT_CMP" --max 50 --dump-a "$w/g.rec" --dump-b "$w/$tag.rec" "$w/golden.uhdm" "$w/$tag.uhdm" 2>&1 | tail -1)
echo "$(basename "$(dirname "$d")")/$(basename "$d") rc=$rc cmp=$cmpn $st [$w]"

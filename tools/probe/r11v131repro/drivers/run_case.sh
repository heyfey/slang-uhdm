#!/usr/bin/env bash
# run_case.sh <case dir> <binary> <outdir> : golden (probe flags, cached by content md5), ours, cmp lines, strict
set -u
source /tmp/v11u131_drv/env.sh
c=$1; bin=$2; out=$3
GC=/tmp/v11u131_gcache; mkdir -p "$out" "$GC"
h=$(md5sum "$c/dut.sv" | cut -c1-16); g=$GC/$h.uhdm
if [ ! -s "$g" ]; then
  w=$(mktemp -d /tmp/v11u131_sl.XXXXXX)
  (cd "$c" && timeout 300 "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w" >/dev/null 2>&1)
  f=$(find "$w" -name '*.uhdm' | head -1); [ -n "$f" ] && cp "$f" "$g"; rm -rf "$w"
fi
name=$(basename $(dirname "$c"))__$(basename "$c")
o=$out/$name.uhdm; rm -f "$o"
(cd "$c" && timeout 300 "$bin" dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1); rc=$?
if [ ! -s "$g" ]; then echo "$name NOGOLDEN rc=$rc"; exit 0; fi
if [ ! -s "$o" ]; then echo "$name SLANG_FAIL rc=$rc"; exit 0; fi
cmpl=$("$UHDM_CMP" "$g" "$o" 2>&1 | wc -l)
st=$("$STRICT_CMP" --max 0 "$g" "$o" 2>&1 | tail -1)
echo "$name rc=$rc cmp=$cmpl strict=$st"
echo "$g" > "$out/$name.golden"

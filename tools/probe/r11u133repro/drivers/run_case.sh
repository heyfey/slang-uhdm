#!/usr/bin/env bash
# run_case.sh <case dir with dut.sv> <slang-uhdm binary> <out dir>
# Golden: the pinned Surelog with the probe flags, cached by the md5 of
# dut.sv (an edited case never reads a stale golden). Ours: the probe
# command line. Prints: <case> rc=<rc> cmp=<lines> strict=<verdict line>.
# Needs SURELOG, UHDM_CMP, STRICT_CMP exported. GCACHE overrides the cache dir.
set -u
c=$1; bin=$2; out=$3
GC=${GCACHE:-/tmp/r11u133_gcache}
mkdir -p "$out" "$GC"
h=$(md5sum "$c/dut.sv" | cut -c1-16)
g=$GC/$h.uhdm
if [ ! -s "$g" ]; then
  w=$(mktemp -d /tmp/r11u133_sl.XXXXXX)
  (cd "$c" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w" >/dev/null 2>&1)
  f=$(find "$w" -name '*.uhdm' | head -1)
  [ -n "$f" ] && cp "$f" "$g"
  rm -rf "$w"
fi
name=$(echo "$c" | sed "s#.*/r11u133repro/##; s#.*/cases/##; s#/#__#g")
o=$out/$name.uhdm
rm -f "$o"
(cd "$c" && "$bin" dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1); rc=$?
if [ ! -s "$g" ]; then echo "$name NOGOLDEN rc=$rc"; exit 0; fi
if [ ! -s "$o" ]; then echo "$name SLANG_FAIL rc=$rc"; exit 0; fi
cmpl=$("$UHDM_CMP" "$g" "$o" 2>&1 | wc -l)
st=$("$STRICT_CMP" --max 0 "$g" "$o" | tail -1)
echo "$name rc=$rc cmp=$cmpl strict=$st"
echo "$g" > "$out/$name.golden"

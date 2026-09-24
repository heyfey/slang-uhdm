#!/usr/bin/env bash
# run2.sh <case dir> <outroot> : golden (cached by dut.sv md5), ours with PRIS and LAW binaries,
# prints: case rcP rcL cmpP cmpL strictP | strictL | bytes-same
set -u
c=$1; out=$2
GC=/tmp/v11u124_gcache; mkdir -p "$GC" "$out"
h=$( (cat "$c"/*.sv "$c"/*.svh 2>/dev/null) | md5sum | cut -c1-16)
g=$GC/$h.uhdm
if [ ! -s "$g" ]; then
  w=$(mktemp -d /tmp/v11u124_sl.XXXXXX)
  (cd "$c" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w" >/dev/null 2>&1)
  f=$(find "$w" -name '*.uhdm' | head -1)
  [ -n "$f" ] && cp "$f" "$g"
  rm -rf "$w"
fi
name=$(echo "$c" | sed 's#^/tmp/v11u124_cases/##; s#/#__#g')
res="$name"
for tag in P L; do
  if [ $tag = P ]; then bin=$PRIS; else bin=$LAW; fi
  o=$out/$name.$tag.uhdm; rm -f "$o"
  (cd "$c" && env $EXTRA "$bin" dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1); rc=$?
  if [ ! -s "$g" ]; then res="$res NOGOLDEN"; break; fi
  if [ ! -s "$o" ]; then res="$res $tag:rc=$rc:NOOUT"; continue; fi
  cm=$("$UHDM_CMP" "$g" "$o" 2>&1 | wc -l)
  st=$("$STRICT_CMP" --max 0 "$g" "$o" 2>&1 | tail -1)
  res="$res | $tag rc=$rc cmp=$cm $st"
done
if cmp -s "$out/$name.P.uhdm" "$out/$name.L.uhdm"; then res="$res | SAMEBYTES"; else res="$res | MOVED"; fi
echo "$g" > "$out/$name.golden"
echo "$res"

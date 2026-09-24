#!/usr/bin/env bash
# rc.sh <case dir> : golden (cached by content), pristine, law; rc, cmp lines, strict line for both
source /tmp/v11u140_scratch/env.sh
c=$(realpath ${1%/}); GC=/tmp/v11u140_gcache
h=$(md5sum "$c/dut.sv" | cut -c1-16); g=$GC/$h.uhdm
if [ ! -s "$g" ]; then
  w=$(mktemp -d /tmp/v11u140_sl.XXXXXX)
  (cd "$c" && "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$w" >/dev/null 2>&1)
  f=$(find "$w" -name '*.uhdm' | head -1); [ -n "$f" ] && cp "$f" "$g"; rm -rf "$w"
fi
res=""
for b in ${BINS:-pris law}; do
  o=$c/$b.uhdm; rm -f "$o"
  (cd "$c" && env $EXTRA /tmp/v11u140_bin/$b dut.sv --single-unit --nobuiltin -o "$o" >/dev/null 2>&1); rc=$?
  if [ ! -s "$g" ]; then res="$res | $b NOGOLDEN rc=$rc"; continue; fi
  if [ ! -s "$o" ]; then res="$res | $b FAIL rc=$rc"; continue; fi
  cl=$("$UHDM_CMP" "$g" "$o" 2>&1 | wc -l)
  st=$("$STRICT_CMP" --max 0 "$g" "$o" 2>&1 | tail -1 | cut -c1-60)
  res="$res | $b rc=$rc cmp=$cl $st"
done
set -- ${BINS:-pris law}; m=SAME; cmp -s $c/$1.uhdm $c/$2.uhdm || m=MOVED
echo "$(basename $c)$res | $m"

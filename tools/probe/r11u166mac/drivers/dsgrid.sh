#!/bin/bash
# dsgrid.sh <tag=binary> ... — the downstream harness (scripts/downstream_uhdm2rtlil.py `one`, the probe arguments)
# on every case under ../cases: verdict, both lane statuses and which RTLIL outputs differ, per binary.
set -u
here=$(cd "$(dirname "$0")" && pwd); R=$(cd "$here/../../../.." && pwd)
cd "$here/../cases"
find . -name dut.sv | sort | while read -r f; do
  d=$(cd "$(dirname "$f")" && pwd); c=$(echo "${f#./}" | sed 's|/dut.sv||;s|/|_|g'); line="$c"
  for tb in "$@"; do
    tag=${tb%%=*}; bin=${tb#*=}; wr=/tmp/r11u166_dsg_$tag; mkdir -p "$wr"; rm -rf "$wr/$c"
    v=$(cd "$R" && SLANG_UHDM=$bin python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$c', '$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$wr', 300); print(r['verdict'], r['differs'] or '-')" 2>&1 | tail -1)
    line="$line | $tag: $v"
  done
  echo "$line"
done

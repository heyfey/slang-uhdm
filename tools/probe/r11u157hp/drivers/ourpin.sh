#!/bin/bash
# r11u157: pin OUR hier_path element mints. args: <case dir> <out dir> [g1 binary]. Prints objtab with mint sites.
set -u
D=$(cd "$(dirname "$0")" && pwd); c=$1; o=$2; B=${3:-/tmp/r11u157_bin/slang-uhdm.g1}; mkdir -p "$o"; rm -f "$o/g1.uhdm"
( cd "$c" && OM_OUT=$o/om.json timeout 900 gdb -q -batch -ex "set pagination off" -ex "set breakpoint pending on" -ex "source $D/ourmint.py" \
  -ex run --args "$B" dut.sv --single-unit --nobuiltin -o "$o/g1.uhdm" > "$o/ourgdb.log" 2>&1 )
/tmp/r11u157_bin/objtab "$o/g1.uhdm" > "$o/g1.objtab"
python3 - "$o" <<'PY'
import json, sys
o = sys.argv[1]; J = json.load(open(f'{o}/om.json'))
mint = {i: bt for t, i, bt in J['mint']}; full = {}
for t, i, s, bt in J['full']: full.setdefault(i, []).append(f"{s!r}@{bt[0] if bt else '?'}")
for l in open(f'{o}/g1.objtab'):
    x = l.rstrip('\n').split('\t')
    if x[0] == 'P': print(f"P{x[1]} {x[2]} {x[4]} <{x[5]}> mint={' < '.join(mint.get(int(x[1]), ['?'])[:3])}"); continue
    i = int(x[1])
    print(f"   E{i} {x[2]} {x[3]} full={x[4]!r} span={x[6]} | mint={' < '.join(mint.get(i, ['?'])[:2])} | set={';'.join(full.get(i, [])) or '-'}")
PY

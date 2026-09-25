#!/bin/bash
# r11u161 (copy of r11u157hp/drivers/slpin.sh, tools rebased): decode a case's golden hier_path elements at the Surelog source. args: <case dir with dut.sv> <out dir>
# Runs the PINNED Surelog (check_probe's arguments) under gdb twice-in-one (slmint.py + slfull.py): every ref_obj /
# hier_path / bit_select / ... mint with its caller chain, every ref_obj/bit_select VpiFullName setter call; then
# objtab on the database written under gdb. Prints one line per hier_path element:
#   <path id> <path name> <path span> | <elem id> <type> <name> fullname=<vpi> span=<span> | mint=<chain> | set=<setter calls>
set -u
D=/tmp/wt_r11u161/tools/probe/r11u157hp/drivers; c=$1; o=$2; mkdir -p "$o"; rm -rf "$o/db"
( cd "$c" && SLMINT_TYPES=ref_obj,hier_path,bit_select,var_select,part_select,indexed_part_select,method_func_call SLMINT_OUT=$o/mint.json \
  SLFULL_TYPES=ref_obj,bit_select SLFULL_OUT=$o/full.json timeout 900 gdb -q -batch -ex "set pagination off" -ex "set breakpoint pending on" \
  -ex "source $D/slmint.py" -ex "source $D/slfull.py" -ex run --args "$SURELOG" -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o "$o/db" > "$o/gdb.log" 2>&1 )
db=$(find "$o/db" -name '*.uhdm' | head -1)
[ -n "$db" ] || { echo "NODB $c"; exit 1; }
/tmp/r11u161_bin/objtab "$db" > "$o/objtab.txt"
python3 - "$o" <<'PY'
import json, sys
o = sys.argv[1]
mint = {}; full = {}
for t, i, bt in json.load(open(f'{o}/mint.json')):
    mint[i] = ' < '.join(n.split('(')[0].split('::')[-1] for n in bt[1:5])
for t, i, s, bt in json.load(open(f'{o}/full.json')):
    full.setdefault(i, []).append(f"{s!r}@{bt[0] if bt[0] != 'VpiFullName' else 'SAVE'}")
cur = None
for l in open(f'{o}/objtab.txt'):
    x = l.rstrip('\n').split('\t')
    if x[0] == 'P': cur = f"P{x[1]} {x[2]} {x[4]} <{x[5]}> mint={mint.get(int(x[1]), '?')}"; print(cur); continue
    i = int(x[1])
    print(f"   E{i} {x[2]} {x[3]} full={x[4]!r} span={x[6]} {x[7]} | mint={mint.get(i, 'CLONE/other')} | set={';'.join(full.get(i, [])) or '-'}")
PY

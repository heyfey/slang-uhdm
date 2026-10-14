#!/bin/bash
# r11u314 mkcase.sh <case dir> <law> <template: cls|raw> <body line(s)>: writes <case dir>/dut.sv, its first line
# '// § <law>'.  cls: the pass-310 class template (tools/probe/v11u310repro/cases/VT/vt36_concat lines 2-12 and
# 14-17) with the body as the method probe()'s statements; raw: the body is the whole file after the law line.
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
d=$1; law=$2; t=$3; shift 3; mkdir -p "$d"; f="$d/dut.sv"
T=$R/tools/probe/v11u310repro/cases/VT/vt36_concat/dut.sv
{ echo "// § $law"
  if [ "$t" = cls ]; then sed -n 2,12p "$T"; printf '%s\n' "$@"; sed -n 14,17p "$T"; else printf '%s\n' "$@"; fi; } > "$f"

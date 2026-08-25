#!/bin/bash
# v132 A-PRIORI PREDICTOR v3 (verifier's own, run on PRISTINE databases ONLY,
# BEFORE any patched-vs-pristine comparison).
#
# A database is PREDICTED TO MOVE iff its pristine dump holds a hier_path /
# ref_obj / method_func_call whose FIRST NAME COMPONENT is not a legal
# SystemVerilog name.  Legal here means an identifier, optionally escaped,
# optionally carrying the dump's SYNTHESISED scope punctuation (`::`, `@`) —
# v1 and v2 over-fired because index-bracket decompiles carry spaces and
# operators (`q[i + 1]`) and fullnames carry `work@top` / `pkg::cls::f`.
f=$1
o=/tmp/v132_scratch/names/$(echo "$f" | tr / _).txt
~/.local/bin/uhdm-dump "$f" 2>/dev/null \
  | grep -aoE '^\s*\\_(hier_path|ref_obj|method_func_call): \([^).[]*' \
  | sed 's/^.*: (//' | sort -u > "$o"
n=$(grep -acvE '^[A-Za-z_$\\@][A-Za-z0-9_$@:]*$|^$' "$o"; true)
echo "$n $f"

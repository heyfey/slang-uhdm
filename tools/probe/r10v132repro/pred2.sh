#!/bin/bash
# v132 A-PRIORI PREDICTOR v2: flag a pristine database iff some hier_path /
# ref_obj / method_func_call NAME has a FIRST COMPONENT that is not a legal
# SystemVerilog identifier — the misread receiver's signature.  Legal names may
# carry spaces and operators INSIDE index brackets, which is why v1 over-fired.
f=$1
n=$(~/.local/bin/uhdm-dump "$f" 2>/dev/null \
    | grep -aoE '^\s*\\_(hier_path|ref_obj|method_func_call): \([^).[]*' \
    | sed 's/^.*: (//' \
    | grep -acvE '^[A-Za-z_$\\][A-Za-z0-9_$]*$|^$')
echo "$n $f"

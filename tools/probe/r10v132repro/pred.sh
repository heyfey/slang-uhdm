#!/bin/bash
# v132 A-PRIORI PREDICTOR (verifier's own): a pristine database is predicted to
# MOVE iff its dump contains a hier_path / ref_obj / method_func_call whose NAME
# is not a legal SV dotted name (contains a quote, a parenthesis, a backslash,
# whitespace or a newline) — the misread receiver's signature.
f=$1
n=$(~/.local/bin/uhdm-dump "$f" 2>/dev/null | grep -aoE '^\s*\\_(hier_path|ref_obj|method_func_call): \([^)]*' | grep -acE ': \([^)]*["\\ ]|: \($' )
echo "$n $f"

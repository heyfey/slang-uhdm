#!/usr/bin/env bash
# r11u53 SITE LISTER — print the `line:col` of every `$bits` in an arm's
# dut.sv, in source order, one per line, with the source text beside it.
# The producer anchors a `sys_func_call`/folded `constant` at the `$` column,
# so these are exactly the sites `cell53.sh` keys on.  Deriving the sites from
# the SOURCE (not from either dump) is what stops a site that is missing on
# BOTH sides from reading as agreement.
set -u
D=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/grid/${1:?arm}
awk '/^[ \t]*\/\//{next}
     { s=$0; off=0
       while (match(s, /\$bits/)) { c = off + RSTART; off = c + 4
                                    printf "%d:%d\t%s\n", NR, c, $0
                                    s = substr(s, RSTART+5) } }' "$D/dut.sv"

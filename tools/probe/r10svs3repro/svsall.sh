#!/bin/bash
# r10svs3repro/svsall.sh — ALL FOUR ARMS, one binary, one table.
#
#   usage: svsall.sh <outdir-prefix> <slang-binary>
#
# Prints, per arm, the driver's own guard lines and then ONE ROW PER CELL:
#     <arm> <method>  golden=<n> ours=<n>  <TOTALS line>
# and finally the four counters summed over all 45 cells:
#     EQ          both sides Compare equal
#     DIFFER      same class, a FIELD inside disagrees
#     DIFFERKIND  the two sides emit an element of a DIFFERENT CLASS
#     ONLY        the statement LISTS are different lengths (this pass's cell)
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# GUARD: the arm list and its (class, method) cells are written out here, so a
# method that stops appearing in a database is reported by svsstmts as
# `METHOD NOT FOUND` rather than dropping silently out of the totals.
set -u
PFX=${1:?outdir prefix}
BIN=${2:?slang binary}
HERE=$(cd "$(dirname "$0")" && pwd)
CENSUS=/tmp/r10svs3_svsstmts
[ -x "$CENSUS" ] || { echo "FATAL: build it first: svsbuild.sh svsstmts"; exit 3; }

run_arm() {  # <armfile> <class> <methods...>
    local f=$1 cls=$2; shift 2
    local out=$PFX-${f%%_*}
    echo "######## ARM $f"
    bash "$HERE/svsarm.sh" "$HERE/$f.sv" "$out" "$BIN" 2>&1 |
        grep -E "^surelog rc|^slang rc|dump content|cmp rc"
    local G=$out/slpp_all/surelog.uhdm O=$out/ours.uhdm
    for m in "$@"; do
        printf '%-14s %-5s ' "$f" "$m"
        "$CENSUS" "$G" "$O" "work@$cls" "$m" 2>&1 |
            grep -E "^STMTS|^TOTALS|NOT FOUND" | tr '\n' ' '
        echo
    done
}

run_arm a1_newlhs   holder  m1 m2 m3 m4 m5 m6 m7 m8 m9 m10
run_arm a2_thisnew  holder2 n1 n2 n3 n4 n5 n6 n7 n8 new n10 n11 n12 n13
run_arm a3_position solo    p1 new p3 p4 p5 p6 p7 p8 p9 p10 p11 p12
run_arm a4_ctorspan spans   new q2 q3 q4 q5 q6 q7 q8 q9 q10

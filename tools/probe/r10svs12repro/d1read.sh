#!/usr/bin/env bash
# r10svs12 — read every cell of all three arms from an ALREADY-RUN workdir pair.
#
#   usage: TAG=<pris|ship> ./d1read.sh
#
# Containers are keyed by their SOURCE SPAN, not by name: a module_array's dump
# header carries only `(work@<def>)`, so two arrays of the same interface would
# collide on a name key and portread.py takes the FIRST match.  The span is in
# the header text (`module_array: (work@if1), line:39:5,`) and is unique per
# instantiation, so it is used as the --obj prefix throughout.
#
# The ABSENCE of a container is a cell too (arm d1 h3 / d2 m3+m5): portread.py
# prints `OBJECT NOT FOUND on <side>` for it, which is the measurement, not an
# error — so this driver does not stop on a non-zero return.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
TAG=${TAG:?set TAG to pris or ship}
r() { # r <arm> <cell> <objpat>
    local A=$1 C=$2 O=$3
    local D=/tmp/r10svs12_arm_${TAG}_$A
    [ -s "$D/g.dump" ] || { echo "$C: NO WORKDIR $D"; return; }
    echo "-- cell $C"
    python3 "$HERE/portread.py" "$D/g.dump" "$D/o.dump" --obj "$O" || true
}

echo "===== d1_ifacearrayport (TAG=$TAG)"
r d1_ifacearrayport h1  'module_array: (work@if1), line:39:5,'
r d1_ifacearrayport h2  'module_array: (work@if1), line:41:5,'
r d1_ifacearrayport h3  'module_array: (work@if2), line:43:5,'
r d1_ifacearrayport h4  'module_array: (work@if2), line:45:5,'
r d1_ifacearrayport h5  'module_array: (work@if2), line:47:5,'
r d1_ifacearrayport h6  'module_array: (work@if1), line:49:5,'
r d1_ifacearrayport h7  'module_array: (work@if1), line:51:5,'
r d1_ifacearrayport h8  'ref_module: work@if1 (s1),'
r d1_ifacearrayport h9  'ref_module: work@if1 (s2),'
r d1_ifacearrayport h10 'module_array: (work@if1), line:58:5,'

echo "===== d2_modarrayport (TAG=$TAG)"
r d2_modarrayport m1 'module_array: (work@leaf1), line:25:7,'
r d2_modarrayport m2 'module_array: (work@leaf1), line:27:7,'
r d2_modarrayport m3 'module_array: (work@leaf2), line:29:7,'
r d2_modarrayport m4 'module_array: (work@leaf2), line:31:7,'
r d2_modarrayport m5 'module_array: (work@leaf3), line:33:12,'
r d2_modarrayport m6 'module_array: (work@leaf2), line:35:7,'
r d2_modarrayport m7 'ref_module: work@leaf1 (c1),'
r d2_modarrayport m8 'ref_module: work@leaf1 (c2),'
r d2_modarrayport m9  'module_array: (work@leaf1), line:44:7,'
r d2_modarrayport m10 'module_array: (work@leaf1), line:47:7,'

echo "===== d3_hcshape (TAG=$TAG)"
r d3_hcshape k1 'module_array: (work@if1), line:32:5,'
r d3_hcshape k2 'module_array: (work@if1), line:34:5,'
r d3_hcshape k3 'module_array: (work@if1), line:36:5,'
r d3_hcshape k4 'module_array: (work@if1), line:38:5,'
r d3_hcshape k5 'module_array: (work@if1), line:40:5,'
r d3_hcshape k6 'module_array: (work@if1), line:42:5,'
r d3_hcshape k7 'module_array: (work@if1), line:44:5,'

# d4 — the ESCAPED-IDENTIFIER arm.  e1 (two positional terminals, no `#()`) is
# UDP-form, so golden builds NO def-view module_array for it: `OBJECT NOT FOUND
# on LHS golden side` IS that cell's measurement, exactly as for d1 h3 / d2 m3.
echo "===== d4_escaped (TAG=$TAG)"
r d4_escaped e1 'module_array: (work@ifE), line:27:5,'
r d4_escaped e2 'module_array: (work@ifE), line:29:5,'
r d4_escaped e3 'module_array: (work@ifE), line:31:5,'
r d4_escaped e4 'module_array: (work@ifE), line:33:5,'

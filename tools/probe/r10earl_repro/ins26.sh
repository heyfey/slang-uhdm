#!/bin/bash
# ins19.sh <tag> -- instance-topness census (r10earl18a) of both databases into
# /tmp/r10earl26_ins_<tag>_{g,o}.txt, plus the A-vs-B diff.
G=${EARL_GOLD:-/home/heyfey/.cache/slang-uhdm-goldens/00d4794526e44dc553f3/golden.uhdm}
O=${EARL_OURS:-/tmp/r10earl26_e0w/default/Earlgrey_0_1-71da2fd7/slang.uhdm}
T=${1:-base}
/tmp/r10e26_18a "$G" > "/tmp/r10earl26_ins_${T}_g.txt" 2>&1
/tmp/r10e26_18a "$O" > "/tmp/r10earl26_ins_${T}_o.txt" 2>&1
nrm() { sed -E -e 's/^A x[0-9]+  //' -e "s/' [^ ]*:([0-9]+:[0-9]+)/' :\1/" "$1" \
        | sort -u; }
nrm "/tmp/r10earl26_ins_${T}_g.txt" > "/tmp/r10earl26_ins_${T}_gs.txt"
nrm "/tmp/r10earl26_ins_${T}_o.txt" > "/tmp/r10earl26_ins_${T}_os.txt"
echo "--- SET diff (an object shape one side has and the other lacks)"
diff "/tmp/r10earl26_ins_${T}_gs.txt" "/tmp/r10earl26_ins_${T}_os.txt"
echo "(set diff rc=$?)"
# THE METRIC: the COUNTS.
cnt() { sed -E -e "s/^A (x[0-9]+)  (.*)' [^ ]*:([0-9]+:[0-9]+)/\2' :\3\t\1/" \
        -e 's/^A (x[0-9]+)  (.*)/\2\t\1/' "$1" | sort; }
cnt "/tmp/r10earl26_ins_${T}_g.txt" > "/tmp/r10earl26_ins_${T}_gc.txt"
cnt "/tmp/r10earl26_ins_${T}_o.txt" > "/tmp/r10earl26_ins_${T}_oc.txt"
echo "--- COUNT diff"
diff "/tmp/r10earl26_ins_${T}_gc.txt" "/tmp/r10earl26_ins_${T}_oc.txt"
echo "(count diff rc=$?)"

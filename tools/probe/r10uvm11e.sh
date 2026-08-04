#!/bin/bash
# r10uvm11e.sh <test> [mode] — hier_path element census counts + golden-only
# element keys, for one UVM-4 pair out of the r10uvm11 sweep workdir.
set -u
T=$1; M=${2:-default}
D=$(ls -d /tmp/r10uvm11_slw/$M/$T-* | head -1)
G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' $D/cmds.txt | head -1)/golden.uhdm
/tmp/r10uvm11_e "$G" > /tmp/r10uvm11_eg.txt 2>/dev/null
/tmp/r10uvm11_e "$D/slang.uhdm" > /tmp/r10uvm11_es.txt 2>/dev/null
echo "elements golden=$(wc -l < /tmp/r10uvm11_eg.txt) ours=$(wc -l < /tmp/r10uvm11_es.txt)"
cut -d'|' -f1,2,5,6 /tmp/r10uvm11_eg.txt | sort -u > /tmp/r10uvm11_ekg.txt
cut -d'|' -f1,2,5,6 /tmp/r10uvm11_es.txt | sort -u > /tmp/r10uvm11_eks.txt
echo "unique keys golden=$(wc -l < /tmp/r10uvm11_ekg.txt) ours=$(wc -l < /tmp/r10uvm11_eks.txt)"
echo "golden-only keys=$(comm -23 /tmp/r10uvm11_ekg.txt /tmp/r10uvm11_eks.txt | wc -l)"
echo "ours-only  keys=$(comm -13 /tmp/r10uvm11_ekg.txt /tmp/r10uvm11_eks.txt | wc -l)"

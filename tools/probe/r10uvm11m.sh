#!/bin/bash
# r10uvm11m.sh — split the hier_path-ending-in-method_func_call population
# (the R5 shape) into golden-only / ours-only keys.  Run after r10uvm11e.sh.
set -u
F='{split($1,a,"/"); i=substr(a[1],2)+0; n=a[2]+0; if ($2=="method_func_call" && i==n-1) print $5"|"$6}'
awk -F'|' "$F" /tmp/r10uvm11_eg.txt | sort > /tmp/r10uvm11_mg.txt
awk -F'|' "$F" /tmp/r10uvm11_es.txt | sort > /tmp/r10uvm11_ms.txt
echo "mfc-tail golden=$(wc -l < /tmp/r10uvm11_mg.txt) ours=$(wc -l < /tmp/r10uvm11_ms.txt)"
sort -u /tmp/r10uvm11_mg.txt > /tmp/r10uvm11_mgu.txt
sort -u /tmp/r10uvm11_ms.txt > /tmp/r10uvm11_msu.txt
echo "--- ours-only keys ($(comm -13 /tmp/r10uvm11_mgu.txt /tmp/r10uvm11_msu.txt | wc -l)) ---"
comm -13 /tmp/r10uvm11_mgu.txt /tmp/r10uvm11_msu.txt | head -${1:-25}
echo "--- golden-only keys ($(comm -23 /tmp/r10uvm11_mgu.txt /tmp/r10uvm11_msu.txt | wc -l)) ---"
comm -23 /tmp/r10uvm11_mgu.txt /tmp/r10uvm11_msu.txt | head -${1:-25}

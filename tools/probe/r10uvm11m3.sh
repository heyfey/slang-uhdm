#!/bin/bash
# r10uvm11m3.sh — the >=3-element hier_path population (the deepRecvCall11
# shape), golden-only vs ours-only, keyed on name+owner+line.
set -u
F='{split($1,a,"/"); n=a[2]+0; if (n>=3) print $5"|"$6"|"$7}'
awk -F'|' "$F" /tmp/r10uvm11_eg.txt | sort -u > /tmp/r10uvm11_m3g.txt
awk -F'|' "$F" /tmp/r10uvm11_es.txt | sort -u > /tmp/r10uvm11_m3s.txt
echo "keys golden=$(wc -l < /tmp/r10uvm11_m3g.txt) ours=$(wc -l < /tmp/r10uvm11_m3s.txt)"
echo "--- ours-only ($(comm -13 /tmp/r10uvm11_m3g.txt /tmp/r10uvm11_m3s.txt|wc -l)) ---"
comm -13 /tmp/r10uvm11_m3g.txt /tmp/r10uvm11_m3s.txt | head -${1:-25}
echo "--- golden-only ($(comm -23 /tmp/r10uvm11_m3g.txt /tmp/r10uvm11_m3s.txt|wc -l)) ---"
comm -23 /tmp/r10uvm11_m3g.txt /tmp/r10uvm11_m3s.txt | head -${1:-25}

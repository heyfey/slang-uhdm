#!/bin/bash
# r10uvm9dmp: dump all four views of a repro tag to /tmp/r10uvm9_<tag>_<v>.txt
T=$1
for v in gd sd ge se; do
  /home/heyfey/.local/bin/uhdm-dump /tmp/r10uvm9_${T}_$v.uhdm 2>/dev/null \
    | tail -n +2 > /tmp/r10uvm9_${T}_$v.txt
done
wc -l /tmp/r10uvm9_${T}_gd.txt /tmp/r10uvm9_${T}_sd.txt /tmp/r10uvm9_${T}_ge.txt /tmp/r10uvm9_${T}_se.txt

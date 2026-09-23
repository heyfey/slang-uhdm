#!/bin/bash
# whole-dump distance: golden vs ours, ids and workdir stripped, order-blind (sorted) line diff count
G=${1:?golden}; O=${2:?ours}
D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
norm(){ $D "$1" 2>/dev/null | tail -n +2 | sed -E 's/, id:[0-9]+//; s#/tmp/[^ ,]*/##g' | sort; }
diff <(norm "$G") <(norm "$O") | grep -c '^[<>]'; true

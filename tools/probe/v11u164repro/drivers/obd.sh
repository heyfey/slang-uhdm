#!/bin/bash
# order-blind distance of <tag>.uhdm to golden in a case scratch dir
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
w=$1; t=$2
norm(){ $D $1 2>/dev/null | tail -n +2 | sed -E 's/, id:[0-9]+//; s#file:[^,]*/##' | sort; }
[ -s $w/gold.sorted ] || norm $w/gold/golden.uhdm > $w/gold.sorted
norm $w/$t.uhdm > $w/$t.sorted
diff $w/gold.sorted $w/$t.sorted | grep -c '^[<>]'

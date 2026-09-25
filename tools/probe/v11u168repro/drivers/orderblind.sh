#!/bin/bash
# obd.sh <casegoldendir>: order-blind uhdm-dump distance (lines of ours not in golden) for pris and law
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
c=$1
norm(){ $D $1 2>/dev/null | sed -E 's#/[^ ]*/##g; s/id:[0-9]+//g' | sort; }
norm $c/gold/golden.uhdm > $c/g.sd; norm $c/pris.uhdm > $c/p.sd; norm $c/law.uhdm > $c/l.sd
echo "$c pris=$(comm -13 $c/g.sd $c/p.sd | wc -l) law=$(comm -13 $c/g.sd $c/l.sd | wc -l) pris-vs-law=$(comm -3 $c/p.sd $c/l.sd | wc -l)"

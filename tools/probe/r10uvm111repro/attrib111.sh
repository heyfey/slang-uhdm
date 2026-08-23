#!/bin/bash
# r10uvm111 attrib111.sh — ORDER-BLIND attribution of one mover.
# uhdm-dump both databases, normalise the workdir path away, SORT, diff.
# 0 lines => the move was the Scoreboard/default COIN; otherwise the lines
# printed are the law's.
set -u
P=${1:?patched db}; Q=${2:?pristine db}; T=${3:?tag}
D=/tmp/r10uvm111_scratch/attr_$T; rm -rf $D; mkdir -p $D
uhdm-dump "$P" 2>/dev/null | sed 's#/tmp/r10uvm111_[a-z]*/[a-z0-9]*/#<WD>/#g; s#/tmp/r10uvm111_[a-z]*/#<WD>/#g; 1s#^[^:]*\.uhdm:#<DB>:#' > $D/pat.txt
uhdm-dump "$Q" 2>/dev/null | sed 's#/tmp/r10uvm111_[a-z]*/[a-z0-9]*/#<WD>/#g; s#/tmp/r10uvm111_[a-z]*/#<WD>/#g; 1s#^[^:]*\.uhdm:#<DB>:#' > $D/pris.txt
sort $D/pat.txt > $D/pat.s; sort $D/pris.txt > $D/pris.s
diff $D/pris.s $D/pat.s > $D/ob.diff
echo "$T order-blind changed lines: $(grep -c '^[<>]' $D/ob.diff; true)"
grep '^[<>]' $D/ob.diff | sort | uniq -c | sort -rn | head -20

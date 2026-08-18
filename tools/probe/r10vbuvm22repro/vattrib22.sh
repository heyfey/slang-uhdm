#!/usr/bin/env bash
# r10vbuvm22repro/vattrib22.sh — ORDER-BLIND, path-normalised attribution of one
# mover database: sort both dumps, strip ids and the workdir path, and print the
# surviving diff.  Scoreboard/default is a ~50/50 COIN (RESUME §9), so only an
# order-blind read may be attributed.
#   vattrib22.sh <pristine wd> <patched wd> <rel path>
set -u
P=$1; Q=$2; R=$3
norm() { uhdm-dump "$1" 2>&1 | sed -e 's#, id:[0-9]*##g' -e 's#/tmp/[a-zA-Z0-9_]*/#<WD>/#g' \
         -e 's#^[^:]*\.uhdm:#<DB>:#' | sed 's/^ *//' | LC_ALL=C sort; }
norm "$P/$R" > /tmp/vbuvm22_att_p.txt
norm "$Q/$R" > /tmp/vbuvm22_att_q.txt
echo "== $R"
diff /tmp/vbuvm22_att_p.txt /tmp/vbuvm22_att_q.txt > /tmp/vbuvm22_att_d.txt
echo "changed lines: $(grep -c '^[<>]' /tmp/vbuvm22_att_d.txt; true)"
grep '^[<>]' /tmp/vbuvm22_att_d.txt | sort | uniq -c | sort -rn

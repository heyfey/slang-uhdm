#!/bin/bash
# hdiff13.sh <censusA> <censusB> -- the head-line diff that separates CLOSED
# heads from ADVANCED ones in one line each.
A=$1; B=$2
grep -E "^  HEAD |failLhs|failRhs" "$A" > /tmp/r10earl14_ha.txt
grep -E "^  HEAD |failLhs|failRhs" "$B" > /tmp/r10earl14_hb.txt
diff /tmp/r10earl14_ha.txt /tmp/r10earl14_hb.txt

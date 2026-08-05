#!/bin/bash
# usage: dd6.sh <basename>  -> the raw dump diff of a witness (header dropped)
D=/tmp/r10earl6_rep/out_$1
diff <(tail -n +2 "$D/g.dump") <(tail -n +2 "$D/o.dump")

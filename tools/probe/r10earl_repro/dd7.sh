#!/bin/bash
# usage: dd7.sh <basename>  -> the raw dump diff of a witness (header dropped)
D=/tmp/r10earl7_rep/out_$1
diff <(tail -n +2 "$D/g.dump") <(tail -n +2 "$D/o.dump")

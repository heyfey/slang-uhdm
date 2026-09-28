#!/bin/bash
# r11u198: order-blind dump distance of a judged case: obdist.sh <judge outdir> -> number of lines in the diff of the
# sorted golden dump and the sorted ours dump (paths normalised; vpiFile/id tokens stripped)
o=$1
norm() { sed -E 's#/[^ ,]*/##g; s/id:[0-9]+//g' "$1" | sort; }
diff <(norm $o/g.dump) <(norm $o/o.dump) | grep -c '^[<>]'

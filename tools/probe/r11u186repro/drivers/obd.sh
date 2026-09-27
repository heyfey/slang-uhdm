#!/bin/bash
# r11u186: order-blind dump distance of one case output dir against its golden: the uhdm-dump lines of both
# databases with object ids and directory prefixes removed, sorted, and the symmetric difference counted.
# usage: obd.sh <case output dir (holds g.dump, o.dump)>
norm() { sed -E 's/, id:[0-9]+//; s/id:[0-9]+//; s#file:[^,]*/##; s#/[^ ,]*/##g' "$1" | sort; }
diff <(norm $1/g.dump) <(norm $1/o.dump) | grep -c '^[<>]'

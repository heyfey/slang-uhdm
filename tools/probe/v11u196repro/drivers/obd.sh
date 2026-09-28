#!/bin/bash
# order-blind dump distance to golden: obd.sh <run dir>  (prints pris/law distance)
for b in pris law ${EXTRA:-}; do
  [ -f $1/$b/o.dump ] || continue
  n=$(diff <(sed 's/^ *//' $1/$b/g.dump | sort) <(sed 's/^ *//' $1/$b/o.dump | sort) | grep -c '^[<>]')
  printf "%s=%s " $b $n
done; echo

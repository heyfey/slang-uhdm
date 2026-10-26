#!/bin/bash
# dist.sh <key> <tag>: unsorted diff line count vs golden + sorted
/tmp/v11u433_scr/drv/dd.sh $1 $2 > /dev/null
o=/tmp/v11u433_scr/out/$1/$2
u=$(diff $o/g.txt $o/o.txt | grep -c '^[<>]'); s=$(diff <(sed 1d $o/g.txt|sort) <(sed 1d $o/o.txt|sort) | grep -c '^[<>]')
echo "$u $s"

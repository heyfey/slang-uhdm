#!/bin/bash
# pair.sh <casedir> <outtag>: print "<golden.uhdm> <ours.uhdm>" for a case run by run1.sh
c=$(cd $1 && pwd); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
echo /tmp/v11u422_scr/gold/$h/slpp_all/surelog.uhdm /tmp/v11u422_scr/out/$key/$2/ours.uhdm

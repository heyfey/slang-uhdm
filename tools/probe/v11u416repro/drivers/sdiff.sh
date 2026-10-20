#!/bin/bash
# sdiff.sh <casedir> <outtag>: the strict records that differ (golden A, ours B)
c=$(cd $1 && pwd); t=$2
SC=${STRICTCMP:-/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp}
h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed 's|.*/cases/||; s|/|_|g')
$SC --max ${MAX:-6} /tmp/v11u416_scr/gold/$h/slpp_all/surelog.uhdm /tmp/v11u416_scr/out/$key/$t/ours.uhdm 2>&1 | tail -${LINES_:-30}

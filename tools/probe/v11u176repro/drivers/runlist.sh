#!/bin/bash
# runlist.sh <list of abs dirs> <tag> <bin> <out>
xargs -a $1 -P 3 -I{} /tmp/v11u176_case.sh {} $2 $3 | sort > $4

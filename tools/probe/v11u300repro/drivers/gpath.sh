#!/bin/bash
# v11u300 gpath.sh <case dir> <d|e>: the cached golden database path of a case-view (case.sh's key).
d=$(realpath "$1"); h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$2
echo ${V300_GOLD:-/tmp/v11u300_gold}/$h/g.uhdm

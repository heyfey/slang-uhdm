#!/bin/bash
# cx.sh <case dir> [bin] [max]: differing records with ancestors for one case
source /tmp/r11u140_scratch/env.sh
D=$(dirname $(realpath $0))
c=${1%/}; b=${2:-/tmp/r11u140_bin/pristine}
$D/run_case.sh $c $b /tmp/r11u140_x/out_cx >/dev/null
name=$(echo "$c" | sed "s#.*/r11u140repro/##; s#.*/cases/##; s#/#__#g")
/tmp/r11u140_scratch/ctx.sh $(cat /tmp/r11u140_x/out_cx/$name.golden) /tmp/r11u140_x/out_cx/$name.uhdm ${3:-6} 0 | cut -c1-${W:-330}

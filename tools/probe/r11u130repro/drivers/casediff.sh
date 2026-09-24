#!/bin/bash
# casediff.sh <case dir> <tag> [max]  -> the differing records of a case scored by case.sh
source /tmp/r11u130_env.sh
d=$(realpath "$1"); w=/tmp/r11u130_cases/$(echo "$d" | md5sum | cut -c1-12)
$STRICT_CMP --max ${3:-30} $w/golden.uhdm $w/$2.uhdm 2>&1

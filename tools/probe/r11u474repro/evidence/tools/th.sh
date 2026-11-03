#!/bin/bash
# th.sh <tag> <cls> <casedir>...: this_t of class <cls> in golden and ours (<tag>.uhdm) under /tmp/r11u474_runs
source /tmp/wt_r11u474/tools/probe/r11u474repro/drivers/env.sh || exit 1
export LD_LIBRARY_PATH=~/.local/lib64:~/.local/lib
T=$1; C=$2; shift 2
for c in "$@"; do c=$(realpath $c); W=/tmp/r11u474_runs$c
 echo "${c#*/cases/} G $(/tmp/r11u474_tools/thist $W/sl/slpp_all/surelog.uhdm $C this_t | head -1 | grep -o '@[0-9:]* \|inst=[^ ]*' | tr '\n' ' ') O $(/tmp/r11u474_tools/thist $W/$T.uhdm $C this_t | head -1 | grep -o '@[0-9:]* \|inst=[^ ]*' | tr '\n' ' ')"
done

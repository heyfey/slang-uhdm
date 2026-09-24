#!/bin/bash
# allsw_all.sh <out prefix>: the single-switch battery over every fresh case, both modes, 3 workers
cd $(dirname $0)/..
source drivers/env.sh
ls -d cases/*/* | xargs -P 3 -n 1 python3 drivers/allsw.py > $1_default.txt 2>&1
ls -d cases/*/* | xargs -P 3 -n 1 python3 drivers/allsw.py --elab > $1_elab.txt 2>&1

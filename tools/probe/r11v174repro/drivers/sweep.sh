#!/bin/bash
# sweep <P|L> <corpora>
source $(dirname $0)/env.sh
t=$1; shift
case $t in P) export SLANG_UHDM=/tmp/v11u174_bin/pris; wt=/tmp/wt_v11u174pris;; L) export SLANG_UHDM=/tmp/v11u174_bin/law; wt=/tmp/wt_v11u174;; M) export SLANG_UHDM=/tmp/v11u174_bin/law2; wt=/tmp/wt_v11u174;; esac
unset GOLDEN_DEFER
cd $wt && bash tests/sweep.sh --jobs 3 --workdir /tmp/v11u174_sw$t --corpus "$1"

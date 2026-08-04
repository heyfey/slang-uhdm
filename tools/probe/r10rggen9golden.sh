#!/bin/bash
# r10rggen9golden: run Surelog on a purpose-built repro, dump golden UHDM (text).
# usage: r10rggen9golden.sh <dir> <file.sv> [extra surelog args]
D=$1; shift
F=$1; shift
cd "$D" || exit 1
rm -rf slpp_all
$HOME/git-repos/Surelog/build/bin/surelog -parse -mt 0 -mp 0 -d uhdm "$@" "$F" \
  > /tmp/r10rggen9_gold.log 2>&1
echo "rc=$?  uhdm=$D/slpp_all/surelog.uhdm"
grep -c . /tmp/r10rggen9_gold.log

#!/usr/bin/env bash
# usage: grid.sh <grid dir> <outroot> <binary> [jobs]  — runs arm.sh on every arm (subdirs with dut.sv)
set -u
G=$(cd "$1" && pwd); O=$2; B=$3; J=${4:-3}
D=$(cd "$(dirname "$0")" && pwd)
find "$G" -name dut.sv -printf '%h\n' | sort > "$O.list" 2>/dev/null || { mkdir -p "$(dirname $O)"; find "$G" -name dut.sv -printf '%h\n' | sort > "$O.list"; }
n=$(wc -l < "$O.list")
xargs -P "$J" -I{} bash -c 'a={}; r=${a#'"$G"'/}; bash '"$D"'/arm.sh "$a" '"$O"'/"$r" '"$B"' </dev/null' < "$O.list" | sort
echo "LISTED=$n"

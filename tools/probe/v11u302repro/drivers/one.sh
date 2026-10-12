#!/bin/bash
# v11u302 one.sh <case dir> <binary> <d|e> <out.uhdm>: writes our database for one case-view (deleting the output
# first) and prints the cached golden's path (case.sh's cache key).  Fail-closed on $FENCED.
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
d=$(realpath "$1"); b=$2; v=$3; o=$4
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "one.sh: fenced path refused" >&2; exit 2; }; done
[ -x "$b" ] || { echo "one.sh: binary not executable" >&2; exit 2; }
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
ex=""; [ $v = e ] && ex=--elabuhdm
rm -f $o; (cd $d && $b dut.sv --single-unit --nobuiltin $ex -o $o >/dev/null 2>&1 </dev/null)
echo ${V302_GOLD:-/tmp/v11u302_gold}/$h/g.uhdm

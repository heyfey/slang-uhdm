#!/bin/bash
# r11u202: judge every case dir (dut.sv) under a cases root with the frozen binaries named in $GRIDBINS (files in $B),
# one line per case: <case> <verdict per binary>(objects differing).  With OFFENV="<VAR=1 ...>" also runs the LAST binary
# under that environment and reports whether its database is byte-identical to the FIRST binary's (OFF=pristine).
# Uses case.sh (fence fail-closed).  usage: grid.sh <cases root> > grid.tsv    (GRIDTAG names the scratch dir)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
ROOT=$(cd "$1" && pwd); TAG=${GRIDTAG:-$(echo $ROOT | md5sum | cut -c1-8)}
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; r=${c#$ROOT/}; line="$r"; first=""; last=""
  for b in ${GRIDBINS:-pris.bin l200.bin}; do
    o=/tmp/r11u202_grid/$TAG/$b/$r; [ -z "$first" ] && first=$o; last=$b
    v=$(SLANG_UHDM=$B/$b bash $HERE/case.sh $c $o 2>/dev/null | V)
    n=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2)
    [ -n "$n" ] && v="$v($n)"; line="$line	$v"; done
  if [ -n "${OFFENV:-}" ]; then o=/tmp/r11u202_grid/$TAG/off/$r
    env $OFFENV SLANG_UHDM=$B/$last bash $HERE/case.sh $c $o > /dev/null 2>&1
    if cmp -s $o/ours.uhdm $first/ours.uhdm; then line="$line	OFF=pristine"; else line="$line	OFF=DIFF"; fi
  fi
  echo "$line"; }
export -f one V; export HERE GRIDBINS OFFENV ROOT TAG
find -L $ROOT -name dut.sv -printf '%h\n' | sort | xargs -P3 -I{} bash -c 'one {}' | sort

#!/bin/bash
# vswitch.sh <case-root>...: per case and view, the byte identity of (a) ver.bin R11U184_OFF=1 vs pris.bin,
# (b) ver.bin R11V184_OFF=1 vs law.bin, (c) each R11V184 switch alone vs law.bin where its trace fires, else vs ver.bin.
D=$(cd "$(dirname "$0")" && pwd); source $D/env.sh || exit 9
B=/tmp/v11u184_bin; W=/tmp/v11u184_sw; mkdir -p $W
run(){ (cd $1 && env "${@:4}" $2 ${ELAB:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $3 >/dev/null 2>&1); $UHDM_DUMP $3 2>/dev/null | sed "s#$3##" | md5sum | cut -c1-12; rm -f $3; }
for root in "$@"; do for c in $(find $root -name dut.sv -printf '%h\n' | sort); do
  echo "$c" | grep -qP "$FENCED_RE" && { echo "FENCE refuse $c"; continue; }
  for e in "" 1; do export ELAB=$e
    p=$(run $c $B/pris.bin $W/p.uhdm); l=$(run $c $B/law.bin $W/l.uhdm); v=$(run $c $B/ver.bin $W/v.uhdm)
    off=$(run $c $B/ver.bin $W/o.uhdm R11U184_OFF=1); voff=$(run $c $B/ver.bin $W/q.uhdm R11V184_OFF=1)
    fires=$( (cd $c && R11U184_TRACE=1 $B/ver.bin ${ELAB:+--elabuhdm} dut.sv --single-unit --nobuiltin -o $W/t.uhdm 2>&1 >/dev/null) | grep -c 'V184'); rm -f $W/t.uhdm
    s1=$([ $off = $p ] && echo U184OFF=pris || echo U184OFF!=pris); s2=$([ $voff = $l ] && echo V184OFF=law || echo V184OFF!=law)
    echo "$c${e:+.elab} $s1 $s2 v184fires=$fires $([ $v = $l ] && echo ver=law || echo ver!=law)"
  done
done; done

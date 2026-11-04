#!/bin/bash
# switches.sh <casedir>...: md5 of the law binary's database with each switch of pass 478 off, and the
# trace firings per law, against pristine.  Explicit case DIRECTORIES only.
P=/tmp/v11u478_bin/pristine; L=${LAWBIN:-/tmp/v11u478_bin/law}
[ -x "$P" ] && [ -x "$L" ] || exit 1
run() { local c=$1; shift; rm -f /tmp/v11u478_sw.uhdm; (cd "$c" && env "$@" dut.sv --single-unit --nobuiltin -o /tmp/v11u478_sw.uhdm >/dev/null 2>&1 </dev/null); echo "$?:$(md5sum < /tmp/v11u478_sw.uhdm | cut -c1-8)"; }
for c in "$@"; do
  [ -d "$c" ] || continue; c=$(realpath "$c")
  p=$(run $c $P); l=$(run $c $L)
  rm -rf /tmp/v11u478_swtr; mkdir -p /tmp/v11u478_swtr
  run $c R11U478_TRACE=/tmp/v11u478_swtr $L >/dev/null
  tr=$(cat /tmp/v11u478_swtr/* 2>/dev/null | grep -o '478[^ ]*\|aliasFormalCopyPerClone478\|cloneHierArrElemMember478\|aliasCopyParamUnnamed478\|providerBodyCopyBind478' | sort | uniq -c | awk '{printf "%s:%s,",$2,$1}')
  line="${c#*/cases/} pris=$p law=$l"
  for s in R11U478_OFF R11U478_ALIASCOPY_OFF R11U478_ARRMEMBER_OFF R11U478_ALIASPARNAME_OFF R11U478_PROVCOPYBIND_OFF ${EXTRA_SW}; do
    v=$(run $c $s=1 $L); t=x; [ "$v" = "$p" ] && t=P; [ "$v" = "$l" ] && t=L; [ "$p" = "$l" ] && [ "$v" = "$p" ] && t=PL
    line="$line ${s#R11U478_}=$t"
  done
  echo "$line trace=$tr"
done

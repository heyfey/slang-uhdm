#!/bin/bash
# sw3.sh <dir>...: md5 (exit code) of pristine, law, verified, verified+R11U479_OFF, verified+R11V479_OFF, verified+R11V479_CLSSCOPED_OFF; dut.sv --single-unit --nobuiltin from the dir
P=/tmp/v11u479_bin/pristine; L=/tmp/v11u479_bin/law; V=${VER:-/tmp/v11u479_bin/ver1}
O=/tmp/v11u479_sw3.uhdm
m(){ rm -f $O; (cd "$1" && env $2 "$3" dut.sv --single-unit --nobuiltin -o $O >/dev/null 2>&1 </dev/null); echo "$?:$( [ -f $O ] && md5sum < $O | cut -c1-8)"; }
for d in "$@"; do
  p=$(m "$d" "" $P); l=$(m "$d" "" $L); v=$(m "$d" "" $V); uo=$(m "$d" R11U479_OFF=1 $V); vo=$(m "$d" R11V479_OFF=1 $V); co=$(m "$d" R11V479_CLSSCOPED_OFF=1 $V)
  echo "$d p=$p l=$l v=$v | Uoff=$([ "$uo" = "$p" ] && echo pristine || echo DIFF) Voff=$([ "$vo" = "$l" ] && echo law || echo DIFF) CLSSCOPEDoff=$([ "$co" = "$l" ] && echo law || echo DIFF) ver=$([ "$v" = "$l" ] && echo =law || echo ne-law)"
done

#!/bin/bash
# swmat <dir>: md5 of pris, law, law2 and law2 under each switch
d=$1; cd $d; k=$(echo $d | md5sum | cut -c1-12); o=/tmp/v11u174_off/sw$k.uhdm
run(){ rm -f $o; timeout 300 env "$@" dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1; [ -s $o ] && md5sum < $o | cut -c1-8 || echo NODB; }
p=$(run /tmp/v11u174_bin/pris); l=$(run /tmp/v11u174_bin/law); a=$(run /tmp/v11u174_bin/law2)
out="$p $l $a"
for s in R11U172_DEPTH_OFF R11U174_LEFTREF_OFF R11U174_ASMSPAN_OFF R11U174_MOPUNLOC_OFF R11V174_MOPPKG_OFF R11U174_OFF R11U172_OFF; do out="$out $(run $s=1 /tmp/v11u174_bin/law2)"; done
rm -f $o; echo "$out $d"

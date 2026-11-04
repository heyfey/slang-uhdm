sw=$1; c=$2; W=/tmp/r11u482_bc$c
# swchk.sh <switch> <casedir>: law3 with one switch set against law3s own bytes (b.uhdm of bytecensus.sh): CONTRIB when they differ
(cd "$c" && env $sw=1 timeout 120 /tmp/r11u482_bin/law3 dut.sv --single-unit --nobuiltin -o "$W/sw.$sw.uhdm" >/dev/null 2>&1 </dev/null)
b=$(md5sum < "$W/b.uhdm" | cut -c1-12); o=$(md5sum < "$W/sw.$sw.uhdm" | cut -c1-12)
[ "$b" = "$o" ] && echo "$c $sw NOEFFECT" || echo "$c $sw CONTRIB"
rm -f "$W/sw.$sw.uhdm"

c=$1; W=/tmp/r11u482_bc$c
# offchk.sh <casedir>: law3 with R11U482_OFF against the pristine bytes bytecensus.sh left in /tmp/r11u482_bc<dir>/a.uhdm
(cd "$c" && R11U482_OFF=1 timeout 120 /tmp/r11u482_bin/law3 dut.sv --single-unit --nobuiltin -o "$W/off.uhdm" >/dev/null 2>&1 </dev/null); r=$?
a=$(md5sum < "$W/a.uhdm" | cut -c1-12); o=$(md5sum < "$W/off.uhdm" | cut -c1-12)
[ "$a" = "$o" ] && echo "$c SAME rc=$r" || echo "$c DIFF rc=$r"

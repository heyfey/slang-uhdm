#!/bin/bash
# switches.sh <binary> <casedir>...: md5 of the output under no switch, R11U478_OFF and each law's own switch
# (explicit case DIRECTORIES only); writes under /tmp/r11u478_sw/<full case path>/
B=$1; shift
[ -x "$B" ] || { echo "no binary $B"; exit 1; }
for c in "$@"; do
  [ -d "$c" ] || continue
  c=$(realpath "$c"); W=/tmp/r11u478_sw$c; mkdir -p "$W"
  line="${c#*/cases/}"
  for sw in NONE R11U478_OFF R11U478_ALIASCOPY_OFF R11U478_ARRMEMBER_OFF R11U478_ALIASPARNAME_OFF R11U478_PROVCOPYBIND_OFF; do
    rm -f "$W/$sw.uhdm"
    if [ $sw = NONE ]; then (cd "$c" && "$B" dut.sv --single-unit --nobuiltin -o "$W/$sw.uhdm" >/dev/null 2>&1 </dev/null); rc=$?
    else (cd "$c" && env $sw=1 "$B" dut.sv --single-unit --nobuiltin -o "$W/$sw.uhdm" >/dev/null 2>&1 </dev/null); rc=$?; fi
    line="$line $sw:rc$rc:$(md5sum < "$W/$sw.uhdm" | cut -c1-8)"
  done
  echo "$line"
done

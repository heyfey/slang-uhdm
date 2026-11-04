#!/bin/bash
# away.sh <dirlist> <out>: pristine vs law exit code and database md5 per case dir (dut.sv, --single-unit --nobuiltin).
P=/tmp/v11u478_bin/pristine; L=/tmp/v11u478_bin/law
[ -x "$P" ] && [ -x "$L" ] || exit 1
: > "$2"
while read -r c; do
  [ -d "$c" ] && [ -f "$c/dut.sv" ] || continue
  r=""
  for B in $P $L; do rm -f /tmp/v11u478_aw.uhdm; (cd "$c" && timeout 120 $B dut.sv --single-unit --nobuiltin -o /tmp/v11u478_aw.uhdm >/dev/null 2>&1 </dev/null); rc=$?
    m=$( [ -f /tmp/v11u478_aw.uhdm ] && md5sum < /tmp/v11u478_aw.uhdm | cut -c1-12 || echo none); r="$r $rc:$m"; done
  echo "$c$r" >> "$2"
done < "$1"

#!/bin/bash
# switches.sh <casesdir> : for every case, the md5 of the database written by the pristine binary, the law binary,
# the law binary with R11U171_OFF=1 R11U172_OFF=1 (must equal pristine), and the law binary with each single switch
# (the cases that switch restores to pristine are the law's movers).  Output: one line per case.
set -u; C=$(readlink -f $1); P=/tmp/r11u171_bin/pris.bin; L=/tmp/r11u171_bin/final.bin; O=/tmp/r11u171_scr/sw; mkdir -p $O
: "${FENCED:?FENCED unset}"
SW="R11U172_VALUE_OFF R11U172_FILE_OFF R11U172_SPAN_OFF R11U171_CASTUNIONFILE_OFF R11U171_MEMBERROOTFILE_OFF R11U171_SPLITPORTKEY_OFF R11U171_SELDECSHARE_OFF R11U171_UDPSWALLOW_OFF R11U171_NETENDCOL_OFF R11U171_NETENDPASTE_OFF R11U171_GENELSEIF_OFF"
run() { local tag=$1; shift; local out=$O/$key.$tag.uhdm; rm -f $out; (cd $d && env "$@" timeout 300 $BIN $FILES --single-unit --nobuiltin -o $out >/dev/null 2>&1 </dev/null); [ -s $out ] && md5sum < $out | cut -c1-12 || echo NODB; }
find $C \( -name dut.sv -o -name files \) -printf '%h\n' | sort -u | while read d; do
  for f in $FENCED; do echo "$d" | grep -qw "$f" && { echo "fenced refused $d"; continue 2; }; done
  key=$(echo $d | sed 's|.*/cases/||; s|/|__|g'); FILES=$( [ -f $d/files ] && cat $d/files || echo dut.sv )
  BIN=$P; p=$(run p X=1); BIN=$L; l=$(run l X=1); a=$(run a R11U171_OFF=1 R11U172_OFF=1)
  line="$(echo $d | sed 's|.*/cases/||') pris=$p law=$l alloff=$([ "$a" = "$p" ] && echo PRIS || echo DIFF:$a)"
  for s in $SW; do r=$(run $s $s=1); [ "$r" = "$p" ] && [ "$l" != "$p" ] && line="$line $s:restores"; [ "$r" != "$l" ] && [ "$r" != "$p" ] && line="$line $s:partial"; done
  echo "$line"
done

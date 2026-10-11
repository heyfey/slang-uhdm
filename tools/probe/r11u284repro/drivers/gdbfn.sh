#!/bin/bash
# r11u284 gdbfn.sh: decode aid (probe and fresh cases only, fail-closed on $FENCED): backtraces of a VpiFullName write.
# gdbfn.sh <case dir> <fullname string> [binary]: backtraces of every ref_typespec VpiFullName write of that string (probe/fresh cases only)
d=$1; s=$2; b=${3:-/tmp/r11u284_bin/pris.bin}
[ -n "$FENCED" ] || { echo FENCED unset; exit 2; }
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo fenced; exit 2; }; done
t=/tmp/r11u284_scratch/gdbrun.$$; rm -rf $t; mkdir -p $t; cp $d/*.sv $t/ 2>/dev/null; cd $t
n=${#s}; SYM=${SYM:-ref_typespec}
timeout 300 gdb -batch -ex "break UHDM::${SYM:-ref_typespec}::VpiFullName(std::basic_string_view<char, std::char_traits<char> >) if \$rsi==$n && \$_memeq(\$rdx,\"$s\",$n)" -ex run -ex 'bt 8' -ex continue -ex 'bt 8' -ex continue -ex 'bt 8' --args $b dut.sv --single-unit --nobuiltin $EXTRA -o $t/o.uhdm 2>&1 | grep -E '^#[0-9]' | sed -E 's/\(.*\) at / at /; s/\(.*//' | cut -c1-170
rm -rf $t

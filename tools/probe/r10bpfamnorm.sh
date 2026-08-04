#!/bin/bash
# r10bpfam: CMP-relevant projection of uhdm-dump text.  uhdm-cmp reads only
# VpiType / VpiName / VpiDefName per object plus constant extras
# (VpiConstType/VpiDecompile/VpiSize) and typespec Instance().  Locations,
# vpiRef*No, vpiFullName, vpiFile are NEVER compared -- strip them so the
# residue is only what can actually fail.
# Usage: r10bpfamnorm.sh <golden.uhdm-dump.txt> <ours.uhdm-dump.txt> <out.diff>
norm() {
  sed -e 's/, line:[0-9]*:[0-9]*, endln:[0-9]*:[0-9]*//g' \
      -e 's/, line:[0-9]*:[0-9]*//g' \
      -e '/|vpiRef[A-Za-z]*No:/d' \
      -e '/|vpiFullName:/d' \
      -e '/|vpiFile:/d' \
      -e '/|vpiColumnNo:/d' \
      -e '/|vpiLineNo:/d' \
      -e '/|vpiEndLineNo:/d' \
      -e '/|vpiEndColumnNo:/d' \
      -e 's|, file:[^,]*,|,|' \
      "$1"
}
norm "$1" > /tmp/r10bpfam_n_g.txt
norm "$2" > /tmp/r10bpfam_n_o.txt
diff /tmp/r10bpfam_n_g.txt /tmp/r10bpfam_n_o.txt > "$3"
echo "cmp-relevant residue lines: $(grep -c '^[<>]' "$3")"

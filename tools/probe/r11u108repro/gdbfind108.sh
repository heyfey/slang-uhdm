#!/bin/bash
# gdbfind108.sh <arm-dir> <exact-string> [setter]
# SITE LOCATOR (measurement only).  Backtraces every call of a UHDM setter
# (default: ref_typespec::VpiFullName) whose string_view argument equals the
# given string exactly, in a DECODE build of the pristine source: Release
# flags plus -g (`-DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -g"`, same config
# mapping as the shipped build -- a Debug-config build links the dependency
# packages differently and ran out of memory here).  The decode binary must
# write byte-identical databases to the pristine one (checked on grid f4 c02).
# libuhdm has no debug info, so the argument is read from the SysV registers:
# rsi = length, rdx = data pointer.
#   DECODE_BIN=<decode binary> gdbfind108.sh <dir> <string>
BIN=${DECODE_BIN:?set DECODE_BIN}; DIR=${1:?}; STR=${2:?}
SET=${3:-UHDM::ref_typespec::VpiFullName(std::basic_string_view<char, std::char_traits<char> >)}
N=${#STR}; CMD=$(mktemp "${TMPDIR:-/tmp}/gdbfind108.XXXX"); OUTDB=$(mktemp "${TMPDIR:-/tmp}/gdbfind108db.XXXX")
cat > "$CMD" <<EOC
set pagination off
set print frame-arguments none
break $SET if \$rsi == $N && \$_memeq((char*)\$rdx, "$STR", $N)
commands
bt 7
continue
end
run
quit
EOC
(cd "$DIR" && timeout 600 gdb -batch -x "$CMD" --args "$BIN" dut.sv --single-unit --nobuiltin -o "$OUTDB" </dev/null 2>&1) \
  | grep -E '^#[0-9]' | sed -E 's/ \(.*\) at / at /; s/0x[0-9a-f]+ in //'
rm -f "$CMD" "$OUTDB"

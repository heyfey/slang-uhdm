#!/bin/bash
# r11u229: firecases.sh <out> <casedir>...: the firing census of fix.bin's refinement over case directories: each case in
# both views (--elabuhdm too) with R11V229_TRACE into a fresh directory, output to scratch (no golden needed: every
# code path of § unitImportFileOrder229v with two or more compilation-unit imports traces, and with fewer the
# refinement changes nothing).  Prints one line per case-view that fired.  Fail-closed on $FENCED; paths from args.
source "$(dirname "$0")/env.sh" || exit 2
[ -x "$FIX" ] || { echo "firecases.sh: FIX not executable" >&2; exit 2; }
O=$1; shift; : > $O
one() {
  c=$(realpath $1)
  for n in $FENCED; do echo "$c" | grep -qw "$n" && return; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args); [ -f "$c/${SRC%% *}" ] || return
  for ox in "" --elabuhdm; do
    t=$(mktemp -d /tmp/r11u229_fc.XXXXXX)
    (cd $c && R11V229_TRACE=$t timeout 300 $FIX $SRC --single-unit --nobuiltin $ox -o $t/o.uhdm > /dev/null 2>&1)
    f=$(cat $t/*.229 2>/dev/null | grep -v '^OUT ' | tr '\n' ' ')
    [ -n "$f" ] && echo "$c ${ox:-parse} $f"
    rm -rf $t
  done
}
export -f one; export FIX FENCED
printf '%s\n' "$@" | xargs -P ${P:-3} -I{} bash -c 'one {}' >> $O
echo "# case dirs: $#; case-views that fired: $(grep -c . $O)"

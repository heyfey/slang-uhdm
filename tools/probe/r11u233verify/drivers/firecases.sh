#!/bin/bash
# r11u233: firecases.sh <binary> <out> <casedir>...: the firing census of the laws of passes 227 and 228 (and of this
# pass's refinements) over case directories: each case in both views with R11U227_TRACE, R11U228_TRACE and
# R11V233_TRACE into a fresh directory, output to scratch (no golden needed).  Prints one line per case-view that fired.
# Fail-closed on $FENCED; paths from args.
source "$(dirname "$0")/env.sh" || exit 2
B=$1; O=$2; shift 2; [ -x "$B" ] || { echo "firecases.sh: $B not executable" >&2; exit 2; }
: > $O
one() {
  c=$(realpath $1)
  for n in $FENCED; do echo "$c" | grep -qw "$n" && return; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args); [ -f "$c/${SRC%% *}" ] || return
  for ox in "" --elabuhdm; do
    t=$(mktemp -d /tmp/r11u233_fc.XXXXXX)
    (cd $c && R11U227_TRACE=$t R11U228_TRACE=$t R11V233_TRACE=$t timeout 300 "$B" $SRC --single-unit --nobuiltin $ox -o $t/o.uhdm > /dev/null 2>&1)
    f=$(cat $t/*.22[78] $t/*.233 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort | uniq -c | tr -s ' ' | tr '\n' ' ')
    echo "$c ${ox:-parse} ${f:--}"
    rm -rf $t
  done
}
export -f one; export B FENCED
printf '%s\n' "$@" | xargs -P ${P:-3} -I{} bash -c 'one {}' >> $O
echo "# case dirs: $#; case-views that fired: $(grep -vc ' -$' $O)"

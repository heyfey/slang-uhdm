#!/bin/bash
# controls.sh <pristine bin> <law bin> <dir>... — the landed laws' cases as byte controls.  Each dut.sv under the
# given pass dirs runs through both binaries (`dut.sv --single-unit --nobuiltin`, in its own dir); a case whose bytes
# move is judged against its golden (case.sh, cached) and reported pristine vs law: strict verdict and objects
# differing.  A path naming a fenced test (FENCED, word boundary) is skipped unopened.
set -u
: "${FENCED:?}"
here=$(cd "$(dirname "$0")" && pwd)
p=$1; l=$2; shift 2
t=$(mktemp -d /tmp/r11u166_ctl.XXXX)
tot=0; same=0; moved=0
for dir in "$@"; do
  while read -r f; do
    skip=0; for x in $FENCED; do [[ "$f" =~ (^|[^A-Za-z0-9_])$x([^A-Za-z0-9_]|$) ]] && skip=1; done
    [ $skip = 1 ] && continue
    d=$(dirname "$f"); tot=$((tot+1))
    rm -f "$t"/*.uhdm
    (cd "$d" && "$p" dut.sv --single-unit --nobuiltin -o "$t/p.uhdm" >/dev/null 2>&1)
    (cd "$d" && "$l" dut.sv --single-unit --nobuiltin -o "$t/l.uhdm" >/dev/null 2>&1)
    if cmp -s "$t/p.uhdm" "$t/l.uhdm"; then same=$((same+1)); continue; fi
    moved=$((moved+1))
    # judged copies (case.sh refuses paths outside r11u166 dirs): copy the case dir to scratch
    cd2=/tmp/r11u166_ctlcase/$(echo "$d" | md5sum | cut -c1-12); rm -rf "$cd2"; mkdir -p "$cd2"; cp -r "$d"/. "$cd2"/
    a=$(bash "$here/case.sh" "$cd2" "$p" P); b=$(bash "$here/case.sh" "$cd2" "$l" L)
    w=$(echo "$b" | sed 's/.*\[//;s/\]//')
    np=$("$STRICT_CMP" --max 0 "$w/golden.uhdm" "$w/P.uhdm" 2>&1 | grep -o 'objects_differing=[0-9]*' | cut -d= -f2)
    nl=$("$STRICT_CMP" --max 0 "$w/golden.uhdm" "$w/L.uhdm" 2>&1 | grep -o 'objects_differing=[0-9]*' | cut -d= -f2)
    echo "MOVED $d | P: $(echo "$a" | awk '{print $3,$4}') n=${np:-0} | L: $(echo "$b" | awk '{print $3,$4}') n=${nl:-0}"
  done < <(find "$dir" -name dut.sv | sort)
done
echo "TOTAL cases=$tot byte-identical=$same moved=$moved"
rm -rf "$t"

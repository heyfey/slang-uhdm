# (v11u304: copied from r11u304repro/drivers, scratch renamed to /tmp/v11u304_*)
#!/bin/bash
# r11u304 firescan.sh <law bin> <out>: runs the law binary (default view) under R11U304_TRACE over every
# dut.sv dir under tools/probe and tests/probe (the path list built first and filtered by $FENCED before any
# file is opened), and lists each dir whose run wrote a trace line (a firing or an abstention):
# `<dir> <tags>`.  Used to select the trigger controls.  Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "firescan.sh: FENCED unset" >&2; exit 2; }
B=$1; O=$2; [ -x "$B" ] || { echo "firescan.sh: binary not executable" >&2; exit 2; }
H=$(cd "$(dirname "$0")" && pwd); R=$(cd "$H/../../../.." && pwd)
FR="\\b($(echo $FENCED | tr ' ' '|'))\\b"
W=$(mktemp -d /tmp/v11u304_scan.XXXXXX)
(cd $R && find tools/probe tests/probe -name dut.sv | sort) | grep -vP "$FR" | sed 's#/dut.sv$##' > $W/list
wc -l < $W/list
cat $W/list | xargs -P 3 -I{} bash -c 'd={}; k=$(echo "$d" | md5sum | cut -c1-16); mkdir -p '"$W"'/t/$k; (cd '"$R"'/$d && R11U304_TRACE='"$W"'/t/$k timeout 120 '"$B"' dut.sv --single-unit --nobuiltin -o '"$W"'/o_$k.uhdm >/dev/null 2>&1 </dev/null); rm -f '"$W"'/o_$k.uhdm; if ls '"$W"'/t/$k/* >/dev/null 2>&1; then echo "$d $(cat '"$W"'/t/$k/* | grep -v ^OUT | cut -d" " -f1 | sort | uniq -c | awk "{printf \"%s:%s \", \$2, \$1}")"; fi; rm -rf '"$W"'/t/$k' | sort > $O
rm -rf $W
wc -l < $O

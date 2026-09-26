#!/bin/bash
# census.sh <law binary> <out dir>: the firing census of the r11u173 refinement BEFORE its gate sweep.  The refinement
# fires only under --elabuhdm, which only the surelog corpus's testflags mode passes (0 of 871 uhdm2rtlil testflags
# rows, no probe case), so the census runs that stage alone through the harness with tracewrap.sh as SLANG_UHDM, with
# a negative-lookahead --filter that drops the four fenced tests (fail-closed on $FENCED), and prints the predicted
# movers by name.  A positive control (pv/p07 --elabuhdm) must fire.
source /tmp/wt_r11u173/tools/probe/r11u173verify/drivers/env.sh || exit 2
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census.sh: FENCED" >&2; exit 2; }
B=$1; O=$2; mkdir -p $O; rm -f $O/census.log
F="^(?!($(echo $FENCED | tr ' ' '|'))\$)"
export LAWBIN=$B CENLOG=$O/census.log SLANG_UHDM=/tmp/wt_r11u173/tools/probe/r11u173verify/drivers/tracewrap.sh
( cd /tmp/wt_r11u173/tools/probe/r11u173verify/cases/pv/p07_array_elem_genfor_named && R11V173_TRACE=1 $B dut.sv --single-unit --nobuiltin --elabuhdm -o $O/ctl.uhdm 2>&1 >/dev/null | grep -c R11V173_TRACE | sed 's/^/positive control firings: /' )
cd /tmp/wt_r11u173 && python3 scripts/verify_golden.py --corpus surelog --mode testflags --jobs 3 --filter "$F" --out $O/sl_tf.csv --workdir $O/wd > $O/census_run.log 2>&1
echo "census firings (rows): $(awk '{print $1}' $O/census.log | sort -u | wc -l)"
awk '{print $1}' $O/census.log | sed 's#.*/testflags/##; s#-[0-9a-f]*/slang.uhdm##' | sort -u | sed 's/^/  predicted mover: surelog testflags /'
for f in $FENCED; do grep -cw "$f" $O/census.log $O/sl_tf.csv; done | awk -F: '{s+=$NF} END{print "fenced mentions:", s+0}'

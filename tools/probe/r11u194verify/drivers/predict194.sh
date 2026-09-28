#!/bin/bash
# predict194.sh <out>: the fix's byte-mover prediction, written before the fix sweep.  § tpCaPortNetIsVar194v sits inside
# § tpEnumCopyAtTypedef184's scan and § incDecSelCallArgRead194v inside § incDecMemberSelIsLvalue184's operand (each can
# move bytes only where its parent law fires); fix.bin with R11U184_TRACE=1 on (1) every tests/probe case (dut.sv
# --single-unit --nobuiltin, both views) and (2) the corpus rows where pass 184's census saw TPENUM or INCDECSEL fire
# (TypeParameterAsPortTypeWithEnum* in uhdm2rtlil; BuildUVMPkg, MiniAmiq, Scoreboard, SeqDriver, SimpleUVM in surelog;
# both modes, through verify_golden.py --filter, checked against $FENCED), printing every database whose trace holds a
# `V194` line.  Fail-closed on $FENCED.
source "$(dirname "$0")/env.sh" || exit 2
O=$1; T=/tmp/r11u194_pred194; rm -rf $T; mkdir -p $T
find $R194_ROOT/tests/probe -name dut.sv | sort | grep -Pv "$FENCE_RE" > $T/list
echo "probe cases listed $(wc -l < $T/list)"
one() { c=$(dirname $1); k=$(echo ${c#$R194_ROOT/tests/probe/} | tr / _)
  for el in "" --elabuhdm; do (cd $c && R11U184_TRACE=1 $FIX dut.sv --single-unit --nobuiltin $el -o $T/$k$el.uhdm 2>&1 >/dev/null | grep -q 'V194 ' && echo "probe ${c#$R194_ROOT/tests/probe/}$el"); rm -f $T/$k$el.uhdm; done; }
export -f one; export T FIX R194_ROOT
xargs -a $T/list -P 3 -I{} bash -c 'one {}' > $O
F='^TypeParameterAsPortTypeWithEnum'; echo "$F" | grep -Pq "$FENCE_RE" && exit 4
printf '#!/bin/bash\nR11U184_TRACE=1 %s "$@" 2> >(grep "V194 " | sed "s#^#$PWD #" >> %s/corpus.trace)\n' $FIX $T > $T/w.sh; chmod +x $T/w.sh
cd $R194_ROOT && SLANG_UHDM=$T/w.sh python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 2 --filter "$F" --out $T/u2r.csv --workdir $T/wd > $T/u2r.log 2>&1
F2='^(BuildUVMPkg|MiniAmiq|Scoreboard|SeqDriver|SimpleUVM)$'; echo "$F2" | grep -Pq "$FENCE_RE" && exit 4
SLANG_UHDM=$T/w.sh python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 --filter "$F2" --out $T/sl.csv --workdir $T/wds > $T/sl.log 2>&1
echo "corpus rows run: $(( $(grep -c , $T/u2r.csv) + $(grep -c , $T/sl.csv) - 2 )) firing lines: $(cat $T/corpus.trace 2>/dev/null | wc -l)" >> $O
sort $T/corpus.trace 2>/dev/null | uniq -c | sed 's/^/  corpus-firing /' >> $O
echo "predicted probe databases: $(grep -c '^probe' $O)"; date >> $O

#!/bin/bash
# attrib.sh <corpus/mode/test> : re-export one mover row (argument vector from the pristine sweep's cmds.txt) with the
# pristine binary, the final binary (R11U171_TRACE=1: the law tags that fired), and the final binary with each single
# switch; prints which switches restore the pristine bytes.  Fenced tests refused (fail closed).
set -u; K=$1; C=${K%%/*}; r=${K#*/}; M=${r%%/*}; T=${r#*/}
: "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
for f in $FENCED; do echo "$T" | grep -qw "$f" && { echo "FENCED refused"; exit 3; }; done
REF=/tmp/r11u171_swP; O=/tmp/r11u171_scr/attr/$C.$M.$T; mkdir -p $O
cm=$(ls -d $REF/$C/$M/$T-*/cmds.txt | head -1)
args=$(grep '^slang:' $cm | sed 's/^slang: *[^ ]* //; s/ -o [^ ]*$//')
if [ $C = uhdm2rtlil ]; then cwd=$UHDM2RTLIL_TESTS/$T; else cwd=$(dirname $(find $SURELOG_ROOT/tests $SURELOG_ROOT/third_party/tests -name "$T.sl" | head -1)); fi
run() { local tag=$1; shift; rm -f $O/$tag.uhdm; (cd $cwd && env "$@" $BIN $args -o $O/$tag.uhdm > $O/$tag.log 2>&1 </dev/null); md5sum < $O/$tag.uhdm | cut -c1-12; }
BIN=/tmp/r11u171_bin/pris.bin; p=$(run p X=1); p2=$(run p2 X=1)
BIN=/tmp/r11u171_bin/final.bin; f=$(run f R11U171_TRACE=1); a=$(run a R11U171_OFF=1 R11U172_OFF=1)
tags=$(grep -o '^R11U171 [A-Z]*' $O/f.log | sort | uniq -c | awk '{printf "%s:%s ", $3, $1}')
line="$K pris=$p pris2=$( [ $p = $p2 ] && echo same || echo COIN) final=$f alloff=$( [ $a = $p ] && echo PRIS || echo DIFF) trace=[$tags]"
for s in R11U172_VALUE_OFF R11U172_FILE_OFF R11U172_SPAN_OFF R11U171_CASTUNIONFILE_OFF R11U171_MEMBERROOTFILE_OFF R11U171_SPLITPORTKEY_OFF R11U171_SELDECSHARE_OFF R11U171_UDPSWALLOW_OFF R11U171_NETENDCOL_OFF R11U171_GENELSEIF_OFF; do
  x=$(run s $s=1); [ "$x" != "$f" ] && line="$line $s:moves$( [ $x = $p ] && echo '(restores)')"
done
echo "$line"

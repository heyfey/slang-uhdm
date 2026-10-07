#!/bin/bash
# v11u274 case.sh (copied from r11u274repro) <case dir> <binary> [d|e] [max]: one case-view.  The golden is the
# pinned Surelog's database with check_probe's arguments (view e: + -elabuhdm; ours
# + --elabuhdm), cached under $R274_GOLD (default /tmp/v11u274_gold) by the md5 of the
# case's files and the view.  Prints: rc=<ours> cmp=<uhdm-cmp lines> <strict verdict>
# md5=<database md5>.  Refuses a case dir naming a fenced test (fail-closed on $FENCED).
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "case.sh: FENCED unset" >&2; exit 2; }
for t in SURELOG UHDM_CMP STRICT_CMP; do [ -x "${!t}" ] || { echo "case.sh: $t not executable" >&2; exit 2; }; done
d=$(realpath "$1"); bin=$2; v=${3:-d}; m=${4:-5}
[ -x "$bin" ] || { echo "case.sh: binary not executable" >&2; exit 2; }
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "case.sh: fenced path refused" >&2; exit 2; }; done
G=${R274_GOLD:-/tmp/v11u274_gold}
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
gd=$G/$h
if [ ! -s $gd/g.uhdm ]; then
  # built in a private directory and moved in whole: two concurrent runs of one case-view never see half a golden
  t=$gd.tmp.$$; rm -rf $t; mkdir -p $t/o
  ex=""; [ $v = e ] && ex="-elabuhdm"
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 $ex -o $t/o >/dev/null 2>&1 </dev/null)
  f=$(find $t/o -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $t/g.uhdm
  if [ -s $t/g.uhdm ] && [ ! -s $gd/g.uhdm ]; then mkdir -p $gd; mv $t/g.uhdm $gd/g.uhdm.$$ && mv $gd/g.uhdm.$$ $gd/g.uhdm; fi
  rm -rf $t
fi
[ -s $gd/g.uhdm ] || { echo "rc=- NOGOLDEN"; exit 0; }
O=${R274_OUT:-/tmp/v11u274_caseout}; mkdir -p $O
o=$O/$(echo "$d|$bin|$v|$$|$RANDOM" | md5sum | cut -c1-16).uhdm; rm -f $o
ex=""; [ $v = e ] && ex="--elabuhdm"
(cd $d && $bin dut.sv --single-unit --nobuiltin $ex -o $o >/dev/null 2>&1 </dev/null); rc=$?
[ -s $o ] || { echo "rc=$rc NODB"; exit 0; }
c=$($UHDM_CMP $gd/g.uhdm $o 2>&1 | wc -l)
s=$($STRICT_CMP --max $m $gd/g.uhdm $o 2>&1)
md=$(md5sum < $o | cut -c1-12)
echo "rc=$rc cmp=$c $(echo "$s" | tail -1) md5=$md"
[ -n "$SHOW" ] && echo "$s"
[ -n "$KEEP" ] && cp $o "$KEEP"
rm -f $o

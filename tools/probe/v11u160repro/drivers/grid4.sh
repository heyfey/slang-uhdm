#!/bin/bash
# grid4.sh <casedir>: one case, five states, each judged against the pinned Surelog's golden.
#   pris = pristine 75226e07, law = the implementer's r11u160.patch build, ver = r11u160.verified.patch build,
#   off  = ver under R11U160_OFF=1 (must equal pris bytes), unref = ver under R11V160_PASTECHAIN_OFF=1
#   R11V160_TPWHOLEUNINST_OFF=1 (must equal law bytes).
# Scratch under GW (default /tmp/v11u160_gG), never in the case dir. Prints one line per case:
#   <rel> pris=<verdict/n> law=<verdict/n> ver=<verdict/n> off=<PRISBYTES|DIFF> unref=<LAWBYTES|DIFF> cls=<classifier on pris->ver>
c=$(realpath $1); GW=${GW:-/tmp/v11u160_gG}
PB=${PB:-/tmp/v11u160_bin/pris.bin}; LB=${LB:-/tmp/v11u160_bin/law.bin}; VB=${VB:-/tmp/v11u160_bin/fix2.bin}
SURELOG=${SURELOG:-/home/heyfey/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
SC=${STRICT_CMP:-/tmp/v11u160_bin/uhdm-strictcmp}
UNMASK=${UNMASK:-$(dirname $0)/unmask.py}
rel=$(echo $c | sed "s#.*/cases/##"); w=$GW/$rel; mkdir -p $w; g=$w/gold/golden.uhdm
if [ ! -s $g ] || [ $c/dut.sv -nt $g ]; then
  rm -rf $w/gold; mkdir -p $w/gold/w
  (cd $c && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/gold/w > $w/gold/sl.log 2>&1)
  f=$(find $w/gold/w -name '*.uhdm' | head -1); [ -n "$f" ] && cp $f $g; rm -rf $w/gold/w
fi
run(){ rm -f $w/$1.uhdm; (cd $c && env $3 $2 dut.sv --single-unit --nobuiltin -o $w/$1.uhdm > $w/$1.log 2>&1); echo $? > $w/$1.rc; }
run pris $PB ""; run law $LB ""; run ver $VB ""; run off $VB "R11U160_OFF=1"; run unref $VB "R11V160_PASTECHAIN_OFF=1 R11V160_TPWHOLEUNINST_OFF=1"
v(){ [ -s $g ] || { echo "SURELOG_FAIL(rc=$(cat $w/$1.rc))"; return; }; [ -s $w/$1.uhdm ] || { echo "NOOUT(rc=$(cat $w/$1.rc))"; return; }
  $CMP $g $w/$1.uhdm > $w/$1.cmp 2>&1; cr=$?; [ $cr = 0 ] || { echo "CMP_NOTEQUAL"; return; }
  r=$($SC --max 1000000 $g $w/$1.uhdm 2>&1); echo "$(echo "$r" | tail -1 | awk '{print $1}')/$(echo "$r" | grep -c '^#')"; }
same(){ { [ -s $w/$1.uhdm ] || [ -s $w/$2.uhdm ]; } || { echo NOOUT; return; }; cmp -s $w/$1.uhdm $w/$2.uhdm && echo $3 || echo DIFF; }
cls=-; [ -s $g ] && [ -s $w/pris.uhdm ] && [ -s $w/ver.uhdm ] && cls=$(python3 $UNMASK $g $w/pris.uhdm $w/ver.uhdm | head -1 | awk '{print $1}')
echo "$rel pris=$(v pris) law=$(v law) ver=$(v ver) off=$(same off pris PRISBYTES) unref=$(same unref law LAWBYTES) cls=$cls"

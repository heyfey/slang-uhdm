#!/usr/bin/env bash
# r11u121 boundary attribution: for every DIFF arm of ctl121.sh, (1) which single switch
# restores the pristine bytes, (2) order-blind locdump distance to golden, pristine -> LAW,
# per form (pr: pinned v1.87 with probe flags; ds: uhdm2rtlil's Surelog with -DSYNTHESIS).
# usage: attr121.sh <repo> <ctl.txt> <law bin> <pristine bin> <scratch>
set -u
R=$1; C=$2; L=$3; P=$4; S=$5; mkdir -p $S
U2RSL=${UHDM2RTLIL_ROOT}/build/third_party/Surelog/bin/surelog
LD=${LOCDUMP:-/tmp/r11u121_locdump}  # built from ../r11u119repro/locdump.cpp (README)
for rel in $(grep ^DIFF $C | awk '{print $2}' | sort -u); do
  d=$R/$rel; k=$(echo $rel | md5sum | cut -c1-12); w=$S/$k; rm -rf $w; mkdir -p $w/g187 $w/gds
  (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $w/g187 >/dev/null 2>&1 </dev/null)
  (cd $d && $U2RSL -parse -nobuiltin -nocache -DSYNTHESIS -filterprotected -d vpi_ids -d uhdm -sv dut.sv -mt 0 -mp 0 -o $w/gds >/dev/null 2>&1 </dev/null)
  G1=$(find $w/g187 -name surelog.uhdm | head -1); G2=$(find $w/gds -name surelog.uhdm | head -1)
  out="$rel"
  for f in pr ds; do
    if [ $f = ds ]; then fl="-DSYNTHESIS"; G=$G2; else fl=""; G=$G1; fi
    for b in P L; do bin=$P; [ $b = L ] && bin=$L; rm -f $w/$b$f.uhdm; (cd $d && $bin $fl dut.sv --single-unit --nobuiltin -o $w/$b$f.uhdm >/dev/null 2>&1 </dev/null); done
    who=""
    for sw in R11U121_TPGS_OFF R11U121_QMSEL_OFF R11U121_PVSPAN_OFF R11U121_PVSP_OFF; do
      rm -f $w/x.uhdm; (cd $d && env $sw=1 $L $fl dut.sv --single-unit --nobuiltin -o $w/x.uhdm >/dev/null 2>&1 </dev/null)
      cmp -s $w/x.uhdm $w/P$f.uhdm && who="$who ${sw#R11U121_}"
    done
    if [ -n "$G" ] && [ -s "$G" ]; then
      dp=$(diff <($LD $G) <($LD $w/P$f.uhdm) | grep -c '^[<>]'); dl=$(diff <($LD $G) <($LD $w/L$f.uhdm) | grep -c '^[<>]')
      cp=$($UHDM_CMP $G $w/P$f.uhdm 2>&1 | wc -l); cl=$($UHDM_CMP $G $w/L$f.uhdm 2>&1 | wc -l)
    else dp=NA; dl=NA; cp=NA; cl=NA; fi
    same=""; cmp -s $w/P$f.uhdm $w/L$f.uhdm && same=" BYTESAME"
    v=SAME; [ "$dp" != NA ] && { [ $dl -lt $dp ] && v=TO; [ $dl -gt $dp ] && v=AWAY; }
    out="$out | $f dist=$dp->$dl cmp=$cp->$cl $v drop=[${who# }]$same"
  done
  echo "$out"
done

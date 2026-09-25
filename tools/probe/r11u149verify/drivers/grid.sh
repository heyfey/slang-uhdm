#!/bin/bash
# grid.sh [case dirs...]: every case x {plain, elab} x {ON, OFF (both landings off), OWN (the law's own switch)}
D=/tmp/wt_r11u149/tools/probe/r11u149verify/drivers; C=/tmp/wt_r11u149/tools/probe/r11u149verify/cases
own(){ case $1 in
 sca) echo R11U140_SYSUNARY_OFF=1;; scv) echo R11V140_CONSTSEL_OFF=1;; stm) echo R11U140_STREAMBRACE_OFF=1;;
 plv) echo R11U140_LVIDX_OFF=1;; plt) echo R11U140_LVTRAIL_OFF=1;; fav) echo R11U140_FEFILE_OFF=1;;
 pso) echo R11U140_PATOPSPAN_OFF=1;; mdi) echo R11U140_MULTIDECL_OFF=1;; lat) echo R11U140_LHSARRTS_OFF=1;;
 pfp) echo R11U140_PKGREFMD_OFF=1;; pfx) echo R11V140_MDRENAME_OFF=1;; tdc) echo R11U140_PKGTDCAST_OFF=1;;
 dfl) echo R11U140_DEFFILL_OFF=1;; rcf) echo R11U140_REPLCNTFILE_OFF=1;;
 el) echo R11U144_ELABINST_OFF=1 R11U144_ELABPROP_OFF=1;; ia) echo R11U144_SELBAREDEC_OFF=1;;
 pf) echo R11U144_CALLBITSEL_OFF=1;; fb) echo R11U144_FOLDTSNAME_OFF=1;; tq) echo R11U144_TPPACKEDNET_OFF=1;;
 pt) echo R11U144_PARAMALIASREF_OFF=1;; qb) echo R11U144_PKGQUALREF_OFF=1;; vf) echo R11U144_METHQUALSPAN_OFF=1;;
 at) echo R11U144_METHATTR_OFF=1;; hg) echo R11U144_DEFGENHP_OFF=1;; esac; }
cases=("$@"); [ ${#cases[@]} -eq 0 ] && cases=($(ls -d $C/*/*/ | sed 's#/$##'))
for c in "${cases[@]}"; do g=$(basename $(dirname $c))
  for m in plain elab; do
    bash $D/case.sh $c $m ON /tmp/r11u149_bin/on.bin
    bash $D/case.sh $c $m OFF /tmp/r11u149_bin/on.bin R11U140_OFF=1 R11U144_OFF=1
    bash $D/case.sh $c $m OWN /tmp/r11u149_bin/on.bin $(own $g)
  done
done

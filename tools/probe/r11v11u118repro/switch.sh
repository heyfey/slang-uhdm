#!/usr/bin/env bash
# switch audit: usage switch.sh <outroot> <pris> <law> <fix> <arm dir>...
# per arm, probe-flag databases (fresh files): fix+ALL_OFF vs pristine, fix+PSPAREN_OFF vs law,
# fix+PKGPS_OFF vs law+PKGPS_OFF, fix+PKGVS_OFF vs law+PKGVS_OFF.
O=$1; BP=$2; BL=$3; BF=$4; shift 4
run(){ rm -f "$3"; (cd "$1" && env $4 $2 dut.sv --single-unit --nobuiltin -o "$3" >/dev/null 2>&1); }
for a in "$@"; do
  d=$O/$(basename $a); mkdir -p $d
  run $a $BP $d/p.uhdm X=1; run $a $BL $d/l.uhdm X=1; run $a $BF $d/f.uhdm X=1
  run $a $BF $d/f_all.uhdm R11U118_OFF=1; run $a $BF $d/f_par.uhdm R11U118_PSPAREN_OFF=1
  run $a $BF $d/f_ps.uhdm R11U118_PKGPS_OFF=1; run $a $BL $d/l_ps.uhdm R11U118_PKGPS_OFF=1
  run $a $BF $d/f_vs.uhdm R11U118_PKGVS_OFF=1; run $a $BL $d/l_vs.uhdm R11U118_PKGVS_OFF=1
  c(){ cmp -s $d/$1 $d/$2 && echo = || echo X; }
  echo "$(basename $a) law=$(c p.uhdm l.uhdm | tr '=X' 'PM') fix=$(c l.uhdm f.uhdm | tr '=X' 'LM') ALLOFF~pris:$(c f_all.uhdm p.uhdm) PAROFF~law:$(c f_par.uhdm l.uhdm) PSOFF:$(c f_ps.uhdm l_ps.uhdm) VSOFF:$(c f_vs.uhdm l_vs.uhdm) PSOFFonly_moves:$(c f_ps.uhdm p.uhdm) VSOFFonly_moves:$(c f_vs.uhdm p.uhdm)"
done

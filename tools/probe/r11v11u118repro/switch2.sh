#!/usr/bin/env bash
# switch audit, final binary: usage switch2.sh <outroot> <pris> <law> <fix2> <arm dir>...
# fix2+R11U118_OFF == pristine; fix2+PSPAREN_OFF+PSRTFULL_OFF == implementer law;
# each switch alone == law with that same switch plus the two verifier switches off.
O=$1; BP=$2; BL=$3; BF=$4; shift 4
run(){ rm -f "$3"; (cd "$1" && env $4 $2 dut.sv --single-unit --nobuiltin -o "$3" >/dev/null 2>&1); }
for a in "$@"; do
  d=$O/$(basename $a); mkdir -p $d
  run $a $BP $d/p.uhdm X=1; run $a $BL $d/l.uhdm X=1; run $a $BF $d/f.uhdm X=1
  run $a $BF $d/f_all.uhdm R11U118_OFF=1
  run $a $BF $d/f_v.uhdm "R11U118_PSPAREN_OFF=1 R11U118_PSRTFULL_OFF=1"
  run $a $BF $d/f_par.uhdm R11U118_PSPAREN_OFF=1
  run $a $BF $d/f_rt.uhdm R11U118_PSRTFULL_OFF=1
  run $a $BF $d/f_ps.uhdm "R11U118_PKGPS_OFF=1 R11U118_PSPAREN_OFF=1 R11U118_PSRTFULL_OFF=1"; run $a $BL $d/l_ps.uhdm R11U118_PKGPS_OFF=1
  run $a $BF $d/f_vs.uhdm "R11U118_PKGVS_OFF=1 R11U118_PSPAREN_OFF=1 R11U118_PSRTFULL_OFF=1"; run $a $BL $d/l_vs.uhdm R11U118_PKGVS_OFF=1
  c(){ cmp -s $d/$1 $d/$2 && echo = || echo X; }
  echo "$(basename $a) lawmoves=$(c p.uhdm l.uhdm) fix2moves_vs_law=$(c l.uhdm f.uhdm) ALLOFF~pris:$(c f_all.uhdm p.uhdm) VOFF~law:$(c f_v.uhdm l.uhdm) PAROFF_moves:$(c f_par.uhdm f.uhdm) RTOFF_moves:$(c f_rt.uhdm f.uhdm) PSOFF~law:$(c f_ps.uhdm l_ps.uhdm) VSOFF~law:$(c f_vs.uhdm l_vs.uhdm)"
done

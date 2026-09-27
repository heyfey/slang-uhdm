#!/bin/bash
# residues.sh <out>: the top-three residues of the four evidence directories (r11u176repro, v11u176repro, r11u178repro,
# r11v178repro), re-measured at 459b7cdf: each named case in both modes with $LAW (every law on, pass 181 on top) and
# with the two landings off (ALLOFF), through case.sh (goldens from the pinned Surelog).  Cases only: fail-closed on
# $FENCED like case.sh.
source /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/env.sh || exit 2
O=$1; T=/tmp/wt_r11u185/tools/probe; export GW=/tmp/r11u185_gres
L="r11u176repro/cases/F3/s08_class_and_outside_module r11u176repro/cases/F3/s13_class_and_other_pkg r11u176repro/cases/PQ/q11_two_modules
r11u176repro/cases/F3/s04_pkgfunc_struct_unpacked r11u176repro/cases/F3/s14_struct_pkgfunc_no_module r11u176repro/cases/PQ/q12_alias
v11u176repro/cases/TT/t9_order_reversed v11u176repro/cases/CM/c20_derived_two_pkgs
r11u178repro/cases/hp/h09_nested_idx r11u178repro/cases/cs/c01_module r11u178repro/cases/cs/c02_class r11u178repro/cases/hp/m07_idx_kinds
r11u178repro/cases/hp/h08_ops_class r11u178repro/cases/pz/z01_typedef_range_unpacked r11u178repro/cases/pz/z02_typedef_range_packed
r11u178repro/cases/pz/z04_localparam_read r11u178repro/cases/pz/z07_typedef_width_expr
r11v178repro/cases/hk/k06_lvalue_kinds r11v178repro/cases/hk/k01_incdec r11v178repro/cases/hx/x05_multidim r11v178repro/cases/hx/x08_genfor"
for c in $L; do for el in 0 1; do
  EL=$el bash /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/case.sh $T/$c on $LAW
  EL=$el bash /tmp/wt_r11u185/tools/probe/r11u185verify/drivers/case.sh $T/$c alloff $LAW R11U175_OFF=1 R11U176_OFF=1 R11U178_OFF=1 R11V178_OFF=1
done; done > $O 2>&1

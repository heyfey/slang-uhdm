#!/bin/bash
# r11u156: the residue cases the live briefs name (pass-145 residues -> r11u147; pass-146 residues, the verifiers'
# faces -> r11u152) through casekeys.sh: each case's cluster ids at 89d599ef (a key the corpus lacks reads NEW:).
# env: SURELOG UHDM_CMP SLANG_UHDM SCX W (ids.json). Run from anywhere; cases are read from the main checkout's tools/probe.
DR=$(cd "$(dirname "$0")" && pwd); P=/home/heyfey/git-repos/slang-uhdm/tools/probe
cd $P
while read pair c; do
  [ -z "$c" ] && continue
  echo -n "$pair "; "$DR/casekeys.sh" "$P/$c" $(echo $c | tr / _) 2>/dev/null | tail -1
done <<'LIST'
A r11u145repro/iaw/q02
A r11u145repro/iaw/q06
A r11u145repro/iaw/ae4
A r11u145repro/usp/u04
A r11u145repro/usp/u08
A r11u145repro/dfi/i01_func_body
A r11u145repro/dfi/i03_static_func
A r11v145repro/lpb/x15_ips_in_compare
A r11v145repro/bso/x06_gen_scope
A r11v145repro/bso/x09_sysfunc_idx_ctl
A r11v145repro/bso/x14_bitsel_in_op
A r11v145repro/bso/x15_call_in_op
A r11v145repro/psb/x11_member_ps
A r11v145repro/psb/x14_modport
A r11v145repro/psb/x17_pkg_param_bound
A r11v145repro/psb/x18_qualified_bound
A r11v145repro/psb/x20_gen_if_proc
A r11v145repro/psb/x23_struct_param_bound
A r11v145repro/uop/x11_pkg_param
A r11v145repro/iaw/x06_paren
A r11v145repro/iaw/x08_cast_init
A r11u153verify/cases/lpb/l02_func_arg
B r11u146repro/grid/fa/f11
B r11u146repro/grid/ig/i11
B r11u146repro/grid/tp/t4_unused
B r11u146repro/grid/tp/t5_iface
B r11u146repro/grid/tp/t7_body_var
B v11u146repro/cases/esc/x2_inst
B v11u146repro/cases/esc/x9_param
B v11u146repro/cases/esc/x4_number
B v11u146repro/cases/tn/k6_iface
B v11u146repro/cases/tn/k9_iface_port
B v11u146repro/cases/tn/k10_iface_ansi
B r11u153verify/cases/tn/j03_gen_local_net
B r11u153verify/cases/tn/j12_genfor_local_net
B r11u153verify/cases/esc/y03_struct_member
B r11u153verify/cases/esc/y14_param_value_after
B r11u153verify/cases/ucp/v02_mixed
B r11u153verify/cases/e2148/g03_logic_var_lhs
B r11u153verify/cases/e148/q05_default_fill_import
LIST

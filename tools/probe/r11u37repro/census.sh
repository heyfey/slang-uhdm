#!/usr/bin/env bash
# r11u37 SOURCE CENSUS + SHAPE LISTER for § typeParamNameMintsDefNet37.
#
# Predicts the mover set BY NAME, a priori, from the two SYNTAX KEYS the law
# reads — before any sweep is run.  A census number alone is unreadable, so the
# SHAPE LISTER beside it prints EVERY candidate site with the reason it fires or
# is gated; a zero here means "no site of this shape", not "the grep missed".
#
#   usage: ./census.sh
#
# POSITIVE CONTROL: the two corpus witnesses (param_type_logic_width's
# `.dtype(logic [$bits(a) + $bits(b) - 1:0])` and packed_struct_array_fifo's
# `parameter type dtype = d_t`) MUST appear in the FIRE lists; if they do not,
# the census is looking in the wrong place and its zeros mean nothing.
set -u
U=${U2R:-$HOME/git-repos/uhdm2rtlil/test}
S=${SURELOG_ROOT:-$HOME/git-repos/Surelog}
BUILTIN='logic|bit|byte|int|integer|shortint|longint|real|shortreal|time|reg|wire|string|chandle|event|void'

echo '=== KEY 1: `(local)parameter type X = <bare NAME>` (a non-builtin, unqualified default) ==='
K1() { grep -rInE '\b(parameter|localparam)[[:space:]]+type[[:space:]]+[A-Za-z_][A-Za-z_0-9]*[[:space:]]*=[[:space:]]*[A-Za-z_][A-Za-z_0-9]*[[:space:]]*[,);]' "$@" \
     --include=*.sv --include=*.v --include=*.svh 2>/dev/null \
   | grep -vE "=[[:space:]]*($BUILTIN)[[:space:]]*[,);]" \
   | grep -vE ':[0-9]+:[[:space:]]*//'; }
echo '-- uhdm2rtlil --';  K1 "$U"  | sed "s#^$U/##"
echo '-- surelog --';     K1 "$S/tests" "$S/third_party/tests" | sed "s#^$S/##"

echo
echo '=== KEY 2: a RANGED type override actual at an instantiation ==='
K2() { grep -rInE '\.[A-Za-z_][A-Za-z_0-9]*[[:space:]]*\([[:space:]]*(logic|bit|reg|byte|int|integer|shortint|longint)[[:space:]]*\[' "$@" \
     --include=*.sv --include=*.v --include=*.svh 2>/dev/null \
   | grep -vE ':[0-9]+:[[:space:]]*//'; }
echo '-- uhdm2rtlil --';  K2 "$U"  | sed "s#^$U/##"
echo '-- surelog --';     K2 "$S/tests" "$S/third_party/tests" | sed "s#^$S/##"

echo
echo '=== SHAPE LISTER — verdict per site ==='
cat <<'VERD'
KEY 1
  FIRE   packed_struct_array_fifo/dut.sv:8  `parameter type dtype = d_t`
           d_t is a COMPILATION-UNIT typedef in the same file -> mints work@packed_struct_array_fifo.d_t
  GATED  type_param_packed_dim/dut.sv:3     `= id_t`      id_t is a TYPE PARAMETER of the SAME header (local scope)
  GATED  type_param_unpacked_port/dut.sv:38 `= base_resp_t` same-header type parameter
  GATED  cva6_equiv/wrappers/*.sv           cva6_equiv carries no dut.sv/dut.v/project.f -> NOT a discovered test
  GATED  tests/ClassTypeParamAlias, Google/.../class_test_53, Ibex/.../riscv_instr_pkg.sv
                                            CLASS holders (lateBinding is commented out at UhdmWriter.cpp:1067);
                                            ClassTypeParamAlias is SLANG_REJECT in both modes anyway
  GATED  Ariane2024/.../acc_dispatcher      `= accelerator_req_t`, a same-header localparam type; and the row is
                                            SLANG_REJECT (default) / NO_DATABASE (testflags) — non-comparable
KEY 2
  FIRE   param_type_logic_width/dut.sv:17   `.dtype(logic [$bits(a) + $bits(b) - 1:0])`
           a is the leftmost-chain leaf and binds; b mints work@shift_reg.b at 17:48
  GATED  type_param_override_elem_sel:32    `.id_t(logic [1:0])`        no identifier in the range
  GATED  TypeParameterAsPortTypeWithLogicAnonymous:12 `.test_parameter(logic[1:0])`  same
  GATED  every `.TagType/.AuxType/.DATA_T/.T(logic [<PARAM>-1:0])` site (ArianeElab, ArianeElab2, ariane,
         Ariane2024, cva6_equiv, dm_csrs, cdc_fifo_tb, axi_riscv_lrsc): the range names only PARAMETERS, which
         reduce to their value before any reference exists (grid arm s5) — and every ariane-family row is
         SURELOG_FAIL / SLANG_REJECT / NO_DATABASE, so none of them is a comparable row
VERD

echo
echo '=== PREDICTED MOVER SET (databases that change bytes) ==='
echo '  uhdm2rtlil: param_type_logic_width x {default,testflags}   -> CMP_NOTEQUAL -> CMP_EQUAL (CONVERSION)'
echo '  uhdm2rtlil: packed_struct_array_fifo x {default,testflags} -> stays CMP_NOTEQUAL (ADVANCE ONLY)'
echo '  surelog   : NONE'
echo
pc1=$(K1 "$U" | grep -c 'packed_struct_array_fifo/dut.sv'; true)
pc2=$(K2 "$U" | grep -c 'param_type_logic_width/dut.sv'; true)
echo "POSITIVE CONTROL: key1 sees packed_struct_array_fifo=$pc1 ; key2 sees param_type_logic_width=$pc2 (both must be >=1)"
[ "$pc1" -ge 1 ] && [ "$pc2" -ge 1 ] && echo 'CENSUS CONTROL: PASS' || { echo 'CENSUS CONTROL: FAIL'; exit 5; }

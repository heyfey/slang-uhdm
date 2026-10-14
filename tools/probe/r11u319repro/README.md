# r11u319 — multi-dimension selects as the whole port actual, system calls in a select's index, the leaf rule on whole-select actuals, and the definition-view generate index builder

Base 0fe8b3bb (pass 317). Ground: module/type (src/ModuleEmit.cpp only). Twelve laws, each behind its own switch
read through src/LawSwitch.h (`lawOn(319, ...)`). `R11U319_OFF` drops all twelve and gives pristine's bytes on 312
of 312 grid case-views. `R11U319_TRACE=<dir>` logs every firing (`lawTrace(319, ...)`). There is no src/R*.h, no
LawState.h section and no getenv; the laws keep no state between emitter calls.

**Target: pass 317's residues 1, 2 and 3.** Every listed case-view of the first two enters STRICT_EQUAL, and so do
four of the third's:

| case-view | pristine | law |
|---|---|---|
| v11u317repro VF/vf09_2d_top_iface `.clk(m[s][1])` (both views, residue 1) | fullname | STRICT_EQUAL 112 / 111 |
| v11u317repro VF/vf07_mod_2d_top `.d(m[s][0])` (both views, residue 1) | fullname | STRICT_EQUAL 102 / 100 |
| v11u317repro VD/vd20_mod_two_dim_cast `.d(m[1'(s)][0])` (both views, residue 1) | fullname | STRICT_EQUAL 117 / 115 |
| v11u317repro VD/vd02_signed_cast_op `ck[signed'(s)] \| ck[1]` (both views, residue 2) | fullname | STRICT_EQUAL 118 / 117 |
| v11u317repro VD/vd23_mod_cast_signed_ctl `.d(ck[signed'(s)])` (both views, residue 2) | fullname | STRICT_EQUAL 102 / 100 |
| v11u317repro VH/vh06_cast_spaces `ck[ 2'(s) ]` in a generate block (both views, residue 3) | stage 1 (52 lines) | STRICT_EQUAL 119 / 137 |
| v11u317repro VA/va11_local_in_sysidx `ck[$unsigned(l)]` in a generate block (both views, residue 3) | stage 1 (38) | STRICT_EQUAL 127 / 154 |
| r11u317repro VR/r16_gen_signed_cast_idx_ctl `ck[signed'(s)]` in a generate block (both views, residue 3) | stage 1 (38) | STRICT_EQUAL 176 / 192 |
| v11u317repro VF/vf05_gen_2d (default view) | stage 1 (31) | STRICT_EQUAL 125 |

Moved without entering: v11u317repro VB/vb11 `ck[$bits(s)]` and vb12 `ck[$clog2(P)]` (both views) go from stage 1
(38 lines) to an endcol head in ExprEmit (a sister-ground face, see the residues); r11u177verify X/x03
`v[P % 4]` goes from 54 to 36 uhdm-cmp lines with its head moved to ExprEmit's fold encoding.

**Gate: no corpus row and no gated probe case changes status, and no gate database moves in bytes.**
- Probe: 4017 EQUAL + 70 STRICT_NOTEQUAL. Regressions 0, conversions 0, changes 0. NO PROBE CONVERSION.
- Surelog: 480 + 0 (default) and 474 + 0 (testflags). uhdm2rtlil: 803/1/67 in both modes. All 0/0/0.
- Downstream: 803/66/2/0, byte-identical to the committed csv.
- byteverify: 0 of 3365 corpus and downstream databases move, and 0 of 4087 probe databases.

## The decode

Surelog compiles a port actual in NetlistElaboration::high_conn_ (CompileExpression), with the instantiating
scope for the leftmost leaf and the parent definition's late binding for everything else (pass 139's rule), and
names nothing below a select: every reference written in a select's index takes its parent chain's name, the
select's full name and its own. Every name below was measured in both views on fresh cases, with goldens from
Surelog using check_probe's arguments.

**1. A multi-dimension select as the whole actual (§ ifaceHcVarSelWholeByInst319, § modConnVarSelWholeNames319).**
The select keeps its chain name `<instance>.<port>.<name>` and everything written in its indices is named through it:
- VS/i01 `.clk(m[s][1])`: golden ref_obj `work@top.u.clk.m.s`, ours `work@top.m.s` (both views);
- VS/m01 `.d(m[s][0])`: golden `work@top.c.d.m.s`;
- VS/i06 `m[k[0]][1]`: bit_select `work@top.u.clk.m.k`; VS/i14 `m[k[s]][t]`: s inside k keeps the outer select's
  name `work@top.u.clk.m.s` (the direct-index rule of § nestSelChainName317v);
- VS/m04 `m[1'(s)][0]`: the cast's ref_typespec `work@top.c.d.m` (§ castTsInIdxNamedByChain317's rule);
- in a generate block VS/m08 `work@top.g.c.d.m.s`.
§ ifaceHcVarSelByInst317 and § modConnIdxNestedNames317 reached a var_select operand only.

**2. A system call in a select's index (§ sysCallInIdxNamedBySel319).** A sys_func_call in an index is compiled like
an index operation: its arguments, at any depth, are named through the select. `signed'(s)` is a `$signed`
sys_func_call in both databases, so it is one:
- SC/i01 `ck[signed'(s)] | ck[1]`: golden `work@top.u.clk.ck.s`, ours `work@top.ck.s`;
- SC/i02 `.clk(ck[signed'(s)])`: golden `work@top.u.ck.s` in both views (the definition view included), ours
  `work@top.u.clk.ck.s` (definition) and `work@top.ck.s` (elaborated);
- SC/m02 `.d(ck[signed'(s)])`: golden `work@top.c.ck.s`, ours `work@top.c.d.ck.s` / `work@top.ck.s`;
- SC/m03 `.d(ck[$signed(s)] & a)`: golden `work@top.c.d.ck.s`, ours `work@top.c.d.s`;
- SC/i15 `ck[k[$unsigned(t)]] | a`: golden `work@top.u.clk.ck.k.t` (through the inner select, as
  § nestSelChainName317v has it for an operation).
The walkers of passes 168, 313, 315 and 317 stopped at the call.

**3. The leftmost-leaf rule on a select that IS the actual (§ ifaceConnSelWholeLeafElab319,
§ modConnSelWholeLeafElab319, § varSelIdxOwnLeaf319).** In the default view golden binds every reference in the
select's index except the leftmost leaf (through binary operations' left operands, a ternary's condition and a
bit-select's index) and a cast's leaf to the parent DEFINITION's logic_net, the object the walk reaches only after
the top modules (`7 logic_net s work@top.s` listed under the reference). Pass 139 and pass 315 ran the rule on
operation, system-call and indexed-part-select actuals only:
- SB/i01 `.clk(ck[1+s])`, i02 `ck[t+s]` (s), i06 `ck[~s]`, i14 `ck[a ? s : t]` (s and t), SC/i04
  `ck[$unsigned(s)]` (a call argument): the definition's net; `ck[s]` and `ck[signed'(s)]` keep the elaborated
  object (a leaf and a cast's leaf, controls SC/i11, SB/i07);
- the module twins SB/m01, m02, m06, m14, SC/m04; a positional connection (a udp-shaped instantiation, no leaf at
  all) SB/m17 `child c (ck[s], o)`, m18, VS/m15.

A multi-dimension select has one leaf PER INDEX, not all of them: SB/i09 `.clk(m[s][1+t])` binds s to the
elaborated net and t to the definition's; i11 `m[~s][t]` binds s to the definition's; i10 `m[1+s][t] & a` (an
operand in the leaf position) binds s to the definition's. § ifaceConnLeafVarSel317 and § modConnLeafVarSel317 kept
the instance's objects in all indices of a leaf-position select (their grid x14 `m[1][s] | a` and x17
`m[s][t] & a` hold leaves only).

**4. A multi-dimension select in a generate block (§ genIfaceVarSelUnbound319).** Golden leaves its index references
unbound like every other reference below an interface actual's top (VS/i08 `.clk(m[s][1])` in a generate block:
ref_obj `work@top.g.u.clk.m.s` with no vpiActual; ours bound the module's net, uhdm-cmp stage 1 with 31 lines;
GV/i02 `m[$signed(s)][1]` through the call). § genIfaceHcInnerRefUnbound313 and § genSysArgInnerUnbound317 did
not enter a var_select.

**5. The definition-view generate index builder (§ defGenSysInIdxLeaf319, § defGenVarSelIdxExpr319,
§ defGenSelIdxCallTrim319, § defGenIdxModPowOp319).** The text-driven builder of emitDefGenStmts (mkIdxTx9, the
select leaf mkOpSelLeaf9, the bare-select branch and the multi-dimension branch) wrote one ref_obj named with the
index text for a shape it lacked, a uhdm-cmp stage-1 difference:
- a system call: SC/i08 `.clk(ck[$signed(s)] | a)` in a generate block, golden sys_func_call `$signed` at
  7:20..7:27 (the name, § sysSignNameSpanSyntax172's rule for `$signed` / `$unsigned`), ref_obj
  `work@top.g.u.clk.ck.s` at 7:28..7:29; `signed'(s)` (SC/i17) spans the whole cast 7:20..7:30; any other call the
  whole call (v11u317repro VB/vb11 `$bits(s)` 7:20..7:28); ours a ref_obj named `$signed(s)`;
- an index of a multi-dimension select that is not a plain name: VS/i13 `.clk(m[1'(s)][0])`, golden operation 67
  at 7:19..7:24 with ref_typespec `work@top.g.u.clk.m` and ref_obj `work@top.g.u.clk.m.s`; GV/i01 `m[s+1][0]`;
  ours a ref_obj named `1'(s)` / `s+1`;
- blanks around a call or cast index: GV/m10 `ck[ $signed( s ) ] | a`, golden bit_select at 7:21..7:33 (the
  trimmed text) and `$signed` at 7:21..7:28; v11u317repro VH/vh06 `ck[ 2'(s) ]`;
- `%` and `**`: GV/i12 `ck[s % 2] | a` operation vpiModOp, GV/i14 `ck[2 ** s] | a` vpiPowerOp; r11u177verify X/x03
  `v[P % 4]`; ours a ref_obj named `s % 2`, or `**` split at its first `*` (r10rgg14repro cells/pc4).

**6. An operation in a module child's select index (§ modConnIdxOpNamedBySel319).** References inside an index
operation of a select operand are named through the select, `<port>.<select>.<name>`, as the interface twin
§ ifaceHcOpSelByInst315 does: GV/m15 `.d(ck[s + 1] | a)` golden `work@top.c.d.ck.s`, ours `work@top.c.d.s`; m16 in a
generate block `work@top.g.c.d.ck.s`; m17 a ternary index. § modConnIdxNestedNames317 named only what sits below a
cast or an inner select. An indexed part select's operation base was already right (GV/m18 control).

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § sysCallInIdxNamedBySel319 | R11U319_SYSIDXNAME_OFF | hcSelIdxRescope168 (definition-view and elaborated module-child bit_select actuals, and interface ones in the definition view); the index walkers of § ifaceHcSelNamedByInst313, § ifaceHcOpSelByInst315 and § ifaceHcIdxSelByInst317; the `nest` walker of § modConnIdxNestedNames317 | a system call in a select's index names everything below it through the select, like an index operation; module children of an instance array stand aside (their prefix is `<parent>..<port>`) |
| § ifaceHcVarSelWholeByInst319 | R11U319_IFVSWHOLE_OFF | ifaceHcSelNamedByInst313 | a var_select that is an interface port's whole actual names its indices through `<instance>.<port>.<name>` (the select's own name is left to its chain); a package-qualified select stands aside |
| § modConnVarSelWholeNames319 | R11U319_MODVSWHOLE_OFF | emitInstance, next to § modConnIdxNestedNames317's call | the same for a module child at module scope and in a generate block (no bind), through modConnIdxNestedNames317; a package-qualified select, an instance-array element and a select whose indices are all constants stand aside |
| § ifaceConnSelWholeLeafElab319 | R11U319_IFSELWHOLELEAF_OFF | the entry gate of § ifaceConnLeftmostLeafElab315 | a bit_select or var_select that is the actual takes the leftmost-leaf rule: non-leaf references bind the parent definition's net |
| § modConnSelWholeLeafElab319 | R11U319_MODSELWHOLELEAF_OFF | the entry gate of § connLeftmostLeafElab139 and a binding-only walker in its place | the module twin; names are left to the select's own writers |
| § varSelIdxOwnLeaf319 | R11U319_VSIDXLEAF_OFF | the leaf computation of § ifaceConnLeftmostLeafElab315 and of walk139 | a var_select in the leaf position has one leaf per index; every other reference in it binds the parent definition's net (refining § ifaceConnLeafVarSel317 and § modConnLeafVarSel317) |
| § genIfaceVarSelUnbound319 | R11U319_GENIFVSUNBIND_OFF | genIfaceHcInnerRefUnbound313 and genSysArgInnerUnbound317 | in a generate block the references in a var_select's indices go unbound too |
| § defGenSysInIdxLeaf319 | R11U319_DEFGENSYSIDX_OFF | emitDefGenStmts: mkIdxTx9 and the bare-select branch | `$name(arg)`, `signed'(arg)` and `unsigned'(arg)` with one argument are a sys_func_call (name span for `$signed` / `$unsigned`, the whole text otherwise), the argument built by the same builder in the same scope |
| § defGenVarSelIdxExpr319 | R11U319_DEFGENVSIDX_OFF | emitDefGenStmts: the multi-dimension select branch | an index that is not a plain name goes through mkIdxTx9 scoped by the select; nested selects and `:` part selects stand aside |
| § defGenSelIdxCallTrim319 | R11U319_DEFGENIDXTRIM_OFF | mkOpSelLeaf9 | blanks around an index that is a call or a cast are trimmed off the select's span and the builder's text |
| § defGenIdxModPowOp319 | R11U319_DEFGENMODPOW_OFF | mkIdxTx9 and the bare-select branch | `%` is vpiModOp where no `- + * /` matched first; `**` alone with no other operator is vpiPowerOp |
| § modConnIdxOpNamedBySel319 | R11U319_MODIDXOP_OFF | the `nest` walker of § modConnIdxNestedNames317 | an operation in a module child's select index names its references through the select; instance-array children stand aside |

Name writes in the naming laws are unconditional (reading a stored name first would make UHDM's getter store the
computed one), so the census traces every visit.

## Binaries

| binary | md5 |
|---|---|
| pristine (0fe8b3bb, -j 2) | 3d29c848e262fecd0cbdc507d4d05c38 (equal to the main tree's build/slang-uhdm) |
| law (the delivered patch) | a2c33775a34dbd17110c5c24ab03a29e |
| uhdm-strictcmp / strictcmp_x (drivers/cc_x.sh) | fa6e4f42f252ae0ab69d9845003e71c5 / 886f030233ecdbcce7d0e29ac0c4df2c |

Both slang-uhdm binaries link slang 12.0.0+545f88b2e. Both were frozen (chmod 555) before the measurements below.

## Grid (156 case dirs in GV, GX, SB, SC, VS; both views)

The evidence is in evidence/grid.txt and gridsum.txt. drivers/grid.sh runs each case-view on P, L and OFF
(`R11U319_OFF`), and on L with each switch off; drivers/gridsum319.py summarises.

**Overall:**
- All 4680 lines carry `rc=`, and every line is rc=0.
- 312 case-views: 269 moving, 239 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- OFF equals pristine on 312 of 312.
- uhdm-cmp line counts grow on 2 case-views, GV/m19_gen_vs_ips_ctl in both views (54 to 58): the old head, the
  definition-view `rd[s+1][o -: 4]` index `s+1` written as a ref_obj named `s+1`, is cleared; the new head is
  later in the walk, the `o -: 4` indexed part select the multi-dimension branch does not build (residue 3). Its
  away census reads 0.

**Attribution:**
- Restored by one switch alone: SYSIDXNAME 72, IFVSWHOLE 33, MODVSWHOLE 30, MODSELWHOLELEAF 16, DEFGENMODPOW 10,
  MODIDXOP 6, DEFGENSYSIDX 4, IFSELWHOLELEAF 4, VSIDXLEAF 3.
- The other 91 movers need two or more switches (gridsum.txt lists them); every switch has an effect alone:
  SYSIDXNAME 138, IFVSWHOLE 54, MODVSWHOLE 50, DEFGENSYSIDX 42, MODSELWHOLELEAF 36, DEFGENVSIDX 18, VSIDXLEAF 18,
  IFSELWHOLELEAF 14, DEFGENMODPOW 12, GENIFVSUNBIND 9, MODIDXOP 8, DEFGENIDXTRIM 4.

**Away census** (drivers/awaycv.sh, order-blind and chain-keyed, drivers/awaysum.py):
- all 269 movers: lost 0, chain away 0, flat away 0, with 553 records toward golden (evidence/away_grid.txt).
- Positive control, binaries swapped on 12 entering movers (evidence/away_poscontrol.txt): 12 of 12 read away
  (lost 16, chain away 24).

**Downstream on all 156 dirs** (drivers/dscases.py; evidence/downstream_cases_P.txt and _L.txt): no verdict moves.
155 are IDENTICAL on both binaries, and GX/x08_iface_array_vs is EQUIVALENT on both.

| law | cases (first line names the law) |
|---|---|
| § sysCallInIdxNamedBySel319 | SC/i01 to i07, i09, i10, i14 to i16 and the module twins m01 to m07, m09, m10, m14 to m16; SB/i03, i04, i07, i08, i12, i13, i16 and m03, m04, m07, m08, m12, m13, m16; VS/i09, i11, m09, m11; GX/x02_program_sys_idx, x11_sys_countones_idx, x16_vs_operand_sys_gen; controls SC/i11, i12, m11, m12, GX/x12_sys_clog2_const_ctl, x22_inst_array_sys_idx_ctl |
| § ifaceHcVarSelWholeByInst319 | VS/i01 to i06, i10, i14, i15_vs_positional; GX/x04_casegen_iface_vs, x05_crlf_vs_whole (CRLF), x06_macro_vs_idx, x13_iface_two_ports_vs, x14_vs_three_dims; controls VS/i07_vs_const_ctl, i12_vs_unary, i16_vs_pkg_qual_ctl, GX/x08_iface_array_vs, x10_param_idx_vs |
| § modConnVarSelWholeNames319 | VS/m01 to m06, m08, m10, m14, m15_vs_positional; GX/x01_program_vs_whole, x03_forgen_vs_genvar, x07_two_level_mid, x15_vs_unpacked; controls VS/m07_vs_const_ctl, m12_vs_unary, m16_vs_pkg_qual_ctl, GX/x09_inst_array_vs |
| § ifaceConnSelWholeLeafElab319 | SB/i01_bitsel_const_plus_ref, i02_bitsel_two_refs, i06_bitsel_unary_idx, i14_bitsel_tern_idx; controls i15_bitsel_right_operand, GX/x19_iface_bitsel_nested_bitsel_idx |
| § modConnSelWholeLeafElab319 | SB/m01, m02, m06, m14, m17_bitsel_positional, m18_bitsel_positional_op, m19_bitsel_positional_cast; GX/x17_bitsel_tern_cond_leaf; controls SB/m15, GX/x18_bitsel_nested_bitsel_idx, x20_bitsel_param_plus_ref |
| § varSelIdxOwnLeaf319 | SB/i05_vs_sys_second, i09_vs_second_op_idx, i10_vs_first_op_idx_operand, i11_vs_unary_idx and the module twins m05, m09, m10, m11 |
| § genIfaceVarSelUnbound319 | VS/i08_vs_gen_ref |
| § defGenSysInIdxLeaf319 | SC/i08_sys_gen_op, i13_gen_sys_top, i17_gen_signed_cast_top, m08, m13, m17; GV/i06, i08, i09, m06, m08, m09; GV/i07_gen_bitsel_bits and m07 (`$bits`, moved to an ExprEmit endcol head); controls GV/i11 and m11 (`$countbits(s, 1'b1)`, two arguments: the builder declines) |
| § defGenVarSelIdxExpr319 | GV/i01 to i03, m01 to m03; VS/i13_vs_gen_cast, m13; controls GV/i04, m04 (a nested select), i05, m05 (plain names), m19_gen_vs_ips_ctl (a part select) |
| § defGenSelIdxCallTrim319 | GV/i10_gen_bitsel_sys_spaces, m10 |
| § defGenIdxModPowOp319 | GV/i12_gen_modop_operand, i13_gen_modop_top, i14_gen_pow_operand, m12, m13, m14_forgen_modop_param (moved, the next head ExprEmit's) |
| § modConnIdxOpNamedBySel319 | GV/m15_mod_idx_op_operand, m16_gen_mod_idx_op_operand, m17_mod_idx_tern_operand; controls m18_mod_ips_opbase_ctl, GX/x21_inst_array_idx_op_ctl |

## Controls

**Firing scan** (drivers/firescan.sh with the law binary; evidence/firing_law.txt, firing_scan_count.txt):
- 28413 fence-filtered tools/probe dirs. 213 fire: 140 of this pass and 73 earlier dirs.
- 404 nonzero exits (249 exit 3, 154 exit 4, one exit 139 v11u112repro/grid/brk2/k/m07_hdr_enum_default). Each is
  equal on pristine (evidence/rc_law_nonzero.txt, rc_pristine_nonzero.txt).

**The 73 earlier firing dirs and the 6 that fired only on a superseded freeze, both views**
(evidence/controls_firing.txt, controls_firing_sum.txt):
- 158 case-views, 62 moving, 29 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- Entering: pass 317's residues above; r11u313repro GP/p40_bitsel_nestedop_modlevel (default, depth); r11u168repro
  H/h15 and h16 (default, depth); r11u177verify H/h03_two_dim_elem and h08_packed2d_elem_bit (both views);
  r11u147repro pos/n5_pos_var_idx; r11v147repro brk/pos/w7_first_var_idx_mod; v11u168repro H/x05, x06, x11.
- Growing: r10rgg14repro/cells/pc4 in both views, 54 to 140 uhdm-cmp lines. The old head is the first instance's
  `arr[i % 3]` (ua: golden operation 13 at 11:22..11:27, ours a ref_obj named `i % 3`) and the second's
  `arr[2 ** i]` is cleared too; the new head is later in the walk, the third instance's `arr[(i == 0) ? 4 : 5]`
  (uc), a ternary the builder has no branch for.
- Away census on all 62 movers (evidence/away_controls.txt): lost 0, chain away 0, flat away 0, with 109 records
  toward golden.

**Neighbour repro dirs** (r11u139netbind, r11u168repro, r11u193repro, v11u193repro, r11u307 to r11u317 and v11u307
to v11u317; evidence/controls_nb_sum.txt): 2636 case-views, 32 moving, 20 entering, 0 leaving. No exit-code
change. Every mover is in the firing list.

**Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131 and r11v131;
evidence/controls_std_sum.txt): 1440 case-views, 0 moving.

## Firing census and gates (evidence/predict.txt, predict_poscontrol.txt, gates.txt, byteverify_corp.txt, det.txt)

**Firing census** (drivers/tracecensus.sh, frozen before the law sweep; the law binary under R11U319_TRACE over the
probe and both corpora in both modes, filtered by $FENCED): it names NO database. Its positive control is the same
machinery on the previous freeze (361d0bdc), where § modConnVarSelWholeNames319 still rewrote the name of a select
whose indices are all constants: it named Earlgrey_0_1 d/t, Rggen d, VarSelectGenStmt d/t and the uhdm2rtlil
NestedGenscopesInModuleWithMultidimensionalPorts, NestedSelectOnInputPortInGenscope and NestedSelectOnVarInGenscope
d/t, and that freeze's sweep moved exactly those 11 row-modes and their 3 downstream twins in bytes with identical
dumps (evidence/byteverify_361d.txt). The law now stands aside there.

**Sweeps.** tests/sweep.sh --jobs 3 ran on pristine and on the law, from this worktree, with workdirs of equal length
(/tmp/r11u319_swP, /tmp/r11u319_swL).
- Both read the gate numbers above, and both exit 1 on the law-index check alone (the index is regenerated in the
  patch).
- The csv row diff between law and pristine is 0 lines in probe, surelog, uhdm2rtlil and downstream; the downstream
  csv equals the committed one.

**byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors with 8 fenced
paths skipped):
- 0 of 3365 corpus and downstream databases move. SELFCHECK flags 3363 of 3365 (the known 1DUnpackedArray twin).
- 0 of 4087 probe databases move (md5 of every fence-filtered database).

**Canaries:** surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.

**Binary audit:** each sweep has 3315 fence-filtered cmds.txt. 3265 name that sweep's own binary, and 0 name the
other binary or the main tree's.

**Determinism** (drivers/det.sh, three concurrent draws of the law): one hash per row-mode on Earlgrey_0_1, MiniAmiq,
SeqDriver, SimpleUVM and BuildUVMPkg in both modes, and on Scoreboard and Rggen default, each equal to the law
sweep's (Scoreboard and Rggen testflags write no database).

## Residues (ranked; all wrong on pristine too, none moved away)

1. **Instance-array children** (GX/x09_inst_array_vs, x21, x22: `child c [2] (.d(m[s][1]))`, `(ck[s + 1] | a)`,
   `(ck[$signed(s)] | a)`): golden names through the element, `work@top.c[0].d.m.s`, where the emitInstance prefix
   of an element is `work@top..d` (pass 139's residue, v11u317repro VG/vg06); the laws stand aside, and the head is
   a binding at stage 1 on both binaries. ModuleEmit emitInstance.
2. **The definition-view index builder's remaining shapes** (ModuleEmit emitDefGenStmts): a nested select in a
   multi-dimension select (GV/i04, m04: the bracket groups are split on the first `]`), a part select in its last
   index (GV/m19, v11u287repro VD/vd06), a ternary index (r10rgg14repro pc4's uc), a two-argument call (GV/i11,
   m11), and pass 317's vh21 `W'(s)`, vh09 (a macro-born index), vh02 / vh01 and VR/r10.
3. **Folds Surelog makes in an index** (stage 1 on both binaries): a parameter index (GX/x10 `m[P][s]`, x20
   `ck[P+s]`), `$clog2(4)` (x12), `$size(ck)` folded by TypeEmit emitSyntaxExpr where golden keeps the call
   (v11u317repro VB/vb13).
4. **A package-qualified select as the whole actual** (VS/i16, m16 `mask_pkg::PA[s][0]`): golden names s
   `work@top.u.i.mask_pkg::PA.s` in the elaborated view and `mask_pkg::PA::mask_pkg::PA::s` in the definition view,
   where the law stands aside (the select itself stores no name in golden, r11u118repro p36 / p37).
5. **An interface array fed a multi-dimension select** (GX/x08, stage 1 at the module_array head, pass 317's VR/r06
   family).
6. **Pass 317's other residues** stand as its READMEs list them: vg06, va09, vd09, vd06, vd17, vd21, r06, m20, the
   bind naming and vg11, and pass 315's and 313's faces.

**Sister-ground faces (ExprEmit; reported, not written):**
- the folded `$bits(s)` / `$clog2(P)` in an elaborated select index ends at the call's name where golden spans the
  whole call (v11u317repro VB/vb11 constant 7:20..7:25, golden 7:20..7:28; vb12; r11u319repro GV/i07, m07), the
  fold site of § genvarIdxFoldRerender14's family;
- the folded `P % 4` / `c % 2` in an elaborated index is `UINT:1` with const type 9 where golden writes `INT:1` with
  const type 7 (r11u177verify X/x03, r11u319repro GV/m14), the same fold site;
- pass 317's vd01 (`ck[W'(s)]`, the parameter-width cast typespec, pass 315's vk07).

## Process

- **Drafts and superseded freezes.** Only the last law binary is measured above.
  - An unfrozen draft (a751073f) broke r11u118repro p36 / p37 (a package-qualified select given a full name where
    golden stores none, leaving STRICT_EQUAL) and wrote a ref_obj named `: 4` in v11u287repro VD/vd06 (54 to 58
    lines). The draft firing scan's controls found both; the `::` and `:` abstentions fixed them before any freeze.
  - The first freeze (7542324) moved GX/x09 two records away (the instance-array prefix), found by the grid's away
    census: the instance-array abstentions. Its firing census was stopped through its own process group, after this
    pass's name was checked on its command line.
  - The second freeze (361d0bdc) ran the census and the law sweep: 11 corpus row-modes and 3 downstream twins moved in
    bytes with identical dumps, as its census predicted (the rewrite of an all-constant select's own name): the
    all-constant abstention. The third freeze (a2c33775) is the delivered law.
- **Drafts not delivered.** A first § defGenSysInIdxLeaf319 gave every call the name span (vb11 read the name where
  golden spans `$bits(s)`); its comma check let `$countbits(s, 1'b1)` through as one argument; `**` was first tried
  after the single-character operators. All fixed before the first freeze.
- **Fence.** Every helper reads $FENCED fail-closed (drivers/env.sh). Every tree scan built its path list and filtered
  it before opening a file. The census ran with filters built from $FENCED. Every dump went through a guard on the
  tool variable. Nothing was written outside /tmp/wt_r11u319 and /tmp/r11u319_*. No process of another agent was
  listed or touched.

## Drivers

Copied from r11u317repro/drivers (env.sh, case.sh, grid.sh, awaycv.sh, away.py, awaychain.py, awaydump.py,
awayrows.py, awaycorp.sh, bvmirror.sh, controls.sh, ctlsum.py, det.sh, dscases.py, firescan.sh, tracecensus.sh,
gsum.py, gridsum317.py, recpath.py, cc_x.sh, strictcmp_x.cpp, objinfo.cpp), switched to pass 319's switches and
trace variable; new: gridsum319.py (the grid summary and attribution) and awaysum.py (the away census totals).

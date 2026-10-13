# r11u315 — operand selects, call arguments, leaf binding and casts of interface port actuals; ternary and system-call actuals in definition-view generate blocks

Base 494dcae5 (pass 313). Ground: module/type (src/ModuleEmit.cpp only). Six laws, each behind its own switch read
through src/LawSwitch.h (`lawOn(315, ...)`); `R11U315_OFF` drops all six and gives pristine's bytes on 176 of 176
grid case-views; `R11U315_TRACE=<dir>` logs every firing (`lawTrace(315, ...)`), and every trace marks a byte change.
No src/R*.h, no LawState.h section, no getenv; the laws keep no state between emitter calls.

**Target: the brief's first item** (pass 313's residue 1, the verifier's vg44 / vg46 / vg02) and pass 313's residue 1
(the third logic_net) and residue 4 (the ternary actual's definition-view ref_obj, p49). All enter STRICT_EQUAL:

| case-view (earlier pass) | pristine | law |
|---|---|---|
| v11u313repro VG/vg44_bind_into_gen_iface_mod (both views) | fullname | STRICT_EQUAL 172 / 183 |
| v11u313repro VG/vg46_nested_iface_in_gen_iface_in_gen (both views) | fullname | STRICT_EQUAL 137 / 197 |
| v11u313repro VG/vg02_syscall_gen (both views) | stage 1 (38 lines) | STRICT_EQUAL 142 / 161 |
| r11u313repro GP/p37, p45, p46, p47 (default view) | depth | STRICT_EQUAL 181, 181, 163, 149 |
| v11u313repro VM/vm03, vm04, vm25, vm27, vm40, VG/vg18 (default view) | depth | STRICT_EQUAL |
| r11u313repro GP/p49_ternary_ifgen (both views) | stage 1 (62 lines) | STRICT_EQUAL 170 / 189 |

**Gate: no corpus row and no gated probe case changes status, and no gate database moves in bytes.**
- Probe: 4017 EQUAL + 70 STRICT_NOTEQUAL; regressions 0, conversions 0, changes 0.
- Surelog: 480 + 0 / 474 + 0. uhdm2rtlil: 803/1/67 in both modes. All 0/0/0.
- Downstream: 803/66/2/0, byte-identical to the committed csv.
- The csv row diff between the law and pristine sweeps is 0 lines in probe, surelog, uhdm2rtlil and downstream.
- byteverify: 0 of 3365 corpus and downstream databases, 0 of 4087 probe databases move, as the firing census
  predicted (it names no gate database).

## The decode

Surelog compiles an interface instance's named port actual in NetlistElaboration::high_conn_
(`compileExpression(parent_comp, fC, Expression, ..., Reduce::Yes, nullptr, parent)`), with no parent expression and
the PARENT instance, and the port's parent chain names what the compile leaves unnamed. Four consequences, each
measured in both views on fresh cases (goldens from Surelog with check_probe's arguments):

**1. Every select operand is named through the interface port.** Pass 313 named the actual's own select and the
reference operands of an operation actual. Golden names a select inside an operation (a concatenation, unary or
ternary operation included) the same way, and the references in its index after it:
- `.clk(ck[0] ^ ck[1])`: bit_select `work@top.u.clk.ck` (OS/o01; in a generate block `work@top.g.u.clk.ck`, o02);
- `.clk(ck[s] & a)`: index `s` is `work@top.u.clk.s` (o03); `.clk(a | ck[s+1])`: `work@top.u.clk.ck.s` (o05);
- `.clk(|ck[s+:2])`: indexed part select `work@top.u.clk.ck`, base `work@top.u.clk.s` (o11);
- an indexed part select that IS the actual with an operation base, `ck[s+1 +: 1]`: `work@top.u.clk.ck.s`
  (v11u313repro VM/vm29); ours named all of these through the instantiating scope (`work@top.ck`).

**2. A system call's arguments follow the same rule.** `.clk($signed(a))` names `work@top.u.clk.a` (o06), and
`$signed(ck[1])` the select `work@top.u.clk.ck` (o14). Inside a generate block the references in a system call's
arguments stay unbound (DG/d02, OS/o07: `ref_obj work@top.g.u.clk.a` with no vpiActual), the twin of pass 313's
§ genIfaceHcInnerRefUnbound313, whose walker stops at the call.

**3. Which net a reference names: the leftmost leaf rule of § connLeftmostLeafElab139.** This is pass 313's
"third logic_net": golden's walk reaches a logic_net of the operand's name that is not yet walked, because it is the
parent DEFINITION's net (the definitions are walked after uhdmtopModules), not a third object. The one leaf reached
through left operands, a ternary's condition and a bit-select's index resolves in the parent instance's netlist;
every other reference goes to the parent definition's late binding:
- `a & b & c` binds b and c to the definition (TN/t01), `a & (b & c)` likewise (t02), `a ? b : c` b and c (t04),
  `a & a` the second a (t05);
- a concatenation, a unary operation, a system call's argument and an indexed part select's base have no leaf, so
  every reference goes to the definition (t03, t08, o06, o11, r11u313repro GP/p37);
- a cast's leaf keeps the instance's object, as § castOperandLeafElab193 has it (r11u193repro CL/s12
  `.d(7'(r))`, TN/t16 `a & 1'(b)`, t17 `1'(a | b)` binding a to the instance and b to the definition, t19
  `signed'(a) & b`).
In the default view only the definition object is new to the walk; the elaborated view's walk already reads equal.

**4. Nothing names a cast's typespec reference.** Its full name is the parent chain's, `<instance>.<port>`
(TN/t15 `.clk(1'(a))` `work@top.u.clk`, t18 in a generate block `work@top.g.u.clk`), the interface twin of
§ connCastTsNamedByPort193; ours carried the instantiating scope's path.

**5. Definition-view generate blocks: a conditional and a system-call actual.** The ref_module port loop of
emitDefGenStmts had branches for identifiers, selects, operators, calls, literals, concatenations, replications and
casts. A conditional (`.clk(s ? a : b)`) and a system call (`.clk($signed(a))`) fell to the final else, one ref_obj
named with the actual's text (`work@top.g.u.clk.$signed(a)`). Golden writes operation 32 over the condition and the
branches, and the sys_func_call, with the references scoped through the formal and a select operand or argument in
the select-leaf shape the operator branch already builds (the bit_select at its index span):
- DG/d01 `work@top.g.u.clk.s`, d02 `sys_func_call $signed` with `work@top.g.u.clk.a`;
- d05 `s ? ck[0] : ck[1]`: bit_select `work@top.g.c.clk.ck` at the index (pristine wrote a var_select named `s ? ck`);
- d06 `$unsigned(a[i])`: the bit_select at its index; VC/c06 `$signed($unsigned(a))` nests.
Module and interface children alike, in if, else, case and for (one and two levels) generate blocks.

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § ifaceHcOpSelByInst315 | R11U315_OPSEL_OFF | emitInterfaceInstance port loop, after § ifaceHcSelNamedByInst313 (helper `ifaceHcOpSelByInst315`) | in an operation actual (and an indexed part select that is the actual) every bit_select and indexed part select is named `<instance>.<port>.<name>`; a reference written directly as its index or base `<instance>.<port>.<name>`, one inside an index operation `<instance>.<port>.<select>.<name>` |
| § ifaceHcCallArgByInst315 | R11U315_CALLARG_OFF | the same helper | a system call's arguments, at the actual's top or under an operation, are named the same way (references and selects) |
| § ifaceConnLeftmostLeafElab315 | R11U315_IFLEAFDEF_OFF | the same place (helper `ifaceConnLeftmostLeafElab315`) | at module scope (not in a generate block, not udp-shaped), every reference of an operation, system-call or indexed-part-select actual except the leftmost leaf and a cast's leaf binds the parent definition's net (only where the elaborated net has a distinct definition twin) |
| § ifaceConnCastTsNamedByPort315 | R11U315_CASTTSNAME_OFF | the same place | every cast's typespec reference in the actual is named `<instance>.<port>`, module scope and generate blocks |
| § genIfaceHcCallArgUnbound315 | R11U315_GENCALLUNBIND_OFF | the same place, before § genIfaceHcInnerRefUnbound313 | in a generate block a reference that is a system call's argument (at the top or under an operation or select index) loses its binding |
| § genConnTernSysActual315 | R11U315_DEFGENTERNSYS_OFF | emitDefGenStmts' ref_module port loop: the operator branch (`mkConnOpTree9` takes a conditional) and a new system-call branch after it | a conditional actual is operation 32 over condition and branches built by the operator branch's tree; a system-call actual is the syntax emitter's sys_func_call scoped through the formal, each argument rebuilt by the operator tree, the select leaf or (nested) the same branch |

User function calls (`.clk(f(a))`) are left alone: golden adds a ref_typespec to the argument at module level and
inside a generate block lists `f` as a gen_scope net (a Surelog defect); both stay at stage 1 (OS/o08, o09, o18).

## Binaries

| binary | md5 |
|---|---|
| pristine (494dcae5, -j 2) | 38e604258c7254491e9b6cb732d66e36 (equal to the main tree's build/slang-uhdm) |
| law (the delivered patch) | 233af0ffdaf0de9473fe59f45504cd3e |
| uhdm-strictcmp | fa6e4f42f252ae0ab69d9845003e71c5 |
| strictcmp_x (drivers/cc_x.sh) | 886f030233ecdbcce7d0e29ac0c4df2c |

Both slang-uhdm binaries link slang 12.0.0+545f88b2e. Both were frozen (chmod 555) before any measurement.

## Grid (88 case dirs in OS, TN, DG, VA, VC; both views; evidence/grid.txt, gridsum.txt)

drivers/grid.sh runs each case-view on P, L, OFF (`R11U315_OFF`) and on L with each switch off. All 1584 lines carry
`rc=`, and every line is rc=0.

**Overall:**
- 176 case-views, 122 moving, 117 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- OFF equals pristine on 176 of 176.
- Restored by one switch alone: DEFGENTERNSYS 34, OPSEL 31, IFLEAFDEF 20, CASTTSNAME 9, CALLARG 7. The other 21
  movers need two or more (a select operand moving both its name and its index's binding; GENCALLUNBIND always acts
  with CALLARG on a generate-block system call).
- Away census (drivers/awaycv.sh, order-blind and chain-keyed; evidence/away_grid.txt), all 122 movers: lost 0,
  chain away 0, flat away 0, with 369 records toward golden.
- The positive control, with the binaries swapped on 12 entering movers, reads chain away > 0 on 12 of 12
  (evidence/away_poscontrol.txt).
- uhdm-cmp line counts: 46 case-views move from stage 1 to 0 lines (DG, VC, a20 to a22, o07, c08); none grows.

**Downstream on all 88 dirs** (drivers/dscases.py; evidence/downstream_cases_P.txt and _L.txt): no verdict moves on
either binary. 83 IDENTICAL; OS/o08, o09, o18 and VA/a02 EQUIVALENT and VA/a04 DIVERGENT on both.

| group | cases (first line names the law) |
|---|---|
| OS, § ifaceHcOpSelByInst315 | o01_xor_bitsel_mod, o02_xor_bitsel_gen, o03_bitsel_refidx_mod, o04_bitsel_refidx_gen, o05_bitsel_opidx_mod, o11_ipsel_op_mod, o12_unary_bitsel_mod, o13_unary_bitsel_gen, o15_nested_op_bitsel_mod, o16_concat_bitsel_mod, o17_xor_bitsel_forgen, o19_ternary_bitsel_mod; controls o10_partsel_op_mod (a part_select, named by the chain, unmoved), o08_funccall_mod, o09_funccall_gen, o18_funccall_bitsel_mod (user calls, the law abstains), o20_member_op_mod (a struct member, stage 1) |
| OS, § ifaceHcCallArgByInst315 | o06_syscall_mod, o07_syscall_gen, o14_syscall_bitsel_mod |
| TN, § ifaceConnLeftmostLeafElab315 | t01_and3, t02_and_nested_right, t03_concat3, t04_ternary, t05_same_twice, t06_two_insts, t07_two_insts_shared, t08_unary, t09_bitsel_ref_last, t11_net_decl_used, t12_var_operand, t13_two_ports, t16_cast_operand, t17_cast_op_inside, t19_signed_cast; controls t10_bitsel_refidx_top (a top-level bit_select's index is the leaf), t14_mod_child_ctl (a module child, § connLeftmostLeafElab139's ground) |
| TN, § ifaceConnCastTsNamedByPort315 | t15_cast_whole, t18_cast_gen, t20_cast_typedef |
| DG, § genConnTernSysActual315 | d01_tern_iface_gen, d03_tern_mod_gen, d04_sys_mod_gen, d05_tern_bitsel_mod_gen, d06_sys_forgen, d07_tern_forgen_iface, d08_sys_two_args_gen (control: a binary operation over a call, the operator branch, unmoved) |
| DG, § genIfaceHcCallArgUnbound315 | d02_sys_iface_gen |
| VA, § ifaceConnLeftmostLeafElab315 | a01_positional, a02_iface_array, a03_bind, a04_iface_in_iface, a05_two_parents, a06_param_iface, a09_param_operand, a10_implicit_nets, a14_ternary_ops, a19_var_bitsel_operand; controls a15_ctl_whole_name, a16_const_only |
| VA, § ifaceHcOpSelByInst315 | a07_hier_operand, a08_partsel_operand (control, unmoved), a12_macro_actual, a13_crlf (a CRLF file), a17_unbased_ops_gen_twolevel, a18_iface_body_gen |
| VA, § ifaceHcCallArgByInst315 | a11_sys_two_ops |
| VA, § genIfaceHcCallArgUnbound315 | a20_sys_in_op_gen, a21_sys_gen_for, a22_sys_two_args_gen |
| VC, § genConnTernSysActual315 | c01_nested_tern_mod, c02_tern_ops_mod, c03_tern_const_mod, c04_tern_genvar_forgen, c05_sys_op_arg, c06_sys_nested, c07_tern_positional (control: an ordered connection, unmoved), c08_tern_hier, c09_tern_else_gen, c10_tern_case_gen, c11_sys_bits, c12_sys_signed_bitsel_iface, c13_tern_in_iface_body_gen, c14_tern_two_level_for (control, equal on both), c15_tern_partsel_cond, c16_tern_macro, c17_mod_level_tern_ctl (control: module scope, unmoved), c18_sys_crlf (a CRLF file) |

Entering STRICT_EQUAL in both views (50 dirs): d01 to d07, o01 to o07, o11 to o17, o19, t09, t15 to t20, a11 to
a13, a17 to a22, c01 to c06, c09, c10, c12, c13, c15 and c18. Default view only, the elaborated view being equal on
both binaries (17 dirs): t01 to t08, t11 to t13, a01, a05, a06, a07, a10 and a14.

Moving without entering (all toward golden, chain away 0): a03_bind (a bound module's interface: a definition
binding gained, the bind naming of vg16 left), a04_iface_in_iface and a09_param_operand (stage 1 on both, one
record toward), c08_tern_hier (stage 1 -> fullname, 98 -> 0 uhdm-cmp lines).

## Controls

**Firing scan** (drivers/firescan.sh with the law binary; evidence/firing_law.txt):
- 27498 fence-filtered tools/probe dirs. 103 fire: 71 of this pass and 32 earlier dirs.
- 404 nonzero exits (249 exit 3, 154 exit 4, one exit 139 v11u112repro/grid/brk2/k/m07_hdr_enum_default), every one
  equal on pristine (evidence/rc_law_nonzero.txt).

**The 32 earlier firing dirs in both views** (evidence/controls_firing.txt, controls_firing_sum.txt,
away_controls.txt):
- 64 case-views, 52 moving, 44 entering STRICT_EQUAL, 0 leaving. No exit-code change; 8 uhdm-cmp line counts change,
  all stage 1 -> 0 lines (p49, s08, vg02, vg23 in both views).
- Away census on all 52 movers: lost 0, chain away 0, flat away 0, with 119 records toward golden.
- Entering outside pass 313's dirs: r11u193repro CL/s12 (both views; the cast leaf and the cast typespec name) and
  v11u239repro OS/s08 (both views; a definition-view generate ternary).
- Entering in pass 313's dirs: r11u313repro GP/p37, p45, p46, p47 (default), p49 (both); v11u313repro VG/vg02 (both),
  vg06, vg09 (both), vg16 (both), vg18, vg20, vg23 (both), vg33 (both), vg41 (both), vg44 (both), vg46 (both),
  VM/vm03, vm04, vm05 (both), vm07 (both), vm14 (both), vm25, vm26 (both), vm27, vm29 (both), vm40.
- Moving without entering: r11u199verify C/c04_iface_bind (both views, the cast typespec name; the bind's own
  actual left), r11u217verify PD/p06 and p07, v11u209repro IM/v16 (stage 1 on both).

**Neighbour repro dirs** (r11u139netbind, r11u193repro, v11u193repro, r11u307 to r11u313 and v11u307 to v11u313;
evidence/controls_nb_sum.txt): 1670 case-views, 44 moving (all in the firing list above), 42 entering, 0 leaving, no
exit-code change. § connLeftmostLeafElab139's grid (r11u139netbind) moves 0.

**Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131 and r11v131;
evidence/controls_std_sum.txt): 1440 case-views, 0 moving.

## Firing census and gates (evidence/predict.txt, det.txt, byteverify_corp.txt)

**Firing census** (drivers/tracecensus.sh, frozen before the law sweep; the law binary under R11U315_TRACE over the
probe and both corpora in both modes, filtered by $FENCED): no trace line anywhere, so no gate database is predicted
to move. Positive control: the same harness run with R11U313_TRACE set beside R11U315_TRACE on r10rgg16repro cells/g1
and r10vrgg16repro cells/v8 writes pass 313's GENIFBIRTH and GENIFCONN lines (the harness passes the environment
through) and no pass 315 line; the 103 firing tools/probe dirs show the trace itself writes.

**Sweeps.** tests/sweep.sh --jobs 3 ran on pristine and on the law, from this worktree, with workdirs of equal length
(/tmp/r11u315_swP, /tmp/r11u315_swL). Both read the gate numbers above; both exit 1 on the law-index check alone
(the index is regenerated in the patch).

**byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered mirrors with 8 fenced paths
skipped): 0 of 3365 corpus and downstream databases move; SELFCHECK flags 3363 of 3365 (the known
downstream/1DUnpackedArray twin). The probe: 0 of 4087 databases move (md5 of every fence-filtered database).

**Canaries:** surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.

**Binary audit:** each sweep has 3323 cmds.txt; 3273 name that sweep's own binary, 0 name the other binary or the
main tree's, and 50 run no slang.

**Determinism** (drivers/det.sh, three concurrent draws with the law binary): one hash per row-mode on Earlgrey_0_1,
MiniAmiq, SeqDriver, SimpleUVM, Scoreboard and BuildUVMPkg in both modes and Rggen default, each equal to the law
sweep's.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **Pass 313's standing module/type faces** not reached here: the definition-view generate net declaration
   `wire lclk = clk;` (GP/p06), the struct-member actual's ref_typespec and vpiExpr (p26, p27, q19, OS/o20), the
   module-level interface array's definition-view module_array (p15, p25, VA/a02), the parameter index golden folds
   (p34, p36), two instances in one statement (p35, q11; a Surelog defect), q14, q06, q01, q13, p11, and the stage-1
   hierarchical shapes vg26, vm32, vg42, vg43, vm43, vm44 and vm42.
2. **The bind naming** (VA/a03, v11u313repro vg16 family, r11u199verify C/c04's bound side): golden names a bound
   module's interface `work@top.c.u`, ours `work@top.t.c.u`.
3. **Definition-view generate leftovers of § genConnTernSysActual315:** a hierarchical branch `s ? v.sig[0] : a`
   (VC/c08: golden `work@top.g.c0.clk.v.sig[0].sig`, ours `v.sig[0]`; the operator tree's syntax fallback carries no
   formal scope), `$bits(a)` which TypeEmit emitSyntaxExpr folds to a constant where golden keeps the call (c11), and
   a macro-wrapped parenthesised ternary (c16).
4. **User function-call actuals** (OS/o08, o09, o18): stage 1 (golden adds a ref_typespec to the argument; in a
   generate block Surelog lists the function name as a gen_scope net, a defect not copied).
5. **An interface inside an interface** (VA/a04, DIVERGENT downstream on both binaries), a parameter operand (a09)
   and a constant-only actual (a16): stage 1 on both, not decoded.
6. The brief's other module/type residues stand as passes 307 to 313 left them.

No sister-ground face was reached: every site above is in ModuleEmit or TypeEmit.

## Process

- **No slip.** Every dump went through a guarded wrapper (`[ -x "$UHDM_DUMP" ]`); every helper read the fence
  fail-closed and every tree scan built its path list and filtered it by $FENCED before opening a file; no other
  agent's process was listed or touched; nothing was written outside this worktree and the pass's /tmp scratch
  (/tmp/r11u315_*).
- Drafts measured before the frozen law binary: a draft renaming user-call arguments (dropped: stage 1 on every
  case), and a draft of § ifaceConnLeftmostLeafElab315 without the cast-leaf exemption, which moved r11u193repro
  CL/s12 chain away 6 and v11u313repro VM/vm26 order-blind distance 1 -> 2 in the firing controls; the exemption
  (castLeaves193, the rule § castOperandLeafElab193 already applies to module children) is part of the law as
  delivered, and both cases now enter STRICT_EQUAL.

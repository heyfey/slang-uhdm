# r11u317 — block-local and call-argument bindings, selects and casts nested in a select's index, multi-dimension and indexed-part-select operands of interface and module port actuals

Base 67728688 (pass 315). Ground: module/type (src/ModuleEmit.cpp only). Fifteen laws, each behind its own switch
read through src/LawSwitch.h (`lawOn(317, ...)`). `R11U317_OFF` drops all fifteen and gives pristine's bytes on 208
of 208 grid case-views. `R11U317_TRACE=<dir>` logs every firing (`lawTrace(317, ...)`). There is no src/R*.h, no
LawState.h section and no getenv; the laws keep no state between emitter calls.

**Target: pass 315's residues.** The verifier's VU/vu07 (the brief's first item), VO/vo18, VK/vk03, VO/vo02 and
VO/vo09 all enter STRICT_EQUAL, and so do VD/vd08 and vd23. The pass also covers the module-child twins the decode
found (casts and selects nested in an index, multi-dimension and indexed-part-select operands):

| case-view (v11u315repro) | pristine | law |
|---|---|---|
| VU/vu07_op_gen_local_313ctl (default) | stage 1 (31 lines) | STRICT_EQUAL 94 |
| VO/vo18_sys_bitsel_refidx_gen (default) | stage 1 (31 lines) | STRICT_EQUAL 100 |
| VK/vk03_cast_in_index (both views) | fullname | STRICT_EQUAL 122 / 121 |
| VO/vo02_nested_bitsel_idx_mod (both views) | fullname | STRICT_EQUAL 129 / 127 |
| VO/vo09_2d_bitsel_op (both views) | fullname | STRICT_EQUAL 117 / 115 |
| VD/vd08_tern_ips_branch, vd23_sys_signed_ips (both views) | fullname | STRICT_EQUAL |

**Gate: no corpus row and no gated probe case changes status, and no gate database moves in bytes.**
- Probe: 4017 EQUAL + 70 STRICT_NOTEQUAL. Regressions 0, conversions 0, changes 0.
- Surelog: 480 + 0 (default) and 474 + 0 (testflags). uhdm2rtlil: 803/1/67 in both modes. All 0/0/0.
- Downstream: 803/66/2/0, byte-identical to the committed csv.
- byteverify: 0 of 3365 corpus and downstream databases move, and 0 of 4087 probe databases.

## The decode

The decode carries pass 315's to the shapes its walkers stopped short of. Surelog compiles a port actual in
NetlistElaboration::high_conn_. An interface instance's actual is compiled in the generate scope's component when the
instance sits in a generate block. Every name below was measured in both views on fresh cases, with goldens from
Surelog using check_probe's arguments.

**1. Bindings in a generate block (§ genIfaceInnerLocalKeepsBind317, § genSysArgInnerUnbound317,
§ genCallArgInnerBlockOnly317).** The lookup runs in the instance's own generate block. A name that block declares
resolves and stays bound; every other name stays unbound.
- `.clk(l & a)` with `logic l` in the block binds `l` to `logic_var work@top.g.l` and leaves `a` unbound
  (GL/l01, v11u315repro VU/vu07).
- Pass 313's walker unbound `l` too.
- A name declared by an ENCLOSING block goes unbound (GL/l07 `.clk(l & a)` in g.h with `l` in g; l16
  `$signed(l)`). Pass 315v's refinement kept every generate-block name bound, so `l` stayed bound in l16.
- Every reference below a system call's argument stays unbound, not only an argument that is itself a reference:
  - GS/s01 `$signed(ck[s])`: the index `s`;
  - s02 `$signed(a & b)`: `a` and `b`;
  - s05: an indexed part select's base;
  - s10: a nested call's operation argument.
- Pass 315's walker unbound only direct reference arguments, and pass 313's stopped at the call.
- The elaborated view already read equal on both binaries: UHDM's elaborator rebinds by scope lookup there.

**2. Objects nested in a select's index (§ ifaceHcIdxSelByInst317, § castTsInIdxNamedByChain317,
§ selIdxCastTsNamedBySel317, § modConnIdxNestedNames317, § modConnIdxNestedNamesGen317).** A select written in
another select's index, and everything below it, is named through the OUTERMOST select:
- an inner select: `ck[k[0]] | a` gives `work@top.u.clk.ck.k` (OX/x01). At the actual's top, `ck[k[0]]` gives
  `work@top.u.ck.k` (x05);
- a reference in the inner select's index: x13 `ck[k[s]] | a` gives `work@top.u.clk.ck.s`.

A cast's ref_typespec is unnamed in Surelog (the `paCast` branch), so it takes the parent chain's name, the enclosing
select's full name:
- CK/k01 `ck[2'(s)] & ck[0]` gives `work@top.u.clk.ck`; pass 315 wrote `work@top.u.clk` at every depth;
- k02 `ck[2'(s)]` at the top gives `work@top.u.ck` in both views (the definition view included);
- k06: the cast in an indexed part select's base;
- VR/r14: in a var_select's index.

Module children follow the same rule:
- CM/m01 `.d(ck[2'(s)])` gives `work@top.c.ck` in both views;
- m02 `ck[2'(s)] & ck[0]` gives the typespec `work@top.c.d.ck` and the cast's operand `work@top.c.d.ck.s`;
- m04 `ck[k[0]] | a` gives `work@top.c.d.ck.k`;
- in a generate block: VR/r08, r15.

**3. Multi-dimension select operands (§ ifaceHcVarSelByInst317, § ifaceConnLeafVarSel317,
§ modConnLeafVarSel317).**
- Naming: `m[1][0] & a` names the var_select `work@top.u.clk.m` (OX/x07; ours `work@top.m`), and a reference written
  as one of its indices `<select>.<name>` (x09 `m[s][0] | a` gives `work@top.u.clk.m.s`).
- Binding follows the leftmost-leaf rule of § connLeftmostLeafElab139:
  - a var_select in the leaf position keeps the instance's objects in ALL its indices (x14 `m[1][s] | a`,
    x17 `m[s][t] & a`);
  - anywhere else (a right operand x15, a call argument x11, x16) its index references bind the parent
    definition's net.
- Module children follow the same rule (CM/m08, m09, m10).

**4. An indexed part select's base in a module child's actual (§ modConnIpsBaseByPort317).** Pass 139's walker named
and bound a bit_select's index but never entered an indexed part select's base.
- Golden names a reference written directly as the base `<port>.<name>` and binds it to the parent definition's net:
  - CM/m13 `.d(v[s +: 1])` gives `work@top.c.d.s`;
  - m06 `$signed(v[s +: 1])`;
  - m11 and m12 as operands.
- References inside an operation base are named through the select (m14 `v[s*2 +: 2]` gives `work@top.c.d.v.s`).
- In a generate block the names follow (CM/m07, m17, v11u315repro VD/vd08, vd23), with no definition binding.

**5. Definition-view generate listings (§ defGenSelInIdxLeaf317, § defGenSysInOpLeaf317,
§ defGenCastInIdxLeaf317).** The text-driven index builder of emitDefGenStmts (mkIdxTx9) and the select leaf
(mkOpSelLeaf9) refused a nested select. They also had no branch for a cast, and a system call met as an operand fell to
the syntax emitter. Golden writes the select-leaf shape at every level:
- OX/x02 `ck[k[0]] | a`: the outer bit_select sits at its index `7:20..7:24`, the inner `work@top.g.u.clk.ck.k` at
  `7:22..7:23`. Ours had the syntax emitter's whole-select spans (col);
- DS/d05: a select as the whole index of a bare select actual; ours wrote one ref_obj named `k[0]` (stage 1);
- CK/k03 `ck[2'(s)] | ck[1]`: operation 67 at the cast text. Its ref_typespec is named through the select and
  bound to an unparented `integer_typespec INT:2` at the size token; its operand is
  `work@top.g.u.clk.ck.s`. Ours wrote one ref_obj named `2'(s)` (stage 1);
- GS/s11 `$signed(ck[s]) & a`: the call takes § genConnTernSysActual315's system-call shape, its select argument
  located at the index.

## Laws

| law | switch | site | statement |
|---|---|---|---|
| § genIfaceInnerLocalKeepsBind317 | R11U317_GENLOCALOP_OFF | emitInterfaceInstance port loop, § genIfaceHcInnerRefUnbound313's walker (its new `local317` argument) | in a generate block a reference to a name the instance's OWN generate block declares (found on the slang tree, matched by start position) keeps its binding |
| § genSysArgInnerUnbound317 | R11U317_GENSYSINNER_OFF | same loop, helper `genSysArgInnerUnbound317` | in a generate block every reference below a system call's argument (operands, select indices, indexed part select bases, nested calls) loses its binding unless the instance's own block declares it |
| § genCallArgInnerBlockOnly317 | R11U317_GENLOCALINNER_OFF | inside § genCallArgLocalKeepsBind315v | a direct call argument declared by an ENCLOSING generate block goes unbound; only the instance's own block counts |
| § castTsInIdxNamedByChain317 | R11U317_CASTIDXCHAIN_OFF | § ifaceConnCastTsNamedByPort315's walker | inside a select's index (or an ips base, or a var_select's index) a cast's typespec reference takes the enclosing select's full name, read only at a cast |
| § ifaceHcIdxSelByInst317 | R11U317_IDXSEL_OFF | helper `ifaceHcIdxSelByInst317`, called from the index walkers of passes 313 and 315 | a select inside another select's index of an interface actual is named `<outer>.<name>`, and every reference or select below it the same way through the outermost select |
| § ifaceHcVarSelByInst317 | R11U317_VARSEL_OFF | `ifaceHcOpSelByInst315`'s switch, a var_select case | a var_select operand or call argument is named `<instance>.<port>.<name>`, its index references `<select>.<name>` |
| § ifaceConnLeafVarSel317 | R11U317_VARSELLEAF_OFF | `ifaceConnLeftmostLeafElab315` | a var_select's index references follow the leftmost leaf rule; in the leaf position all of them keep the instance's objects |
| § selIdxCastTsNamedBySel317 | R11U317_SELIDXCASTTS_OFF | helper; the definition-view ref_module port loop (module and interface children) and emitInstance's bit_select HighConn (module children) | a cast in a bit_select actual's index names its typespec reference by the nearest enclosing select |
| § modConnIdxNestedNames317 | R11U317_MODIDXNEST_OFF | helper, emitInstance just before `p->High_conn(h)` | module scope, no bind, operation / system-call / ips actual of a module child: inner selects, references below a cast, cast typespecs in an index named through the outer select; a var_select operand `<port>.<name>` |
| § modConnIdxNestedNamesGen317 | R11U317_MODIDXNESTGEN_OFF | the same call | the same in a generate block, through the generate scope |
| § modConnLeafVarSel317 | R11U317_MODVARSELLEAF_OFF | pass 139's `walk139` and its leaf scan | the module-child twin of § ifaceConnLeafVarSel317 |
| § modConnIpsBaseByPort317 | R11U317_MODIPSBASE_OFF | `walk139` and its entry gate | `walk139` enters an indexed part select's base (and runs on a whole-actual ips): a direct base reference named `<port>.<name>` and bound to the parent definition's net, references in an operation base named through the select |
| § defGenSelInIdxLeaf317 | R11U317_DEFGENSELIDX_OFF | emitDefGenStmts: `mkIdxTx9`, `mkOpSelLeaf9`, the bare-select branch | a select written as (or in) an index is a bit_select in the select-leaf shape named through the outer select |
| § defGenSysInOpLeaf317 | R11U317_DEFGENSYSINOP_OFF | emitDefGenStmts: the operator tree's operand fallback (`sysInOp317`, a copy of `mkSys315` taking the scope) | a system call met as an operand takes § genConnTernSysActual315's call shape |
| § defGenCastInIdxLeaf317 | R11U317_DEFGENCASTIDX_OFF | emitDefGenStmts: `mkIdxTx9` and the bare-select branch | a size cast `N'(...)` in an index is operation 67 with a ref_typespec named through the select, an unparented integer_typespec `INT:N` at the size token, and its operand built by the same builder |

Name writes inside an index are unconditional. Reading a stored name first would make UHDM's getter store the
computed one, so every visit is a trace line, and the census over-predicts by construction (see below).

## Binaries

| binary | md5 |
|---|---|
| pristine (67728688, -j 2) | 4f4e3b7d3caecfcdeaa821c108ed0cc0 (equal to the main tree's build/slang-uhdm) |
| law (the delivered patch) | d287a51e6d2c456b252f2143cfa6efc6 |
| uhdm-strictcmp / strictcmp_x (drivers/cc_x.sh) | fa6e4f42f252ae0ab69d9845003e71c5 / 886f030233ecdbcce7d0e29ac0c4df2c |

Both slang-uhdm binaries link slang 12.0.0+545f88b2e. Both were frozen (chmod 555) before any measurement.

## Grid (104 case dirs in CK, CM, DS, GL, GS, OX, VR; both views)

The evidence is in evidence/grid.txt, gridsum.txt, grid_table.txt and grid_switch_effect.txt. drivers/grid.sh runs
each case-view on P, L and OFF (`R11U317_OFF`), and on L with each switch off.

**Overall:**
- All 3744 lines carry `rc=`, and every line is rc=0.
- 208 case-views: 163 moving, 146 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- OFF equals pristine on 208 of 208.
- uhdm-cmp line counts: 37 case-views go from stage 1 to 0 lines (31, 44, 52 and 17 lines). None grows.

**Attribution:**
- Restored by one switch alone: MODIPSBASE 20, IDXSEL 20, VARSEL 17, DEFGENSYSINOP 14, GENLOCALOP 12, CASTIDXCHAIN 10,
  MODIDXNEST 10, GENSYSINNER 8, SELIDXCASTTS 4.
- The other 48 movers need two or more switches; every switch has an effect alone somewhere
  (grid_switch_effect.txt):
  - CASTIDXCHAIN 22, IDXSEL 38, MODIPSBASE 24, MODIDXNEST 22, DEFGENSYSINOP 20, VARSEL 20, DEFGENSELIDX 18,
    GENSYSINNER 14, GENLOCALOP 13, DEFGENCASTIDX 8, SELIDXCASTTS 6, MODIDXNESTGEN 4, MODVARSELLEAF 4, VARSELLEAF 3.
  - GENLOCALINNER has no effect alone: on GL/l15 and l16, § genSysArgInnerUnbound317 unbinds the same outer-block
    argument, so the two act as a pair.

**Away census:**
- drivers/awaycv.sh (order-blind and chain-keyed) on all 163 movers: lost 0, chain away 0, flat away 0, with 263
  records toward golden (evidence/away_grid.txt).
- Positive control, binaries swapped on 12 entering movers (evidence/away_poscontrol.txt): 9 of 12 read away.
  - The three that do not, GL/l01, l12 and GS/s05, are binding-only movers: a dropped or added vpiActual is
    invisible to the records, as v11u315 found.
  - Their measure is uhdm-cmp: 31 lines on pristine, 0 under the law.

**Downstream on all 104 dirs** (drivers/dscases.py; evidence/downstream_cases_P.txt and _L.txt): no verdict moves.
103 are IDENTICAL on both binaries, and VR/r06 is EQUIVALENT on both.

| law | cases (first line names the law) |
|---|---|
| § genIfaceInnerLocalKeepsBind317 | GL/l01_and_local_left, l02_and_local_right, l03_unary_local, l04_concat_local, l05_bitsel_local_idx, l08_forgen_local, l09_local_shadows, l10_else_local, l11_case_local_tern, l12_local_ips_base, l14_local_var_always, VR/r18_gen_local_ternary_sys; controls l06_local_vector_bitsel, l07_outer_block_local (outer block: unbound in golden), l13_local_mod_child_ctl |
| § genSysArgInnerUnbound317 | GS/s01_sys_bitsel_refidx, s02_sys_op_arg, s03_sys_concat_arg, s04_sys_bitsel_opidx, s05_sys_ips_base, s06_sys_unary_arg, s07_sys_tern_arg, s09_sys_local_op_arg, s10_sys_nested_op_arg, VR/r09_forgen_local_sys, r10_casegen_sys_inner; controls s08_sys_local_idx_keeps, s13_mod_sys_op_arg_ctl, s14_mod_sys_bitsel_ctl |
| § genCallArgInnerBlockOnly317 | GL/l15_outer_block_sys, l16_outer_block_sys_only |
| § castTsInIdxNamedByChain317 | CK/k01_cast_idx_op_mod, k04_cast_in_idx_op_mod, k05_cast_idx_sys_mod, k06_cast_ips_base_mod, k07_cast_idx_and_cast_op, VR/r03_crlf_cast_idxsel (CRLF); control k08_partsel_idx_ctl |
| § selIdxCastTsNamedBySel317 | CK/k02_cast_idx_top_mod, CM/m01_mod_cast_idx_top, VR/r07_mod_positional_cast, r13_mod_ips_top_cast |
| § ifaceHcIdxSelByInst317 | OX/x01_sel_in_idx_op_mod, x04_sel_in_idx_opidx, x05_sel_in_idx_top_ctl, x06_sel_in_idx_sys, x13_sel_refidx_in_idx, VR/r01_bind_idxsel, r02_positional_idxsel, r04_macro_idxsel, r06_iface_array_idxsel; control x03_partsel_in_idx_op |
| § ifaceHcVarSelByInst317 | OX/x07_2d_op_mod, x08_2d_op_gen, x09_2d_refidx_op, VR/r05_depth2_varsel, r14_varsel_cast_idx; controls x10_2d_top_ctl, x12_1of2d_unary |
| § ifaceConnLeafVarSel317 | OX/x11_2d_sys, x14_2d_constfirst_refidx, x15_2d_right_operand, x16_2d_sys_two, x17_2d_left_two_refs |
| § modConnIdxNestedNames317 | CM/m02_mod_cast_idx_op, m03_mod_cast_ips_base, m04_mod_sel_in_idx_op, m05_mod_2d_op, VR/r12_program_child_idxsel |
| § modConnIdxNestedNamesGen317 | VR/r08_mod_gen_nested_ctl, r15_gen_mod_cast_idx_def |
| § modConnLeafVarSel317 | CM/m08_mod_2d_leaf_refidx, m09_mod_2d_right, m10_mod_2d_sys |
| § modConnIpsBaseByPort317 | CM/m06_mod_sys_ips_base, m07_gen_sys_ips_base, m11_mod_ips_operand, m12_mod_ips_right, m13_mod_ips_top_refbase, m14_mod_ips_opbase, m15_mod_ips_addbase, m17_forgen_ips_ref, m18_mod_ips_desc; controls m16_forgen_ips_genvar, m19_mod_ips_const, m20_mod_ips_param |
| § defGenSelInIdxLeaf317 | DS/d05_nested_sel_top, d06_nested_sel_opidx, d07_nested_sel_sysarg, d08_nested_sel_refidx, d10_forgen_nested_sel, GS/s12_sys_nested_sel_idx, OX/x02_sel_in_idx_op_gen, VR/r11_twolevel_for_selidx |
| § defGenSysInOpLeaf317 | DS/d01_or_sys_right, d04_sys_two_in_op, d09_mod_child_sys_in_op, GS/s11_sys_in_op_bitsel; controls d02_unary_sys, d03_cmp_countones (equal on both) |
| § defGenCastInIdxLeaf317 | CK/k03_cast_idx_op_gen, k09_cast_idx_top_gen, VR/r17_gen_cast_opidx; control r16_gen_signed_cast_idx_ctl (`signed'(s)`, the law abstains) |

Moving without entering, all toward golden with chain away 0:
- VR/r01_bind_idxsel default view: the bind naming of residue 3 is left. The elaborated view enters.
- VR/r10_casegen_sys_inner default view: stage 1 to col. The binding is cleared; the col face is residue 2.

## Controls

**Firing scan** (drivers/firescan.sh with the law binary; evidence/firing_law.txt):
- 27691 fence-filtered tools/probe dirs. 173 fire: 93 of this pass and 80 earlier dirs.
- 404 nonzero exits (249 exit 3, 154 exit 4, one exit 139 v11u112repro/grid/brk2/k/m07_hdr_enum_default). Each is
  equal on pristine (evidence/rc_law_nonzero.txt, rc_pristine_nonzero.txt).

**The 80 earlier firing dirs, both views** (evidence/controls_firing.txt, controls_firing_sum.txt):
- 160 case-views, 50 moving, 22 entering STRICT_EQUAL, 0 leaving. No exit-code change.
- Entering:
  - v11u315repro VU/vu07, VO/vo18, VK/vk03, VO/vo02, VO/vo09, VD/vd08, VD/vd23;
  - v11u313repro VG/vg15_nested_bitsel_idx and vg21_gen_local_op (both views, stage 1 to 0 lines);
  - r11u168repro H/h11, r11u177verify H/h04_gen_array_idx_of_idx (both views);
  - r11u239repro OS/x02, v11u239repro OS/s03.
- Moving without entering, at stage 1 on both binaries:
  - r11u177verify X/x03_hc_index_gen_param, 40 to 54 uhdm-cmp lines. The old head (the definition-view
    `v[s[c]]` in a for-generate, ours a ref_obj named `s[c]`) is cleared. The new head is later in the walk: instance
    n's `v[P % 4]`, where mkIdxTx9 has no `%` branch (residue 2).
  - r11u185verify X/x06, r11u236repro P/p05, v11u236repro D/d02 and D/d03 (line counts unchanged).
- The rest move in bytes while STRICT_EQUAL on both binaries: r11u315repro DG/d08 and VA/a20, a22, and
  v11u315repro VD/vd09, vd13, VU/vu01, vu08 and vu11. These are unconditional name writes and an unbinding that
  golden shares.

**Neighbour repro dirs** (r11u139netbind, r11u168repro, r11u193repro, v11u193repro, r11u307 to r11u315 and v11u307
to v11u315; evidence/controls_nb_sum.txt): 2150 case-views, 34 moving, 18 entering, 0 leaving. No exit-code change.
Every mover is in the firing list.

**Away census on all 50 control movers** (evidence/away_controls.txt): lost 0, chain away 0, flat away 0, with 46
records toward golden.

**Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131 and r11v131;
evidence/controls_std_sum.txt): 1440 case-views, 0 moving.

## Firing census and gates (evidence/predict.txt, gates_*.txt, byteverify_corp.txt, det.txt)

**Firing census** (drivers/tracecensus.sh, frozen before the law sweep; the law binary under R11U317_TRACE over the
probe and both corpora in both modes, filtered by $FENCED) names 15 databases, all by § modConnIpsBaseByPort317:
- probe: r10v65repro/a6_def and a8_orphan, r11u110repro/grid/e1/e06_gen_for, r11u111repro/grid/f1/a15_q_genblk,
  v11u111repro/brk/f1/z11_three_inst_gen;
- Surelog: Earlgrey_0_1 d/t and YosysRiscv d/t;
- uhdm2rtlil: gen_scope_numports d/t, generate_test d/t and stamped_gen_param d/t.

All 15 are over-prediction. The walker visits a whole-actual or operand indexed part select whose base is a constant
or a folded genvar, and writes the name that is already stored. The five probe cases run through drivers/case.sh are
byte-identical in both views, and the sweeps' byteverify moves none of them.

**Sweeps.** tests/sweep.sh --jobs 3 ran on pristine and on the law, from this worktree, with workdirs of equal length
(/tmp/r11u317_swP, /tmp/r11u317_swL).
- Both read the gate numbers above, and both exit 1 on the law-index check alone (the index is regenerated in the
  patch).
- The pristine sweep, run while the census, the firing scan and the controls loaded the machine, timed out on
  Earlgrey_0_1 testflags. That row run alone on pristine reads CMP_EQUAL / equal (evidence/gates_pristine.txt).
  Three concurrent draws of the law on it alone read one hash, 025c86db2d2d, equal to the law sweep.
- The csv row diff between law and pristine is 0 lines in probe, uhdm2rtlil and downstream. In surelog the only
  differences are that pristine timeout and the LowMem workdir text (evidence/csv_rowdiff_law_vs_pristine.txt).

**byteverify** (tools/probe/r11v75repro/byteverify.sh, SELFCHECK=1, on fence-filtered hard-link mirrors with 8 fenced
paths skipped):
- 0 of 3365 corpus and downstream databases move. SELFCHECK flags 3363 of 3365 (the known 1DUnpackedArray twin).
- 0 of 4087 probe databases move (md5 of every fence-filtered database).

**Canaries:** surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both csvs.

**Binary audit:** each sweep has 3315 fence-filtered cmds.txt. 3265 name that sweep's own binary, and 0 name the
other binary or the main tree's.

**Determinism** (drivers/det.sh, three concurrent draws of the law): one hash per row-mode on Earlgrey_0_1, MiniAmiq,
SeqDriver, SimpleUVM and BuildUVMPkg in both modes, and on Scoreboard and Rggen default. Each equals the law sweep's.
Earlgrey_0_1 testflags timed out in the concurrent run and was drawn three times alone, as above.

## Residues (ranked; all wrong on pristine too, none moved away)

1. **Pass 315's definition-view generate leftovers.**
   - A hierarchical branch or argument: VD/vd15, vd25, r11u315repro VC/c08.
   - A user-call condition's argument (vd21).
   - `$bits` folded by TypeEmit emitSyntaxExpr (c11) and a macro-wrapped ternary (c16).
   - The elaborated-view folds Surelog makes: vd05 `$clog2(W)` and vd06 `P ? a : b`.
2. **The definition-view index builder's other shapes** (emitDefGenStmts mkIdxTx9 / mkOpSelLeaf9, ModuleEmit):
   - a part select in an index, VR/r10 `$signed(ck[s[1:0]] ^ a)` in a case generate. The select spans the whole text
     (col; mkOpSelLeaf9 refuses `:`).
   - a `signed'(s)` cast, r16, at stage 1;
   - `%` in an index, r11u177verify X/x03 `v[P % 4]` (kIdxOps9 lists `- + * /` only).
3. **The bind naming** (VR/r01 default, v11u315 VO/vo12, VA/a03): in VR/r01 golden lists the bound interface
   actual's net as `work@top.a`, where ours lists `work@tgt.a`.
4. **An interface array fed an operation** (VR/r06 `ifc u [2] (.clk(ck[k[0]] & a))`): stage 1 at the module_array
   head on both binaries; not this pass's face.
5. **A parameter in an indexed part select's base** (CM/m20 `v[P +: 2]`): golden folds it. The head is the folded
   constant's typespec, stage 1 on both.
6. **Pass 313's and 315's other standing faces** stand as those READMEs list them: the struct-member actual, the
   module-level interface array's module_array, the parameter index golden folds, user function-call actuals, an
   interface inside an interface, the package type-cast name vk05, and the stage-1 hierarchical shapes.

No sister-ground face was reached: every site above is in ModuleEmit, with residue 1's c11 in TypeEmit (this
ground).

## Process

- **The IMPLEMENTER'S SLIP, no effect.** One decode shell ran `$UHDM_DUMP gold_*/golden.uhdm` before the environment
  was sourced, which executed one golden database (OX/x02's, inside this pass's scratch).
  - Its output went to a scratch file and came back empty.
  - No file was written in the directory (checked).
  - Every later dump went through a guarded wrapper that refuses to run with the variable unset.
- **Superseded runs.** A first firing census and firing scan on a superseded law binary were stopped through their
  own task ids. Pass 313's index walker had been given the inner-select hook on operation operands too. That moved
  bytes, not verdicts, and was narrowed to index positions before the frozen law. No process of another agent was
  listed or touched.
- **Drafts not delivered:**
  - A draft law renaming an indexed part select's base in the definition-view generate listing was dropped: the face
    was the elaborated module child, now § modConnIpsBaseByPort317.
  - An early form of § ifaceConnLeafVarSel317 that walked only the first index into the leaf moved x14 and x17 to
    depth (an extra definition binding) and was replaced before freezing.
  - Two draft case files had a `|` that the generator split; they were rewritten before any counting.
- **Fence.** Every helper read $FENCED fail-closed. Every tree scan built its path list and filtered it before
  opening a file. The census ran with filters built from $FENCED. Nothing was written outside /tmp/wt_r11u317 and
  /tmp/r11u317_*.

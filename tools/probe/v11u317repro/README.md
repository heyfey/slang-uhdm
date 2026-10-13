# v11u317 — adversarial verification of r11u317

Base 67728688 (pass 315). Implementer's patch /tmp/r11u317.patch: fifteen laws in src/ModuleEmit.cpp read through
src/LawSwitch.h (`lawOn(317, ...)`) and tools/probe/r11u317repro. This dir: 139 fresh case dirs in VA, VB, VC, VD,
VE, VF, VG and VH (both views), the drivers (copied from r11u317repro/drivers, plus gridv.sh, pgridv.sh,
gridsumv.py, controls3.sh, ctlsum3.py and firescanv.sh) and evidence/.

**Verdict: ACCEPT WITH FIX.** Every headline number of the implementer reproduces bit for bit. The fresh attack
found legal SV where pristine was right and the law wrong: six case-views that leave uhdm-cmp equality (stage 1,
28 to 32 lines) and six more that move a strict record away from golden. All of them are in the definition-view
index builder of § defGenSelInIdxLeaf317. Two refinements fix them. A third refinement corrects the naming rule
of the nested-select laws at depth two and more. All three are in src/ModuleEmit.cpp and read through
`fixOn(317, ...)`.

## The verifier's refinements

`R11V317_OFF` drops all three and gives the law's bytes on 278 of 278 fresh case-views and on 208 of 208 of the
implementer's grid case-views. `R11U317_OFF` still gives pristine's bytes on all 486 case-views. Each refinement
logs through `lawTrace(317, ...)`. There is no src/R*.h, no LawState.h section and no getenv.

| refinement | switch | site | statement |
|---|---|---|---|
| § defGenNestSelIdxTrim317v | R11V317_SELIDXTRIM_OFF | emitDefGenStmts, § defGenSelInIdxLeaf317's nested-select branch of `mkIdxTx9` | the inner select's index text is trimmed before it is built, as every other `mkIdxTx9` caller does; the inner bit_select sits at the trimmed span |
| § defGenNestSelEscBase317v | R11V317_ESCBASE_OFF | emitDefGenStmts, `mkOpSelLeaf9` | a select that the law lets through `mkOpSelLeaf9` (one with a nested select in its index) names an escaped base without its backslash, as the syntax emitter it replaced did |
| § nestSelChainName317v | R11V317_NESTCHAIN_OFF | `ifaceHcIdxSelByInst317` (interface actuals, both views), `modConnIdxNestedNames317`'s `nest` (module children), and `mkIdxTx9`'s nested-select branch (the definition view) | below an inner select, an operation index or a further select is named through THAT inner select. A reference written directly as the inner select's index keeps the outer select's name |

### The breaks (pristine right, law wrong)

1. **Blanks in an inner select's index** (§ defGenNestSelIdxTrim317v). The law's nested-select branch passed the
   untrimmed index text to `mkIdxTx9`, which treats its input as trimmed. In VH/vh19_def_nested_sel_spaces
   `.clk(ck[k[ 0 ]] | a)` inside `if (1) begin : g`, golden has `constant 0` at 7:23..7:24 under
   `bit_select work@top.g.u.clk.ck.k` at 7:23..7:24. The law wrote a `ref_obj` named " 0 " (full name
   `work@top.g.u.clk.ck. 0 `) at 7:22..7:25.
   - The law reads uhdm-cmp stage 1 (32 lines) in both views. Pristine is judge-equal there (strict col).
   - The same holds for vh24 `ck[k[ s ]]` (28 lines; the law wrote `ref_obj " s "`) and vh26 `ck[k[0 ]]` (32
     lines). vh25 `ck[k[ s+1 ]]` stays judge-equal under the law but reads chain away 1, order-blind lost 1.
   - Under the fix all eight case-views read STRICT_EQUAL.
2. **An escaped base with a nested select** (§ defGenNestSelEscBase317v). Before the law, `mkOpSelLeaf9` refused a
   select with a nested index, and the syntax emitter wrote the base without its backslash. In VH/vh17
   `\ck$x [k[0]] | a`, golden has `bit_select ck$x`, full name `work@top.g.u.clk.ck$x`. The law wrote `\ck$x` and
   `work@top.g.u.clk.\ck$x`, chain away 1 in both views. vh29 is the module-child twin.
   - Under the fix all four case-views read STRICT_EQUAL.
   - The plain escaped select, vh27 `\ck$x [s] | a`, keeps pristine's bytes on every binary (strict name). That is
     pass 311's standing vt09 face, which § defGenNestSelEscBase317v does not touch.

### The naming refinement (law wrong, pristine wrong too)

Golden names nested selects by their chain, not by the outermost select. The law's "outermost" rule matches golden
only at depth one. The table gives golden's names, measured in both views:

| case | actual | golden | law |
|---|---|---|---|
| VE/ve01_three_level_sel | `ck[k[j[0]]] \| ck[0]` | bit_select j `work@top.u.clk.ck.k.j` | `work@top.u.clk.ck.j` |
| VE/ve03_sel_opidx_inner | `ck[k[s+1]] & ck[0]` | ref_obj s `work@top.u.clk.ck.k.s` | `work@top.u.clk.ck.s` |
| r11u317repro OX/x13 (control) | `ck[k[s]] \| a` | ref_obj s `work@top.u.clk.ck.s` | `work@top.u.clk.ck.s` (unchanged) |
| VE/ve13, ve14 | the module-child twins | `work@top.c.d.ck.k.j`, `work@top.c.d.ck.k.s` | `...ck.j`, `...ck.s` |
| VE/ve15, ve16 | the generate twins (definition view through `mkIdxTx9`) | `work@top.g.u.clk.ck.k.j`, `...ck.k.s` | `...ck.j`, `...ck.s` |
| VF/vf12 | `m[k[s+1]][0] & a` | `work@top.u.clk.m.k.s` | `work@top.u.clk.m.s` |

- Under the law each of these read one record wrong, with chain away 0 (pristine was further off).
- Under the fix, 34 case-views move from the law's bytes to STRICT_EQUAL. That is every depth-2+ shape, at module
  scope and in generate blocks, for interface and module children, top-level and operand selects, var_select
  indices, casts in an inner index (ve27) and four levels (ve23, ve24). § nestSelChainName317v alone restores the
  law's bytes on each of them.

## Reproduction of the implementer's numbers (binaries built and frozen by this verifier)

| binary | md5 |
|---|---|
| pristine (67728688, -j 2) | 4f4e3b7d3caecfcdeaa821c108ed0cc0, equal to the main tree's build/slang-uhdm and the implementer's |
| law (the delivered patch) | d287a51e6d2c456b252f2143cfa6efc6, equal to the implementer's |
| fix (law + the three refinements) | 24f04f6e61371a04b9e3096024034e47 |
| uhdm-strictcmp / strictcmp_x | fa6e4f42f252ae0ab69d9845003e71c5 / 886f030233ecdbcce7d0e29ac0c4df2c, equal to the implementer's |

All three slang-uhdm binaries link slang 12.0.0+545f88b2e. Each was frozen (chmod 555) before any measurement.

**Grid** (the implementer's 104 dirs; evidence/gridsum_impl.txt, drivers/grid.sh on law; the raw grid file is not kept because it matches the implementer's evidence/grid.txt):
- 3744 of 3744 lines carry rc=0.
- 208 case-views: 163 moving, 146 entering STRICT_EQUAL, 0 leaving. OFF equals pristine on 208.
- The same single-switch attribution and the same 48 multi-switch movers.
- The grid matches the implementer's evidence/grid.txt on 3744 of 3744 lines, md5 field excluded.
- Away census on the 163 movers: lost 0, chain away 0, flat away 0, 263 records toward golden. This is identical
  line for line to the implementer's away_grid.txt.
- Under the fix (evidence/gridv_impl.txt): 4784 of 4784 lines rc=0. The fix equals the law on 208 of 208, and
  VOFF equals the law on 208.

**Gate sweeps** (tests/sweep.sh --jobs 3 from this worktree, STRICT_CMP exported; workdirs /tmp/v11u317_swP, _swL and
_swF of equal length; evidence/gates_{P,L,F}.txt and gates_summary.txt). Pristine, law and fix all read:
- probe 4017 EQUAL + 70 STRICT_NOTEQUAL, regressions 0, conversions 0, changes 0;
- surelog default 480 + 0 and testflags 474 + 0 (Google testflags TIMEOUT as in the baseline), 0/0/0;
- uhdm2rtlil 803/1/67 in both modes, 0/0/0;
- downstream 803/66/2/0, with downstream.csv byte-identical to results/downstream_uhdm2rtlil.csv.

Every sweep exits 1 on the law-index check alone; the index is regenerated in the patch.

Other gate checks:
- **CSV row diffs** between any two of the three sweeps: 0 lines in probe, uhdm2rtlil and downstream. In surelog the
  only 4 lines are LowMemLib and LowMemPkg testflags, whose detail text holds the workdir.
- **byteverify** on fence-filtered hard-link mirrors (8 paths skipped): 0 of 3365 movers for law vs pristine, fix vs
  pristine and fix vs law. SELFCHECK 3363 of 3365 (the known 1DUnpackedArray twin).
- **Probe databases** (fence-filtered md5): 0 of 4087 move for law or fix vs pristine.
- **Canaries:** surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0, and both ctcan2 checks PASS, on all three
  sweeps.
- **Binary audit:** each sweep has 3315 fence-filtered cmds.txt; 3265 name its own binary and 0 name another.

**Firing census, frozen before the fix sweep** (drivers/tracecensus.sh with the fix binary; evidence/predict_fix.txt):
- It names exactly the implementer's 15 databases, all by § modConnIpsBaseByPort317, with the same counts.
- No refinement of this verifier fires on any gate database.
- The law and fix sweeps moved none of the 15 in bytes, which confirms the implementer's over-prediction reading.
  The 15 trace lines through the harness are the positive control.

**Determinism** (drivers/det.sh, three concurrent draws; evidence/det_law.txt and det_fix.txt):
- One hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM and BuildUVMPkg in both modes, and on
  Scoreboard and Rggen default. Each equals the sweeps' (fc04e7f2bb3f and 025c86db2d2d for Earlgrey_0_1).
- Earlgrey_0_1 testflags timed out in the fix's loaded concurrent draw, as in the implementer's. Three concurrent
  draws of it alone read 025c86db2d2d each time, equal to all three sweeps.

**Firing scan** (drivers/firescanv.sh with the fix binary, tags kept; evidence/firing_fix_tags.txt):
- 27830 fence-filtered tools/probe dirs (27691 plus this dir's 139); 293 fire.
- Outside this dir, the dirs firing a law tag are exactly the implementer's 173, line for line.
- The refinement tags fire in 23 dirs, all of them in this dir; they fire nowhere else in tools/probe.
- 404 nonzero exits (249 exit 3, 154 exit 4, one exit 139 v11u112repro m07_hdr_enum_default). Each is equal on
  pristine, rerun here (evidence/rc_pristine_nonzero.txt, rc_fix_nonzero.txt).

**Controls** (drivers/controls3.sh, pristine / law / fix, both views):
- **The 80 earlier firing dirs** (160 case-views; evidence/controls_firing*.txt): 50 moving, 22 entering, 0
  leaving, 0 exit-code changes, 10 uhdm-cmp line-count changes. The mover list is the implementer's. The fix
  equals the law on 160 of 160.
- **Away census on the 50 control movers:** lost 0, chain away 0, flat away 0, 46 toward (evidence/away_controls.txt).
- **Neighbour dirs** (r11u139netbind, r11u168, r11u193, v11u193, r11u307 to r11u315, v11u307 to v11u315; 2150
  case-views): 34 moving, 18 entering, 0 leaving. The mover list is the implementer's, and the fix equals the law on
  2150.
- **Standard byte controls** (r11u118, r11v11u118, r11u119, r11u120, r11v120, r11u124, r11v124, r11u131, r11v131;
  1440 case-views): 0 moving on law and on fix. 4 case-views exit 3 on all three binaries.

## The fresh attack (139 dirs, 278 case-views; evidence/gridv_fresh.txt, gridsumv_fresh.txt)

drivers/gridv.sh runs every case-view on these configurations:
- P, L and F;
- OFF (the fix with R11U317_OFF) and VOFF (the fix with R11V317_OFF);
- the fix with each of the three R11V317 switches off, and with each of the fifteen R11U317 switches off.

All 6394 lines are rc=0, with no exit-code change.

| | moving | entering STRICT_EQUAL | leaving STRICT_EQUAL | leaving uhdm-cmp equality | chain away | toward golden |
|---|---|---|---|---|---|---|
| law vs pristine | 225 | 136 | 0 | 6 (vh19, vh24, vh26 both views) | 12 case-views (vh17, vh19, vh24, vh25, vh26, vh29 both views) | 460 records |
| fix vs pristine | 225 | 180 | 0 | 0 | 0 (lost 0, flat away 0) | 516 records |

Other attack results:
- OFF equals pristine on 278 and VOFF equals the law on 278.
- The fix differs from the law on 46 case-views:
  - § nestSelChainName317v alone restores the law on 34, § defGenNestSelIdxTrim317v on 6 and
    § defGenNestSelEscBase317v on 4;
  - vh25 (both views) needs the trim and chain pair.
- **Positive control** (binaries swapped, P vs F, on 12 entering movers): 11 of 12 read away. va04 is
  binding-only; its evidence is uhdm-cmp, 31 lines to 0.
- **Downstream** on all 139 dirs (drivers/dscases.py; evidence/downstream_fresh_{P,L,F}.txt): no verdict moves on
  any binary. 137 are IDENTICAL on all three; vg11_positional_ips and vd17_iface_array_elem_cast are EQUIVALENT on
  all three.
- The law-only stage-1 movers with no record toward golden were each checked by dump against golden:
  - va01: the for-generate local's binding, now golden's;
  - vb10 and vc03: unbindings golden shares;
  - ve11 and vg04: names now golden's;
  - vd08: the bind case, with the cast typespec now named by the select, `work@top.cb.ck`; golden is
    `work@top.t.cb.ck`, so it is still wrong by the bind face;
  - vg06: the instance-array case, `work@top..d.s` where pristine wrote `work@top.s` and golden
    `work@top.c[0].d.s`. That is pass 139's pre-existing empty instance-array prefix, which pristine already
    writes on the indexed part select itself, `work@top..d.v`. Both are wrong, so it is a residue, not a break.

Shapes covered:
- own-block locals in for, case and else generates and in unnamed blocks; a local shadowing a module signal, used
  as an index, in a concatenation or a ternary; three-level and for-generate outer blocks;
- system calls nested, over operations, over indexed part select bases, with a parameter or genvar index, in an
  else branch, over a struct member, and system calls in an index;
- casts sized by a parameter, signed', a typedef, nested casts, a cast of a select, a cast in an indexed part select
  base and in a 2-D index, casts in generate, instance-array, program, bind, positional, two-child, nested-module,
  interface-array-element and for-generate actuals;
- nested selects at depth 2 to 4, under operations, ternaries, concatenations and parameter overrides, in
  unpacked-array and parameter indices, in module, program and generate children;
- 2-D and 3-D and unpacked var_selects as left, right, both, system-call and ternary operands and as the whole
  actual;
- indexed part selects descending, with operation, select, localparam, int, parenthesised and cast bases, in
  generate, instance-array, program, bind, positional, nested-module and interface actuals;
- definition-view shapes with blanks, an escaped base, a macro index, CRLF, case generates, module children,
  param-width casts and system calls in comparisons.

### Per-case verdicts (P / L / F; EQ n = STRICT_EQUAL with n objects; the law each case names on its first line)

**VA**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VA/va01_forgen_local_xor | § genIfaceInnerLocalKeepsBind317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VA/va02_local_wire_init | § genIfaceInnerLocalKeepsBind317 | stage 1 / stage 1 / stage 1 | EQ 119 / EQ 119 / EQ 119 |
| VA/va03_local_shadows_module | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 113 / EQ 113 | EQ 131 / EQ 131 / EQ 131 |
| VA/va04_local_as_index | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 115 / EQ 115 | EQ 136 / EQ 136 / EQ 136 |
| VA/va05_unnamed_block_local | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 87 / EQ 87 | EQ 85 / EQ 85 / EQ 85 |
| VA/va06_casegen_local | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 127 / EQ 127 | EQ 148 / EQ 148 / EQ 148 |
| VA/va07_local_concat_red | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 94 / EQ 94 | EQ 115 / EQ 115 / EQ 115 |
| VA/va08_two_locals_tern | § genIfaceInnerLocalKeepsBind317 | stage 1 / EQ 121 / EQ 121 | EQ 149 / EQ 149 / EQ 149 |
| VA/va09_local_in_inner_and_outer | § genIfaceInnerLocalKeepsBind317 | stage 1 / fullname / fullname | fullname / fullname / fullname |
| VA/va10_local_param_index | § genIfaceInnerLocalKeepsBind317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VA/va11_local_in_sysidx | § genIfaceInnerLocalKeepsBind317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |

**VB**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VB/vb01_sys_param_idx | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VB/vb02_unsigned_xor | § genSysArgInnerUnbound317 | stage 1 / EQ 93 / EQ 93 | EQ 108 / EQ 108 / EQ 108 |
| VB/vb03_forgen_genvar_idx | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VB/vb04_nested_sys | § genSysArgInnerUnbound317 | stage 1 / EQ 95 / EQ 95 | EQ 111 / EQ 111 / EQ 111 |
| VB/vb05_countones_cmp | § genSysArgInnerUnbound317 | stage 1 / EQ 115 / EQ 115 | EQ 131 / EQ 131 / EQ 131 |
| VB/vb06_sys_local_and_outer | § genSysArgInnerUnbound317 | stage 1 / EQ 94 / EQ 94 | EQ 115 / EQ 115 / EQ 115 |
| VB/vb07_sys_ips_opbase | § genSysArgInnerUnbound317 | stage 1 / EQ 106 / EQ 106 | EQ 121 / EQ 121 / EQ 121 |
| VB/vb08_sys_in_else | § genSysArgInnerUnbound317 | stage 1 / EQ 127 / EQ 127 | col / EQ 143 / EQ 143 |
| VB/vb09_sys_two_args | § genSysArgInnerUnbound317 | stage 1 / EQ 100 / EQ 100 | EQ 114 / EQ 114 / EQ 114 |
| VB/vb10_sys_struct_member | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VB/vb11_sysidx_bits_gen | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VB/vb12_sysidx_clog2_param_gen | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VB/vb13_sys_size_gen | § genSysArgInnerUnbound317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |

**VC**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VC/vc01_three_levels | § genCallArgInnerBlockOnly317 | stage 1 / EQ 104 / EQ 104 | EQ 127 / EQ 127 / EQ 127 |
| VC/vc02_outer_and_own | § genCallArgInnerBlockOnly317 | stage 1 / EQ 118 / EQ 118 | EQ 149 / EQ 149 / EQ 149 |
| VC/vc03_forgen_outer | § genCallArgInnerBlockOnly317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |

**VD**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VD/vd01_param_width_cast_op | § castTsInIdxNamedByChain317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VD/vd02_signed_cast_op | § castTsInIdxNamedByChain317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VD/vd03_cast_op_inside | § castTsInIdxNamedByChain317 | fullname / EQ 126 / EQ 126 | fullname / EQ 125 / EQ 125 |
| VD/vd04_cast_gen_iface | § castTsInIdxNamedByChain317 | stage 1 / EQ 119 / EQ 119 | stage 1 / EQ 137 / EQ 137 |
| VD/vd05_mod_gen_top_cast | § selIdxCastTsNamedBySel317 | stage 1 / EQ 111 / EQ 111 | stage 1 / EQ 109 / EQ 109 |
| VD/vd06_mod_instarray_cast | § selIdxCastTsNamedBySel317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VD/vd07_program_cast | § selIdxCastTsNamedBySel317 | fullname / EQ 109 / EQ 109 | fullname / EQ 108 / EQ 108 |
| VD/vd08_bind_cast | § selIdxCastTsNamedBySel317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VD/vd09_nested_cast | § castTsInIdxNamedByChain317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VD/vd10_cast_of_sel | § castTsInIdxNamedByChain317 | fullname / EQ 124 / EQ 124 | fullname / EQ 123 / EQ 123 |
| VD/vd11_mod_positional_cast | § selIdxCastTsNamedBySel317 | fullname / EQ 97 / EQ 97 | fullname / EQ 95 / EQ 95 |
| VD/vd12_typedef_cast | § castTsInIdxNamedByChain317 | fullname / EQ 142 / EQ 142 | fullname / EQ 141 / EQ 141 |
| VD/vd13_mod_cast_two_children | § selIdxCastTsNamedBySel317 | fullname / EQ 148 / EQ 148 | fullname / EQ 149 / EQ 149 |
| VD/vd14_iface_child_of_mod_cast | § selIdxCastTsNamedBySel317 | fullname / EQ 182 / EQ 182 | fullname / EQ 181 / EQ 181 |
| VD/vd15_cast_ips_mod | § modConnIpsBaseByPort317 | fullname / EQ 108 / EQ 108 | fullname / EQ 106 / EQ 106 |
| VD/vd16_cast_in_2d_mod | § modConnIdxNestedNames317 | fullname / EQ 134 / EQ 134 | fullname / EQ 131 / EQ 131 |
| VD/vd17_iface_array_elem_cast | § selIdxCastTsNamedBySel317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VD/vd19_mod_cast_param_operand | § selIdxCastTsNamedBySel317 | stage 1 / stage 1 / stage 1 | fullname / fullname / fullname |
| VD/vd20_mod_two_dim_cast | § selIdxCastTsNamedBySel317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VD/vd21_iface_port_of_mod_cast | § selIdxCastTsNamedBySel317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VD/vd22_nested_mod_cast | § selIdxCastTsNamedBySel317 | fullname / EQ 250 / EQ 250 | fullname / EQ 251 / EQ 251 |
| VD/vd23_mod_cast_signed_ctl | § selIdxCastTsNamedBySel317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VD/vd24_forgen_mod_cast | § selIdxCastTsNamedBySel317 | stage 1 / EQ 167 / EQ 167 | stage 1 / EQ 168 / EQ 168 |

**VE**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VE/ve01_three_level_sel | § ifaceHcIdxSelByInst317 | fullname / fullname / EQ 141 | fullname / fullname / EQ 140 |
| VE/ve02_sel_plus_one | § ifaceHcIdxSelByInst317 | fullname / EQ 122 / EQ 122 | fullname / EQ 121 / EQ 121 |
| VE/ve03_sel_opidx_inner | § ifaceHcIdxSelByInst317 | fullname / fullname / EQ 134 | fullname / fullname / EQ 133 |
| VE/ve04_mod_top_nested_sel | § modConnIdxNestedNames317 | EQ 102 / EQ 102 / EQ 102 | EQ 100 / EQ 100 / EQ 100 |
| VE/ve05_mod_forgen_nested | § modConnIdxNestedNamesGen317 | col / EQ 173 / EQ 173 | col / EQ 174 / EQ 174 |
| VE/ve06_unpacked_in_idx | § ifaceHcIdxSelByInst317 | fullname / EQ 131 / EQ 131 | fullname / EQ 130 / EQ 130 |
| VE/ve07_param_override | § ifaceHcIdxSelByInst317 | fullname / EQ 143 / EQ 143 | fullname / EQ 142 / EQ 142 |
| VE/ve08_tern_nested_sel | § ifaceHcIdxSelByInst317 | fullname / EQ 143 / EQ 143 | fullname / EQ 141 / EQ 141 |
| VE/ve09_mod_two_nested | § modConnIdxNestedNames317 | fullname / EQ 110 / EQ 110 | EQ 108 / EQ 108 / EQ 108 |
| VE/ve10_gen_iface_nested | § ifaceHcIdxSelByInst317 | col / EQ 125 / EQ 125 | col / EQ 140 / EQ 140 |
| VE/ve11_mod_param_nested | § modConnIdxNestedNames317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VE/ve12_mod_nested_concat | § modConnIdxNestedNames317 | fullname / EQ 129 / EQ 129 | EQ 127 / EQ 127 / EQ 127 |
| VE/ve13_mod_three_level | § modConnIdxNestedNames317 | fullname / fullname / EQ 142 | EQ 139 / EQ 139 / EQ 139 |
| VE/ve14_mod_opidx_inner | § modConnIdxNestedNames317 | fullname / fullname / EQ 135 | fullname / fullname / EQ 132 |
| VE/ve15_gen_three_level | § defGenSelInIdxLeaf317 | col / fullname / EQ 148 | col / fullname / EQ 164 |
| VE/ve16_gen_opidx_inner | § defGenSelInIdxLeaf317 | col / fullname / EQ 141 | col / fullname / EQ 158 |
| VE/ve17_top_three_level | § ifaceHcIdxSelByInst317 | fullname / fullname / EQ 135 | fullname / fullname / EQ 134 |
| VE/ve18_top_opidx_inner | § ifaceHcIdxSelByInst317 | fullname / fullname / EQ 128 | fullname / fullname / EQ 127 |
| VE/ve19_mod_gen_three_level | § modConnIdxNestedNamesGen317 | col / fullname / EQ 146 | col / EQ 144 / EQ 144 |
| VE/ve20_mod_refidx_inner | § modConnIdxNestedNames317 | fullname / EQ 131 / EQ 131 | fullname / EQ 128 / EQ 128 |
| VE/ve21_sel_in_opidx_inner_sel | § ifaceHcIdxSelByInst317 | fullname / fullname / EQ 156 | fullname / fullname / EQ 154 |
| VE/ve22_program_nested_op | § modConnIdxNestedNames317 | fullname / EQ 120 / EQ 120 | fullname / EQ 119 / EQ 119 |
| VE/ve23_four_level | § nestSelChainName317v | fullname / fullname / EQ 175 | fullname / fullname / EQ 173 |
| VE/ve24_gen_four_level | § nestSelChainName317v | col / fullname / EQ 171 | col / fullname / EQ 188 |
| VE/ve25_mod_top_three_level | § nestSelChainName317v | EQ 125 / EQ 125 / EQ 125 | EQ 123 / EQ 123 / EQ 123 |
| VE/ve26_two_inner_refidx | § nestSelChainName317v | fullname / EQ 181 / EQ 181 | fullname / EQ 178 / EQ 178 |
| VE/ve27_cast_in_inner | § nestSelChainName317v | fullname / fullname / EQ 156 | fullname / fullname / EQ 154 |
| VE/ve28_mod_inner_xor | § nestSelChainName317v | fullname / EQ 135 / EQ 135 | fullname / EQ 132 / EQ 132 |
| VE/ve29_gen_two_inner_refidx | § nestSelChainName317v | col / EQ 176 / EQ 176 | col / EQ 195 / EQ 195 |
| VE/ve30_mod_gen_opidx_inner | § nestSelChainName317v | col / fullname / EQ 151 | col / fullname / EQ 149 |

**VF**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VF/vf01_3d_op | § ifaceHcVarSelByInst317 | fullname / EQ 140 / EQ 140 | fullname / EQ 138 / EQ 138 |
| VF/vf02_2d_right | § ifaceConnLeafVarSel317 | fullname / EQ 129 / EQ 129 | fullname / EQ 127 / EQ 127 |
| VF/vf03_2d_both | § ifaceConnLeafVarSel317 | fullname / EQ 134 / EQ 134 | fullname / EQ 131 / EQ 131 |
| VF/vf04_unpacked_2d | § ifaceHcVarSelByInst317 | fullname / EQ 134 / EQ 134 | fullname / EQ 132 / EQ 132 |
| VF/vf05_gen_2d | § ifaceHcVarSelByInst317 | stage 1 / stage 1 / stage 1 | fullname / EQ 140 / EQ 140 |
| VF/vf06_mod_sys_2d_two | § modConnLeafVarSel317 | fullname / EQ 118 / EQ 118 | fullname / EQ 114 / EQ 114 |
| VF/vf07_mod_2d_top | § modConnLeafVarSel317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VF/vf08_sel_in_2d_idx | § ifaceHcVarSelByInst317 | fullname / EQ 143 / EQ 143 | fullname / EQ 142 / EQ 142 |
| VF/vf09_2d_top_iface | § ifaceHcVarSelByInst317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VF/vf10_mod_2d_tern | § modConnLeafVarSel317 | fullname / EQ 125 / EQ 125 | fullname / EQ 122 / EQ 122 |
| VF/vf11_mod_2d_gen | § modConnLeafVarSel317 | fullname / EQ 123 / EQ 123 | fullname / EQ 121 / EQ 121 |
| VF/vf12_2d_inner_opidx | § ifaceHcVarSelByInst317 | fullname / fullname / EQ 156 | fullname / fullname / EQ 154 |
| VF/vf13_2d_inner_three | § nestSelChainName317v | fullname / fullname / EQ 163 | fullname / fullname / EQ 161 |
| VF/vf14_mod_2d_inner_opidx | § nestSelChainName317v | fullname / fullname / EQ 146 | fullname / fullname / EQ 143 |

**VG**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VG/vg01_desc_ips | § modConnIpsBaseByPort317 | fullname / EQ 103 / EQ 103 | fullname / EQ 100 / EQ 100 |
| VG/vg02_opbase_plus | § modConnIpsBaseByPort317 | fullname / EQ 117 / EQ 117 | fullname / EQ 115 / EQ 115 |
| VG/vg03_selbase | § modConnIpsBaseByPort317 | fullname / EQ 104 / EQ 104 | EQ 102 / EQ 102 / EQ 102 |
| VG/vg04_localparam_base | § modConnIpsBaseByPort317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VG/vg05_gen_ips | § modConnIpsBaseByPort317 | fullname / EQ 107 / EQ 107 | fullname / EQ 105 / EQ 105 |
| VG/vg06_instarray_ips | § modConnIpsBaseByPort317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VG/vg07_program_ips | § modConnIpsBaseByPort317 | fullname / EQ 106 / EQ 106 | fullname / EQ 105 / EQ 105 |
| VG/vg08_ips_and | § modConnIpsBaseByPort317 | fullname / EQ 119 / EQ 119 | fullname / EQ 116 / EQ 116 |
| VG/vg09_bind_ips | § modConnIpsBaseByPort317 | fullname / fullname / fullname | fullname / fullname / fullname |
| VG/vg10_int_var_base | § modConnIpsBaseByPort317 | fullname / EQ 96 / EQ 96 | fullname / EQ 91 / EQ 91 |
| VG/vg11_positional_ips | § modConnIpsBaseByPort317 | col / col / col | col / col / col |
| VG/vg12_iface_ips_top | § modConnIpsBaseByPort317 | EQ 113 / EQ 113 / EQ 113 | EQ 111 / EQ 111 / EQ 111 |
| VG/vg13_nested_mod_ips | § modConnIpsBaseByPort317 | fullname / EQ 169 / EQ 169 | fullname / EQ 166 / EQ 166 |
| VG/vg14_ips_paren_base | § modConnIpsBaseByPort317 | fullname / EQ 103 / EQ 103 | fullname / EQ 100 / EQ 100 |
| VG/vg16_ips_in_op_gen_mod | § modConnIpsBaseByPort317 | fullname / EQ 123 / EQ 123 | fullname / EQ 121 / EQ 121 |
| VG/vg17_ips_tern | § modConnIpsBaseByPort317 | fullname / EQ 123 / EQ 123 | fullname / EQ 120 / EQ 120 |

**VH**

| case | law (first line) | default P / L / F | elaborated P / L / F |
|---|---|---|---|
| VH/vh01_forgen_genvar_inner | § defGenSelInIdxLeaf317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VH/vh02_param_inner | § defGenSelInIdxLeaf317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VH/vh03_two_nested | § defGenSelInIdxLeaf317 | col / EQ 117 / EQ 117 | col / EQ 133 / EQ 133 |
| VH/vh04_sys_or_sys | § defGenSysInOpLeaf317 | stage 1 / EQ 118 / EQ 118 | col / EQ 135 / EQ 135 |
| VH/vh05_sys_op_arg | § defGenSysInOpLeaf317 | stage 1 / EQ 97 / EQ 97 | EQ 114 / EQ 114 / EQ 114 |
| VH/vh06_cast_spaces | § defGenCastInIdxLeaf317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VH/vh07_cast_plus_one | § defGenCastInIdxLeaf317 | stage 1 / EQ 123 / EQ 123 | stage 1 / EQ 142 / EQ 142 |
| VH/vh08_cast_of_sel | § defGenCastInIdxLeaf317 | col / EQ 121 / EQ 121 | col / EQ 139 / EQ 139 |
| VH/vh09_macro_idx | § defGenSelInIdxLeaf317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VH/vh10_casegen_nested | § defGenSelInIdxLeaf317 | col / EQ 146 / EQ 146 | col / EQ 161 / EQ 161 |
| VH/vh11_unpacked_inner | § defGenSelInIdxLeaf317 | col / EQ 138 / EQ 138 | col / EQ 153 / EQ 153 |
| VH/vh12_mod_child_nested_sel | § defGenSelInIdxLeaf317 | col / EQ 123 / EQ 123 | col / EQ 121 / EQ 121 |
| VH/vh13_mod_child_cast | § defGenCastInIdxLeaf317 | stage 1 / EQ 111 / EQ 111 | stage 1 / EQ 109 / EQ 109 |
| VH/vh14_sys_tern_cond | § defGenSysInOpLeaf317 | stage 1 / EQ 124 / EQ 124 | col / EQ 142 / EQ 142 |
| VH/vh15_crlf_nested | § defGenSelInIdxLeaf317 | col / EQ 125 / EQ 125 | col / EQ 140 / EQ 140 |
| VH/vh16_sys_in_op_mod_child | § defGenSysInOpLeaf317 | col / EQ 126 / EQ 126 | col / EQ 124 / EQ 124 |
| VH/vh17_def_escaped_base | § defGenSelInIdxLeaf317 | col / name / EQ 125 | col / name / EQ 140 |
| VH/vh18_def_cast_inner_spaces | § defGenCastInIdxLeaf317 | stage 1 / EQ 133 / EQ 133 | stage 1 / EQ 152 / EQ 152 |
| VH/vh19_def_nested_sel_spaces | § defGenSelInIdxLeaf317 | col / stage 1 / EQ 125 | col / stage 1 / EQ 140 |
| VH/vh20_def_sys_nested_call_op | § defGenSysInOpLeaf317 | stage 1 / EQ 118 / EQ 118 | stage 1 / EQ 135 / EQ 135 |
| VH/vh21_def_param_width_cast | § defGenCastInIdxLeaf317 | stage 1 / stage 1 / stage 1 | stage 1 / stage 1 / stage 1 |
| VH/vh22_def_sys_two_arg_op | § defGenSysInOpLeaf317 | EQ 118 / EQ 118 / EQ 118 | EQ 134 / EQ 134 / EQ 134 |
| VH/vh23_def_bin_select_based | § defGenSelInIdxLeaf317 | col / EQ 133 / EQ 133 | col / EQ 151 / EQ 151 |
| VH/vh24_def_nested_refidx_spaces | § defGenNestSelIdxTrim317v | col / stage 1 / EQ 137 | col / stage 1 / EQ 153 |
| VH/vh25_def_nested_opidx_spaces | § defGenNestSelIdxTrim317v | col / col / EQ 141 | col / col / EQ 158 |
| VH/vh26_def_nested_trailing_space | § defGenNestSelIdxTrim317v | col / stage 1 / EQ 125 | col / stage 1 / EQ 140 |
| VH/vh27_def_escaped_plain_ctl | § defGenNestSelEscBase317v | name / name / name | name / name / name |
| VH/vh28_mod_escaped_nested | § defGenNestSelEscBase317v | fullname / EQ 129 / EQ 129 | fullname / EQ 127 / EQ 127 |
| VH/vh29_def_escaped_nested_modchild | § defGenNestSelEscBase317v | col / name / EQ 123 | col / name / EQ 121 |

## Residues (ranked; all wrong on pristine too, none moved away under the fix)

1. **A var_select as the whole actual** (ModuleEmit; the var_select twin of the bit_select whole-actual naming).
   - VF/vf09 `.clk(m[s][1])`: golden names s `work@top.u.clk.m.s`, ours `work@top.m.s`.
   - vf07 and vd20 are the module-child twins (`work@top.c.d.m.s`, and the cast typespec `work@top.c.d.m`).
   - § ifaceHcVarSelByInst317 and § modConnIdxNestedNames317 reach a var_select operand only.
2. **The operand of a `signed'(...)` cast in an index** (vd02 `ck[signed'(s)] | ck[1]`, golden
   `work@top.u.clk.ck.s`, ours `work@top.ck.s`; the module twin vd23). The cast laws name the typespec only.
3. **Definition-view generate shapes `mkIdxTx9` does not build:**
   - a parameter-width cast `W'(s)` (vh21, stage 1);
   - blanks around a cast `ck[ 2'(s) ]` (vh06, stage 1);
   - a macro-born index (vh09);
   - a parameter `K[0]` or genvar `k[i]` inner select (vh02, vh01: stage 1 at the same heads as the for-generate
     `g[0]` hier_path or the folded parameter);
   - a system call in an index (vb11 `$bits(s)`, va11 `$unsigned(l)`, vb13 `$size(ck)`);
   - a parameter index golden folds (va10, vb01, vb12).
4. **Pass 139's instance-array prefix** (vg06): the `walk139` prefix of an instance-array child is
   `work@top..d`, so the law's base names inherit `work@top..d.s`. Golden is `work@top.c[0].d.s`, and pristine's
   own ips name is `work@top..d.v`.
5. **A generate-block local beside a hierarchical operand** (va09 `.clk(l & g.l)` in g.h with l declared in h):
   the binding now matches golden (the stage-1 head is cleared), but golden stores `work@top.g.h.u.clk.l` on the
   leaf where ours stores none (fullname, 2 records).
6. **Stage-1 shapes at module scope, not decoded:**
   - a nested cast `ck[2'(3'(s))]` (vd09, head the outer cast operation at 6:21..6:26);
   - a cast index into an instance-array child (vd06, head a logic_net binding);
   - an interface-array element and an interface port (vd17, vd21, unmoved).

   vd01 `ck[W'(s)]` is headed by the parameter-width cast's integer_typespec. That is pass 315's VK/vk07
   sister-ground face (ExprEmit), reported, not written.
7. **The bind naming** (vd08, vg09; golden `work@top.t.cb.*`, ours `work@top.cb.*`) and the positional indexed part
   select's column (vg11, EQUIVALENT downstream on all binaries).
8. **The implementer's residues** stand as its README ranks them: pass 315's definition-view generate leftovers,
   the part select, `signed'` and `%` index shapes, the interface array fed an operation (VR/r06), and the
   parameter ips base (CM/m20). They also include pass 313's and 315's other faces.

The one sister-ground face is vd01's parameter-width cast typespec (ExprEmit, pass 315's vk07). Every other site above is in ModuleEmit.

## Process

- **The VERIFIER'S SLIP, no effect.** One decode loop ran `$UHDM_DUMP` in a shell where the environment had not been
  sourced, with stderr sent to /dev/null. Three golden databases and three law databases of this dir's
  VG/vg06, VG/vg04 and VE/ve11 were each executed as a shell script inside the golden store under this verifier's
  scratch.
  - Each stopped at "command not found" and a syntax error.
  - A search of the scratch, the worktree and the main tree right after found no file written; the main tree was
    clean.
  - Every later dump went through a guarded wrapper that refuses to run unless the variable names an executable.
- **The fix binary was rebuilt once** before any gate measurement. A first fix build differed only in when
  § nestSelChainName317v judges a text plain (now on the trimmed text, so each refinement is droppable alone). Its
  census was stopped through its own process group, after this pass's name was checked on its command line. Every
  number above is on the frozen 24f04f6e build.
- **Discarded runs.** A first pristine sweep ran before uhdm-strictcmp was in the worktree's build dir and wrote no
  csv; it was rerun with STRICT_CMP exported. One draft case, VA/va05, referenced genblk1 (slang rejects it) and
  was rewritten before any counting. vd18 (an out-of-range constant cast, exit 3 on every binary) was dropped.
- **Fence.** Every helper reads $FENCED fail-closed, and every tree scan filtered its path list before opening a
  file. The fence scan of the patch reads 0 for all four names.
- **Scope.** Nothing was written outside /tmp/wt_v11u317, /tmp/wt_v11u317pris and /tmp/v11u317_*. No other agent's
  process was listed or touched.

# v11u319 — adversarial verification of r11u319 (the whole-actual select laws, the system call in an index, the leaf rule on whole-select actuals, the definition-view generate index builder)

Base 0fe8b3bb (pass 317). Ground: module/type (src/ModuleEmit.cpp only). **Verdict: ACCEPT WITH THREE REFINEMENTS.**
The implementer's twelve laws are carried byte-identical. Every headline number of r11u319repro reproduces bit for
bit. Fresh cases found three breaks on legal SV, where pristine was right or nearer to golden and the law moved away:

- one in the leaf rule, a binding moving away from golden;
- two in the `%` builder, where the uhdm-dump distance to golden grows and uhdm-cmp grows on a stage-1 case-view.

Each break is fixed behind its own switch in src/ModuleEmit.cpp, read through `fixOn(319, ...)`. `R11V319_OFF`
restores the law's bytes, and every refinement sits inside its law's condition, so `R11U319_OFF` still gives
pristine's bytes.

**Gates: the fix moves no gate database.** The fix binary reads exactly the law's and pristine's gate numbers:
- probe 4017 EQUAL + 70 STRICT_NOTEQUAL, 0/0/0;
- surelog 480 + 0 / 474 + 0;
- uhdm2rtlil 803/1/67 in both modes;
- downstream 803/66/2/0, byte-identical to the committed csv;
- byteverify 0 of 3365 against both pristine and the law, and 0 of 4087 probe databases.

## Binaries (frozen before any measurement, chmod 555)

| binary | md5 | note |
|---|---|---|
| pristine (0fe8b3bb, -j 2) | 3d29c848e262fecd0cbdc507d4d05c38 | equal to the implementer's pristine |
| law (/tmp/r11u319.patch applied) | a2c33775a34dbd17110c5c24ab03a29e | equal to the implementer's law |
| fix (the verified patch) | 8666dd7efa2867ba7f5b7025f7d46331 | law + the three refinements below |
| uhdm-strictcmp / strictcmp_x | fa6e4f42f252ae0ab69d9845003e71c5 / 886f030233ecdbcce7d0e29ac0c4df2c | equal to the implementer's |

All link slang 12.0.0+545f88b2e. A first fix draft (8ad8b4ae) carried the first two refinements only. It was
measured on fresh cases only, and its successor added § defGenModParenStrip319v.

## The breaks and the refinements

**1. § vsIdxLeafThroughInnerVs319v (`R11V319_INNERVSLEAF_OFF`; both sites of § varSelIdxOwnLeaf319: emitInstance
and ifaceConnLeftmostLeafElab315).**

§ varSelIdxOwnLeaf319 gives each index of a leaf-position multi-dimension select its own leftmost leaf. Its descent
stopped at a var_select met on an index's chain, so every reference inside the inner select was rebound to the parent
DEFINITION's net. Golden treats the inner select as in the leaf position too, each of its indices with its own leaf.

The bindings below were measured with drivers/bindcls.cpp, which classes a ref_obj's vpiActual as the definition's
object or the elaborated one; the record walk does not key on it.

| case | actual | golden | pristine | law |
|---|---|---|---|---|
| VD/vd02_i_vs_in_vs_two | `.clk(m[m[s][t]][1])` | s, t ELAB | ELAB | DEF |
| VD/vd03_i_vs_in_vs_op_first | `m[m[1+s][t]][1]` | s DEF, t ELAB | — | t DEF |
| VD/vd04_i_vs_in_vs_op_second | `m[m[s][1+t]][1]` | s ELAB, t DEF | — | s DEF |
| VD/vd13_i_vs_in_vs_tern | `m[m[a ? s : t][0]][1]` | a ELAB | — | a DEF |
| VD/vd14_m_vs_in_op_first | `.d(m[m[s][0] + t][1])` | s ELAB | — | s DEF |
| VD/vd07, vd16 | `m[m[s][t]][1] & a`, `\| a` (operand forms) | s, t ELAB | — | s, t DEF |
| VN/vn24_vs_inner_vs | `m[m[s][0]][1]` | s ELAB | — | s DEF |

On VN/vn24 the strict record walk diverged (fullname(2) -> walk diverged, with the definition's logic_net listed
under the reference). The chain-keyed away census read 0 on all of these: the moved binding is not in its key.

The refinement: the leaf descent enters a var_select and takes each of its indices' own leaf.
- On the law's 32 refinement case-views it moves every one of these bindings back to golden's: binding away 0, with
  the law's toward bindings kept (vd03 s, vd04 t, vd09 s, vd13 s and t, vd14 t).
- Golden: drivers/bindcls.cpp, evidence/bind_F.txt.

**2. § defGenModLeftAssoc319v (`R11V319_MODASSOC_OFF`; emitDefGenStmts mkIdxTx9).**

`%` shares the precedence of `*` and `/` and groups to the left. The kIdxOps9 loop splits at the first `*` or `/`
before § defGenIdxModPowOp319's `%` branch is reached, so the law built `s * (2 % 3)` where golden has `(s * 2) % 3`.
Pristine wrote one ref_obj named `2 % 3` there, and was nearer to golden:

| case | index | pristine uhdm-cmp | law uhdm-cmp | dump distance (P -> L) |
|---|---|---|---|---|
| VG/vg06_mult_mod | `ck[s * 2 % 3]` | 102 | 132 | 29 -> 36 |
| VE/ve01_div_mod | `s / 2 % 3` | 102 | 132 | 29 -> 36 |
| VE/ve03_pow_mod | `2 ** s % 3` | 106 | 132 | 31 -> 42 |
| VE/ve05_mod_pow | `s % 2 ** 1` | 102 | 128 | 52 -> 57 |
| VE/ve08_mult_mod_t | `t * s % 3` | 98 | 124 | 27 -> 36 |
| VE/ve04_mod_mod | `s % 2 % 3` | 80 | 54 | — |

All of these are in a generate block. ve04 shrinks under the law but stays wrong (`s % (2 % 3)`). The heads stayed at
stage 1 with the same first record, so the strict away census read 0. The uhdm-dump distance grew on 12 case-views
(evidence/dumpdist_L.txt).

The refinement: with `%` in the text and no `+` or `-`, the LAST multiplicative operator (`**` skipped) is the top
operation.

| case-views | under the fix |
|---|---|
| vg06, ve01, ve03, ve04, ve08 (both views) | STRICT_EQUAL |
| ve05 default view | 62 lines; the head is golden's fold of `2 ** 1` to INT:2 |
| ve05 elaborated view | endcol |

Controls: VE/ve02 `s % 2 * 3` was already right and stays so; VE/ve07 `s * 2 / 3` keeps pristine's (pre-existing)
bytes.

**3. § defGenModParenStrip319v (`R11V319_MODPAREN_OFF`; mkIdxTx9).**

VG/vg03_mod_paren `ck[(s % 2)]`: golden has vpiModOp at 7:21..7:26, inside the parentheses. Pristine wrote one ref_obj
named `(s % 2)`. The law split the text at `%` into ref_objs named `(s` and `2)`. The dump distance grew 19 -> 20,
while uhdm-cmp went from 54 to 28 lines.

The refinement: a fully parenthesised index text holding `%` is built from its inside, located without the
parentheses. Both views of vg03 enter STRICT_EQUAL under the fix.

The kIdxOps9 loop's own paren and associativity blindness for `+ - * /` (`(s + 1)`, `s * 2 / 3`) is pre-existing and
untouched.

## The law reproduced (the implementer's numbers, bit for bit)

| check | result |
|---|---|
| grid (r11u319repro/drivers/grid.sh, 156 dirs, 4680 lines) | equal to evidence/grid.txt on 4680 of 4680 lines but the md5 field (a database embeds its worktree path); gridsum319.py output identical: 312 case-views, 269 moving, 239 entering, 0 leaving, OFF==P 312, the same single-switch attribution (SYSIDXNAME 72 ... VSIDXLEAF 3) and the same 91 multi-switch movers |
| away census on the 269 grid movers | lost 0, chain away 0, flat away 0, 553 toward |
| binding census (bindcls) on the 269 grid movers | away 0, toward 192 |
| the fix on the 312 grid case-views | equal to the law on 312 of 312 |
| firing scan, law binary (28591 dirs: the implementer's 28413 + this dir's 178) | outside the two pass dirs exactly the implementer's 213-dir list; nonzero exits 249 exit 3, 154 exit 4, 1 exit 139 (m07_hdr_enum_default), none in this dir |
| earlier firing dirs (the 73 outside the two pass dirs, both views) | 146 case-views, 62 moving, 29 entering, 0 leaving, the same uhdm-cmp growth on r10rgg14repro/cells/pc4 54 -> 140 (old head `arr[i % 3]` at 11:22 cleared, the new head the third instance's ternary index at 13:22, later in the walk), away 0 with 109 toward, binding away 0; the fix equal to the law on all 146 |
| gate sweeps, pristine and law (tests/sweep.sh --jobs 3, equal-length workdirs) | probe 4017 + 70, surelog 480 + 0 / 474 + 0, uhdm2rtlil 803/1/67 both modes, 0/0/0 in every stage, downstream 803/66/2/0; csv row diff law vs pristine 0 lines in all four stages; downstream csv equal to the committed one; both exit 1 on the stale law-index check alone |
| byteverify law vs pristine | 0 of 3365 (SELFCHECK 3363 of 3365, the known 1DUnpackedArray twin); probe 0 of 4087 against the pristine probe stage rerun from the law worktree |
| canaries | surelog ok=52, uhdm2rtlil ok=16, both ctcan2 PASS |
| binary audit | 3315 fence-filtered cmds.txt per sweep, 3265 naming its own binary, 0 another |
| determinism (r11u319repro/drivers/det.sh, three concurrent draws) | one hash per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg (both modes), Scoreboard and Rggen (default), equal to the sweep's, for the law and the fix |

## The fix measured (evidence/gates.txt, bytescan.txt, firing.txt)

**Firing census.** r11u319repro/drivers/tracecensus.sh ran with the FIX binary over the probe and both corpora in
both modes, filtered by $FENCED, and was frozen before the fix sweep. It wrote 0 trace files and predicted no
database. The positive control is the same binary and the same variable on vd02, vg06 and vg03: each writes its tags
(`vsIdxLeafThroughInnerVs319v`, `defGenModLeftAssoc319v`, `defGenModParenStrip319v` with `defGenIdxModPowOp319`).

**Fix gate sweep** (/tmp/v11u319_swF, equal-length workdir):
- the same numbers as pristine and the law, regressions 0, conversions 0 and changes 0 in every stage;
- csv row diff against pristine 0 lines in all four stages;
- byteverify fix vs pristine 0 of 3365 and fix vs law 0 of 3365, probe 0 of 4087;
- canaries and the binary audit as above.

**Firing scan with the fix.** The firing dirs outside this dir are the law's 213. The refinement tags fire in 21 dirs,
all of them in v11u319repro.

**Whole-tree byte scan, pristine vs fix** (drivers/bytescan.sh; every fence-filtered tools/probe dut.sv, both views,
57182 case-views):
- 0 exit-code differences; the 815 nonzero exits are equal (498 exit 3, 308 exit 4, 9 exit 139);
- 590 movers with exit 0: r11u319repro 269, this dir 259, and the 62 earlier-firing-dir movers above, exactly;
- no other dir moves.

## The attack (178 fresh case dirs, 356 case-views, both views; evidence/grid.txt, gridsum.txt)

Each case's first line names its law. Goldens come from the v1.87 Surelog with check_probe's arguments
(r11u319repro/drivers/case.sh). Every line carries rc=, and every line is rc=0. OFF (`R11U319_OFF`) equals pristine
on 356 of 356; FOFF (`R11V319_OFF`) equals the law on 356 of 356.

| configuration | moving | entering STRICT_EQUAL | leaving |
|---|---|---|---|
| law | 269 | 169 | 0 |
| fix | 259 | 181 | 0 |

The fix differs from the law on 32 case-views, each restored by exactly one refinement switch (gridsum.txt):
INNERVSLEAF 18, MODASSOC 12, MODPAREN 2.

| census | law | fix |
|---|---|---|
| strict away (away.py / awaychain.py) | lost 0, chain away 0, flat away 0, 554 toward | lost 0, chain away 0, flat away 0, 598 toward |
| uhdm-dump distance (drivers/dd.sh) | 202 closer, 55 same, **12 farther** (the `%` breaks) | 216 closer, 43 same, 0 farther |
| binding census (drivers/bindcen.sh, bindcls) | **20 bindings away** (the VD family and vn24) and 4 new objects | 0 bindings away, 243 toward, the same 4 new objects |

The 4 new objects:
- VG/vg26 `$signed(-s)` writes a ref_obj named `-s` where golden has a unary operation; uhdm-cmp 70 -> 38;
- VG/vg34 `s % P` keeps a reference P that golden folds to a constant (both views);
- both are not rebindings and are listed in the residues.

**Downstream on all 178 dirs** (drivers/dscases_v.py): no verdict moves on any binary. 169 are IDENTICAL; 9 are
EQUIVALENT on pristine, the law and the fix alike: va02, va05, vc14, vc22, ve11, ve12, vf07, vf08 and vf12.

| law | cases |
|---|---|
| § sysCallInIdxNamedBySel319 | VC/vc01 to vc07, vc09 to vc23; VE/ve09 to ve13; VA/va01 (module array), va02 (interface array), va06 |
| § ifaceHcVarSelWholeByInst319 | VN/vn04, vn05, vn06, vn07, vn11, vn13i, vn19, vn21 (CRLF), vn22; VE/ve14, ve16, ve23; VF/vf11 |
| § modConnVarSelWholeNames319 | VN/vn01 (program), vn05m, vn06m, vn07m, vn08 (positional), vn09, vn10, vn11m, vn12, vn13, vn16, vn17, vn18, vn20, vn23; VE/ve15, ve17, ve18 (non-ANSI), ve19 (case generate), ve20; VF/vf12; VA/va03, va08 (bind) |
| § ifaceConnSelWholeLeafElab319 | VB/vb13i, vb16, vb17, vb18, vb24, vb25 (modport), vb26 (positional), vb27; VE/ve22; VF/vf01, vf03, vf05, vf07, vf09, vf13, vf15; VA/va05 |
| § modConnSelWholeLeafElab319 | VB/vb01 to vb15, vb19; VE/ve21; VF/vf02, vf04, vf06, vf08, vf10, vf14, vf16; VA/va04, va07 (bind) |
| § varSelIdxOwnLeaf319 | VB/vb20 to vb23 |
| § vsIdxLeafThroughInnerVs319v | VD/vd01 to vd16, VN/vn24 |
| § defGenSysInIdxLeaf319 | VG/vg11 to vg18, vg23 to vg27, vg30, vg32, vg35, vg37, vg38; VE/ve24 |
| § defGenVarSelIdxExpr319 | VG/vg20, vg21, vg39 |
| § defGenIdxModPowOp319 | VG/vg01, vg02, vg04, vg05, vg07 to vg10, vg19, vg22, vg28, vg31, vg33, vg34, vg36, vg40; VE/ve06 (control) |
| § defGenModLeftAssoc319v | VG/vg06; VE/ve01 to ve05, ve07 (control), ve08 |
| § defGenModParenStrip319v | VG/vg03 |

## Residues (ranked; all wrong on pristine too, none moved away under the fix)

1. **Names below a nested select inside a whole-actual multi-dimension select.** The VD family and vn24 read fullname
   on every binary: golden names `m[m[s][0]][1]`'s inner select `work@top.u.clk.m.m`, ours `work@top.m.m`.
   ifaceHcIdxSelByInst317 has no var_select branch. ModuleEmit; the next law on this ground.
2. **The definition-view index builder's remaining shapes** (ModuleEmit emitDefGenStmts):
   - a unary operand in a call argument (VG/vg26 `$signed(-s)`);
   - blanks around an operation index (VG/vg19 `ck[ s % 2 ]` and the pre-existing control VE/ve06 `ck[ s + 2 ]`, a
     col head on every binary);
   - a `%` index of a whole-actual multi-dimension select (VG/vg39 `m[s % 2][t]`: the § defGenVarSelIdxExpr319
     character set has no `%`);
   - a genvar index in a for-generate (VG/vg22 and VN/vn19, whose stage-1 head is the `g[0]` path before the index);
   - a macro-born call index (VG/vg27);
   - the pre-existing `+ - * /` paren and associativity blindness (VE/ve07);
   - the implementer's residue 2 (GV/i04, m04, m19, pc4's ternary, the two-argument call, pass 317's vh21, vh09,
     vh02/vh01, VR/r10).
3. **Folds Surelog makes and we do not:** a parameter in an index (VG/vg34 `s % P`, VN/vn06 `m[s][P]`, VC/vc14
   `$signed(P)`, VF/vf15 `P + s`); `2 ** 1` (VE/ve05); `$size(m)` (VC/vc05); `$high(ck)` located at the declaration
   in golden (VG/vg25).
4. **Struct-member, user-call and unpacked-array shapes at stage 1 on every binary** (VF/vf01 to vf04, vf07, vf08,
   vf11, vf12, VN/vn11, VE/ve09 to ve13). A user call's argument in an index keeps the elaborated net where golden
   binds the definition's (VF/vf08 s): the leaf walk does not enter a user call.
5. **The bind naming** (VC/vc21, VA/va07, va08): golden names through the bind target's instance,
   `work@top.t0.cb.ck.s`, where the law writes `work@top.cb.ck.s` and pristine `work@top.ck.s`.
6. **Instance arrays.** The interface and module arrays (VA/va02, va04, va05) stay at stage 1 on every binary. A
   system call in a module-array or interface-array element's whole actual (VA/va01, va02) is now named
   `work@top.c[0].ck.s` as golden has it: § sysCallInIdxNamedBySel319's hcSelIdxRescope168 site does not stand aside
   there, and it is right not to.
7. The implementer's residues 1, 3, 4 and 5 and pass 317's stand as listed in r11u319repro/README.md.

## Sister-ground faces (ExprEmit; reported, not written)

- The folded `$bits(s)` in an elaborated index ends at the call name (VG/vg15 endcol, the implementer's vb11 face).
- The folded `$high(ck)` constant is located at the use where golden takes the declaration's range (VG/vg25 line).
- The implementer's two fold faces and pass 317's vd01 stand.

## Process

- **Main tree.** Nothing was written to the main tree; git status read clean throughout.
- **Draft cases.** Two draft cases (VN/vn14, vn15: an output port connected to a select with a variable index) were
  illegal SV, exiting 3 on both binaries. They were dropped before any counting.
- **Fail-closed refusals.** One firing-scan copy refused to start because its FENCED read path was wrong, and one
  census helper call refused with FENCED unset. Both are the fail-closed behaviour.
- **Binary-audit miscount.** The first binary-audit count read `other=6` through an ungrouped grep alternation that
  matched the word "prefix". It was recounted with the alternation grouped: 0.
- **The fence.**
  - Every scan built its path list and filtered it by $FENCED before opening a file.
  - The census, the firing scans, the byte scan and bindcls/bindcen read the fence fail-closed.
  - The fence scan of this dir is 0 for all four names.
  - No process of another agent was listed or touched.
- **Rebuilds.** The fix binaries were rebuilt with -j 1 while the law sweep ran from its frozen binary. Only the last
  fix binary (8666dd7e) ran the census, the sweep and the scans.

## Drivers

| driver | what it does |
|---|---|
| env.sh | sources r11u319repro/drivers/env.sh |
| agrid.sh | runs this dir's cases through r11u319repro's case.sh |
| gridsum.py, fixattr.py | the grid summary and the fix-versus-law attribution |
| bindcls.cpp, cc_bindcls.sh, bindcen.sh, bindrep.py | the binding census |
| dd.sh | the uhdm-dump distance |
| bytescan.sh | the whole-tree byte scan |
| firescan_tags.sh | the firing scan with tags |
| dscases_v.py | downstream verdicts |

The away census itself is r11u319repro/drivers/awaycv.sh.

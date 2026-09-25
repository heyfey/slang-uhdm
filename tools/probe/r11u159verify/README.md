# r11u159: second adversarial verification of passes 147 and 152 (verifier, measurement plus one refinement patch)

Base `73a67945` (branch matrix-1.87; its `src/` equals the pass-152 landing `78f8134a`). Worktree
`/tmp/wt_r11u159`, system-deps config, `-j 2`. This directory is the deliverable; nothing under `src/`,
`scripts/`, `results/`, `tests/` or `third_party/` is edited. The proposed refinement is [fix.patch](fix.patch)
(a `git diff 73a67945 -- src`, applies clean on 73a67945, NOT applied here). No canonicalisation patch for
`tools/uhdm-strictcmp` was handed to this pass and no comparator defect was found, so the comparator is not
edited. The slang-fenced tests are written `FENCED_n` (n = position in `$FENCED`; pass 147's `FENCED_1` is
`FENCED_2` here). Every driver that reads corpus sources or databases refuses to run without `$FENCED`
(`drivers/env.sh` builds it from RESUME.md without spelling it) and skips those names by word boundary.

**Verdict: TWO BREAKS, both refined under their own switches (fix.patch); the composition is additive with no
cancelling pair; every unmasking re-proven; the fence held; three process findings on the earlier passes'
drivers and evidence.**

1. **§ classVarInitNewDecl152v (v11u152's refinement) breaks the shallow-copy initializer.** `C c1 = new c0;`
   is Surelog's `class_new` production (`class_scope? NEW ( ( list_of_arguments ) | expression )?`,
   third_party/Surelog/grammar/SV3_1aParser.g4:1182), so golden spans the elaborated `class_var` through the
   initializer (`16:5-16:16`). The refinement only recognises slang's `NewClassExpression`, not
   `CopyClassExpression`, and puts the handle back at its name (`16:5-16:7`). Downstream: IDENTICAL under the
   implementer's law, EQUIVALENT (`nohier` differs: the src attribute) under the refinement. Cases
   `cv/v01_copy_new`, `cv/v10_copy_new_only`. Refinement **§ classVarInitCopyNew159v**, switch
   `R11V159_CLSVARCOPY_OFF`.
2. **§ packedElemAliasTypedef152 breaks every non-package enum alias.** The law names a packed array's element by
   the alias typedef object. For a PACKAGE alias that object is golden's (Surelog's alias typedef is a clone of
   the aliased enum renamed, the enum's span plus `Typedef_alias`: ElaborationStep.cpp:201-208 in
   `bindTypedefs_`, CompileType.cpp:881-894), but a MODULE, `$unit` or INTERFACE alias
   (`typedef lp::tx_e my_t; my_t [0:0] w;`) is still our own object at its declaration span without the alias
   reference. The law moves the element's span away from golden (`6:3-6:25` for golden's `3:4-3:51`), and in an
   interface the plugin then reads the variable **32 bits wide where golden's is 4** (`wire width 32 \b.w`, case
   `ea/e08_iface_alias`: downstream IDENTICAL -> EQUIVALENT). Cases `ea/e02 e04 e05 e07 e08`; the implementer's
   own grid case `r11u152repro/cases/EA/e03_local_alias` has the same shape (read there as an unmoved stage-1
   control). Refinement **§ elemAliasPkgScope159v**, switch `R11V159_ELEMALIAS_OFF`: the law fires only for an
   alias declared in a package.

## 1. Binaries (frozen `chmod 555` before any measurement)

| binary | md5 | what |
|---|---|---|
| `/tmp/r11u159_bin/law.bin` | `3b033b63958f68a1837d254512b79a3e` | worktree build of 73a67945 = the main tree's `build/slang-uhdm` (both landings on) |
| `/tmp/r11u159_bin/uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |
| `/tmp/r11u159_bin/pre89d.bin` | `1b89f73ee8704d8bb4979a668115366c` | build of `89d599ef` (the commit before pass 147 landed) |
| `/tmp/r11u159_bin/b6a147.bin` | `0b3b2d0a323c79f91d52be50e5bff788` | build of `b6af876c` (pass 147 landed, pass 152 not) |
| `/tmp/r11u159_bin/fix.bin` | `6dc4aab88e16f6e83302720c74dd53ea` | 73a67945 + fix.patch (a comment-only rebuild reproduces the md5) |
| `alloff.sh` / `off147.sh` / `off152.sh` | wrappers | law.bin with `R11U147_OFF R11U151_OFF R11V147_GCABARE_OFF` (+ `R11U152_OFF R11V152_CLSVARNEW_OFF`) / 147's set / 152's set |

Every `cmds.txt` names its sweep's binary or wrapper by path.

## 2. Gate sweeps (`tests/sweep.sh --jobs 3`, `GOLDEN_DEFER` unset; `evidence/sweep_*.log`, `evidence/sweeps_summary.txt`)

| sweep | binary | probe EQUAL / SN, reg/conv/chg | surelog reg/conv/chg | uhdm2rtlil reg/conv/chg | downstream |
|---|---|---|---|---|---|
| L | law.bin (HEAD) | 2491 / 1596, 0/0/0 | 0/0/0 | 0/0/0 | 803 / 66 / 2, not excused 0 |
| A | alloff.sh | 2390 / 1697, 101/0/98 | 22/0/24 | 44/0/24 | 803 / 66 / 2 |
| X | off147.sh (152 alone) | 2436 / 1651, 55/0/33 | 4/0/18 | 30/0/10 | 803 / 66 / 2 |
| Y | off152.sh (147 alone) | 2445 / 1642, 46/0/65 | 18/0/8 | 18/0/22 | 803 / 66 / 2 |
| P | pre89d.bin | = A | = A | = A | = A |
| Q | b6a147.bin | = Y | = Y | = Y | = Y |
| F | fix.bin (through drivers/tracewrap.sh) | 2491 / 1596, 0/0/0 | 0/0/0 | 0/0/0 | 803 / 66 / 2 |

L reads the committed baselines exactly: surelog 417+416 CMP_EQUAL + 63+58 STRICT_NOTEQUAL (judge-equal 480/474),
uhdm2rtlil 736+736 + 67+67 (803 judge-equal per mode), downstream csv equal to
`results/downstream_uhdm2rtlil.csv` on every column. Every sweep's only other red is `law index STALE`, which is
environmental: regenerating the index at 73a67945 changes one line, the commit count (`1040 -> 1046`, the
commits after the index was written). The downstream csvs of A, X, Y, P and F equal L's on every column.

**Switch completeness.** A (HEAD with both landings switched off) against P (the pre-147 build): csvs identical
(surelog modulo the LowMem log path), probe databases 0 / 4087 byte movers, corpus
`PATH_SETS_IDENTICAL (2560 paths)`, `MOVERS: 6 / 2560` (SELFCHECK 2559/2560), all six the UVM coin (MiniAmiq,
SeqDriver, SimpleUVM d/t: 4 order-blind lines `UINT` / `vpiDecompile`, evidence/coin_alloff_vs_89d599ef.txt).
Y (HEAD with 152 off) against Q (the b6af876c build): csvs identical, probe 0 movers, corpus 6 / 2560, UVM coin
only (Scoreboard d 0 order-blind lines, the others 4). So `R11U147_OFF` + `R11U152_OFF` restore the pre-landing
bytes exactly, and `R11U152_OFF` restores pass 147's landed bytes exactly. (Byte comparisons run on hard-link
mirrors of the sweeps with the 8 fenced row-mode databases left out: drivers/bvmirror.sh.)

Canaries on L: `canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `EXPECT_UNKNOWN=1 ctcan2.sh`
surelog ok=58 changed=0 PASS; `EXPECT_UNKNOWN=6 ctcan2.sh` uhdm2rtlil ok=2 changed=0 PASS (evidence/canaries_head.txt).

## 3. Fresh cases per law (`cases/`, 136 cases; evidence/grid_default.txt, grid_elabuhdm.txt, law_tables.md)

Each case's first line names its law(s). `drivers/grid.py` runs, on law.bin, ON, the case's own switch(es),
every pair of own switches (composition cases) and ALLOFF, in the default probe mode and with
`-elabuhdm` / `--elabuhdm` (`EL=1`), with goldens from the pinned Surelog (check_probe's arguments). Score per
law (ON against own-switch-off): TOWARD (the strict records off had, none new), AWAY / MIXED (a strict record
on has that off had not), STAGE1-x (either state is stage 1: order-blind dump distance to golden decides),
UNFIRED (same bytes). Downstream per case: drivers/dscase.py (the harness's `one()`), states ON, OWN, ALLOFF
(evidence/downstream_cases_*.txt).

| law | fresh cases (fired) | toward / same | away or mixed (adjudicated) | downstream moved |
|---|---|---|---|---|
| § ifaceMemberTrailIdxNamesByPath147 | 6 (4) | 3 / 1 | 0 | none |
| § vsIpsBaseNamesByIps147 | 4 (3) | 3 / 0 | 0 | none |
| § lvIdxBitSelAtIndex147 | 5 (3) | 3 / 0 | 0 | none |
| § nestedDefaultPatLoc147 | 4 (4) | 4 / 0 | 0 | none |
| § gcaUseSiteParamConst147 | 8 (3) | 3 / 0 | 0 (unfired shapes: nested loop, loop in if, child override, composition; all golden-equal or stage 1) | none |
| § gcaBareBoundKeepsInst147v | 3 (2) | 2 / 0 | 0 | none |
| § firstOrderedConnBitSelWhole147 | 4 (3) | 3 / 0 | 0 | none |
| § memberEnumCloneKeepsBase147 | 5 (4) | 1 / 0 | 3 dump-only: `mec/m01` stage 1 -> STRICT_EQUAL, `m02` stage 1 -> judge-equal, `cx/x04` stage 1 unmasked to the next head (`{ea::Busy, ea::Idle}` fold); the extra dump lines are the per-use copy's content (typespec identity, pass 147's own reading) | none |
| § enumQualDefaultDefSpan147 | 5 (5) | 5 / 0 | 0 | none |
| § pkgTdCastTargetOwnView151 | 3 (3) | 0 / 3 | 0 (identity rebinding, dump-invisible; all stage 1 on another face) | none |
| § blockLhsVarSelBindsWholeRef151 | 3 (3) | 3 / 0 | 0 | none |
| § nonblockingSelLhsBindsWholeRef151 | 2 (2) | 2 / 0 | 0 | none |
| § condTakenParamRhsShared151 | 3 (3) | 3 / 0 | 0 | `g/c01 c02` DIVERGENT -> IDENTICAL, `c03` EQUIVALENT -> IDENTICAL |
| § concatArrParamDefTs151 | 2 (2) | 2 / 0 | 0 | none |
| § patLeftoverOrphanCopy151 | 2 (2) | 2 / 0 | 0 | none |
| § hierSizeCastBaseStructTs151 | 2 (2) | 2 / 0 | 0 | `dd/x02` EQUIVALENT -> IDENTICAL |
| § nestedPatOpTsNoParent151 | 5 (5) | 2 / 1 | 2 dump-only (`c3n/n02`, `cx/x01`): the law's own objects checked one by one match golden (unparented `ref_typespec` under the param_assign's nested op); the distance grows only because golden holds extra `work@top` copies elsewhere | none |
| § portConnParamFoldAtActual152 | 9 (8) | 7 / 0 | 1: `pc/q06_positional_ctl` = v11u152's residue 4 (a positional actual: golden keeps a `ref_obj`, ours a fold; stage 1 both) | none |
| § genLpOperandTsNoParent152 | 6 (6) | 6 / 0 | 0 | none |
| § crossPkgFoldTsNameOnChain152 | 3 (2) | 2 / 0 | 0 | none |
| § tpElemPatAtUser152 | 6 (4) | 4 / 0 | 0 (`tp/t03` bytes only, strict equal both: the per-use copy's dump artefact v11u152 recorded) | none |
| § pkgElemMemberPatNoLoc152 | 3 (3) | 3 / 0 | 0 | none |
| § packedElemAliasTypedef152 | 10 (10) | 3 / 1 | **6: BREAK** `ea/e02 e04 e05 e07 e08` (above); `ea/e03_member` is an unmasking (off walk diverged, on aligned: the `lp::lp::tx_t` naming face) | **`ea/e08` IDENTICAL -> EQUIVALENT** |
| § tpOvrTypedefStructSpan152 | 6 (4) | 4 / 0 | 0 | none |
| § genCaseItemUnnamed152 | 3 (3) | 3 / 0 | 0 | none |
| § delayLiteralValueText152 | 4 (3) | 2 / 0 | 1: `dv/d01_multi_assign` (`assign #0.1 b = a, c = ~a;`): ours attaches the delay to BOTH net assignments, golden to the first only (the integer control `d04` shows the extra object pre-exists); the law gives that extra object `UINT:0.1` like the first. Not the law's face | none |
| § unsupportedTsInitEnd152 | 3 (2) | 2 / 0 | 0 | `cg/u01 u03` EQUIVALENT -> IDENTICAL |
| § classVarInitSpan152 | 6 (4) | 4 / 0 | 0 | `cv/s01 s02 s03 s06` EQUIVALENT -> IDENTICAL |
| § classSpecNestedAtName152 | 4 (2) | 1 / 1 | 0 | none |
| § classSpecPaNoFile152 | 3 (3) | 0 / 3 | 0 (all stage 1 on other faces) | none |
| § pkgLeafPatLocByWriting152 | 4 (2) | 2 / 0 | 0 | none |
| § classVarInitNewDecl152v | 12 (4) | 2 / 0 | **2: BREAK** `cv/v01 v10` (above) | **`cv/v01 v10` IDENTICAL (law) -> EQUIVALENT (refinement)**; `v02 v04` EQUIVALENT -> IDENTICAL |

The `--elabuhdm` grid reads the same set, case for case (evidence/grid_elabuhdm.txt: the same AWAY/MIXED cells,
plus bytes-only TOWARD moves the elaborated walk does not list).

Shapes covered (fresh against both pairs' grids): nested interfaces, an interface-member index, escaped port and
instance names, macros, `export`, packed and unpacked struct members, ports typed by package structs,
generate-scope typedefs and localparams (named if, case, nested loops), interfaces holding parameters and
typedefs, type-parameter defaults with two packed dims, element overrides and package elements, union and nested
struct overrides, case-generate items with label lists, in interfaces and with declarations, multi-assignment
and concatenation-lhs delays, covergroups in generate blocks, `var`/`static` class handles, `new c0`,
method-call, ternary-null, typed-constructor, several declarators per declaration, class specialisations with
named arguments, nested classes, extends clauses and package typedefs, and `$unit` / interface / module-local
aliases.

Cases the tools reject: `cv/v12_copy_new_paren` (slang rc=3); two first drafts that crash Surelog (a nested
default pattern in a `localparam` and in a package parameter) were replaced by `dfp/n01_gen_block_var` and
`dfp/n04_typedef_elem`.

**Re-derivation of the two pass-147 laws nearest the fenced row (ENUMCLONE, ENUMQSPAN), on fresh cases and
Surelog's source only.** `importPackage` inserts the home package's DataType itself into the importing scope
(third_party/Surelog/src/DesignCompile/CompileHelper.cpp:162-169), and every later per-use copy is `clone_tree`,
which keeps the base reference and the file: `mec/m01_export` (with `export ea::*`), `m02_port_type` (a port,
no parameter) and `m03_nested_struct` go stage 1 -> STRICT_EQUAL / judge-equal / STRICT_EQUAL under
§ memberEnumCloneKeepsBase147. For § enumQualDefaultDefSpan147, `qen/q01_twice_inst`: golden's definition
listing constant `pk::C` sits at `5:38-5:42` (the qualifier with its colons) twice, the elaborated ones at
`5:38-5:43`; ON reproduces both exactly, off has all eight at `5:38-5:43`.

## 4. The refinements (fix.patch; measured, not applied)

| law | switch | site | statement |
|---|---|---|---|
| § classVarInitCopyNew159v | `R11V159_CLSVARCOPY_OFF` | ModuleEmit.cpp, `newDecl152v` | a declarator initialised by `new expr` (slang `CopyClassExpression`) counts as a `new` initializer, as Surelog's `class_new` does |
| § elemAliasPkgScope159v | `R11V159_ELEMALIAS_OFF` | TypeEmit.cpp makeTypespec, the § packedElemAliasTypedef152 gate | the alias element is taken only for an alias declared in a package |

`R11V159_TRACE=1` prints one stderr line per decision the refinement changes. Both are inside their laws' gates,
so `R11U152_OFF` still drops everything.

Measurements (fix.bin against law.bin):

- **Census first, then bytes** (evidence/fix_census_prediction.txt, written before the comparison). The fix gate
  sweep ran through drivers/tracewrap.sh. `ELEMALIAS` fires (the law would have fired and the fix declines) on
  surelog IncompFunc, LhsOp, PackedEnum, PackedEnumVar (d/t) and uhdm2rtlil AssignmentToConcatenation,
  ReturnEnumArray, latch_packed_enum_loop (d/t); `CLSVARCOPY` nowhere; probe nowhere.
- **Bytes:** corpus `MOVERS: 4 / 2560` (SELFCHECK 2559/2560, path sets identical): MiniAmiq d/t, SeqDriver d,
  SimpleUVM t, each the 4-line UVM coin (evidence/coin_fix_vs_head.txt). None of the 14 firing row-modes moves:
  there the law's alias object and the canonical scan's pick are the same object (A = L bytes on them too).
  Probe 0 / 4087. Every csv equal to L's (Tnoc d/t stay SLANG_REJECT with the wrapper's segfault text).
- **Every committed tools/probe case** (6740 `dut.sv`, this directory included, drivers/bytes.sh,
  evidence/bytes_toolsprobe_head_vs_fix.txt): 8 movers = the 7 break cases here and
  `r11u152repro/cases/EA/e03_local_alias` (module-local alias: restored to pristine bytes, stage 1 either way,
  downstream DIVERGENT on all three binaries, `wire width 64 \w` against golden's 8); 7 more cases fire with
  no byte move.
- **Grid** (evidence/fix_vs_on_all_cases.txt): fix.bin equals law.bin on 128 of 135 cases in both modes; the 7
  movers equal their own-switch-off database byte for byte. Both new switches restore law.bin's bytes.
- **Downstream** (evidence/downstream_fix_breakcases.txt): `cv/v01 v10` and `ea/e08` IDENTICAL; `ea/e02 e04 e05
  e07` DIVERGENT as on every binary (the non-package alias width face below).
- **uhdm-cmp:** no corpus row or probe case moves. On the cases `ea/e07_unit_alias` returns from 17 to 106 lines
  (pristine's head: the element is `lp::tx_e` where golden's is the `my_t` clone). That is the cost of the
  refinement. An alternative gate (package or `$unit`) keeps e07's 17 lines but leaves its span away. The real
  fix is the residue below: emit a non-package enum alias as golden's clone.

## 5. Composition of the two landings (drivers/compose.py, evidence/composition_census.txt)

Per row, v = (status, strict) under A (both off), X (152 alone), Y (147 alone), L (both):

| stage | ONLY147 | ONLY152 | BOTH (both move it) | JOINT (only together) | CANCEL (each alone moves, together back) | NONADD |
|---|---|---|---|---|---|---|
| probe | 88 (55 conv) | 111 (46 conv) | 0 | 0 | 0 | 0 |
| surelog | 20 (4 conv) | 24 (18 conv) | 2 (Earlgrey_0_1 d/t) | 0 | 0 | 0 |
| uhdm2rtlil | 28 (26 conv) | 28 (14 conv) | 12 (4 conv) | 0 | 0 | 0 |

No pair of laws cancels, and no conversion needs a law the landings did not claim. Every BOTH row is additive in
the differing-object count: Earlgrey_0_1 1747 -> 1743 (152) / 1742 (147) -> 1738; ibex_icache 193 -> 192 / 161
-> 160; ibex_compressed_decoder 134 -> 133 / 133 -> 132; ibex_decoder 21 -> 20 / 19 -> 18; ibex_multdiv_fast
102 -> 101 / 101 -> 100. The four BOTH conversions are the two rows each pass listed as its "improved, still
failing" half:
NestedStructArrayParameterInitializedByPatternPassedAsPort d/t (152's § portConnParamFoldAtActual152 fullname
4 -> 2, 147's § nestedPatOpTsNoParent151 line 2 -> 0: `CMP_EQUAL,,,equal`) and ibex_alu d/t (152's
§ crossPkgFoldTsNameOnChain152 fullname, 147's § enumQualDefaultDefSpan147 endcol:
`ibex_alu,default,CMP_EQUAL,,,equal`). So the landed totals are 147's 26 + 152's 14 + these 4 = 44 uhdm2rtlil
conversions over A; surelog 22; probe 101.

The cross-ground pairs on fresh cases (grid rows `cx/*`, every pair of own switches run): C3's two halves
(`cx/x02_nested_port_read_too`, `x03_nested_port_hier`: each half TOWARD by 2 records alone, 4 together,
STRICT_EQUAL with both; `x01` stage 1 on a pre-existing head); ENUMCLONE with ELEMALIAS (`x04`, `x05`: ELEMALIAS
closer in both, ENUMCLONE unmasks x04); GCAUSESITE / GCABARE with GENLPOPTS (`x06`, `x07`: GENLPOPTS toward,
the 147 pair unfired in a nested block, golden-equal); ENUMQSPAN with TPOVRSTRUCT (`x08`, `x09`: each closer,
distance 89 -> 71 / 85 -> 67 additive); IFTRAILIDX with TPELEMPAT (`x10`, `x11`: one law fires per case,
closer).

## 6. The unmaskings and changes (drivers/unmask.py, evidence/unmask_alloff_vs_on.txt)

Every row and probe case whose verdict differs between A and L, re-read with uhdm-strictcmp `--max 100000` on
both databases (record = field, golden text, ours text):

| stage | rows | CONVERSION | SUBSET (strict improvement) | UNMASK (off walk diverged, on aligned) | NEW | BOTH-DIVERGED | fenced (verdicts only) |
|---|---|---|---|---|---|---|---|
| probe | 199 | 101 | 67 | 29 (`r11u109repro/grid/f1`) | 1 | 1 (`p03_ready`) | 0 |
| surelog | 46 | 20 | 12 | 8 (FuncStructValSimple, StructParamFieldRange, StructParamFuncBodyFieldCompare, StructParamPatternInitCast, d/t) | 2 | 2 (FuncStructVal d/t) | 2 (`FENCED_2` d/t: `differ:file(2)` -> CMP_EQUAL) |
| uhdm2rtlil | 68 | 44 | 20 | 2 (cva6_struct_param_field d/t) | 2 | 0 | 0 |

The five NEW rows are exactly the five pass 152 named: `v11u108repro/brk/f5/b15_child_ports`, ClassTypeParam d/t,
gen_scope_typaram d/t. Paired by walk index (both walks aligned, drivers/samepair.py,
evidence/unmask_same_objects.txt) they hold **no new object**: ClassTypeParam 8 fixed + 4 re-rendered (the
specialisation `param_assign` whose file is now golden's empty one, so its next field, golden's `0:0`, reads),
gen_scope_typaram 3 fixed + 6 re-rendered (the member reference's tail moves from `x` to golden's `pair_t.x`),
b15_child_ports 2 fixed + 4 re-rendered. The BOTH-DIVERGED rows are the recorded ones: FuncStructVal testflags
is r11u151's R-D4, default and `p03_ready` diverge later.

## 7. Downstream bytes of the converted uhdm2rtlil rows (L's downstream workdir)

`<test>/surelog/*` against `<test>/slanguh/*`, every file (`.il`, `_nohier.il`, `_synth.v`, `run.ys`,
`yosys.log`) byte-identical: pass 147 latch_packed_dyn_write (`IDENTICAL,OK,OK,37,37`), multiplier
(`IDENTICAL,OK,OK,21,21`), ParameterPassedToSubmoduleOfSubmodule, array_assign; pass 152
type_param_packed_dim (`IDENTICAL,OK,OK,9,9`), LocalParamInNestedForLoops,
StructArrayParameterInitializedByPatternPassedAsPort; and the two joint conversions
NestedStructArray...PassedAsPort and ibex_alu (`IDENTICAL,OK,OK,1028,1028`). The class-variable and
port-connection cases: section 3 (every `pc/*` IDENTICAL on and off; the class cases as listed).

## 8. Residues re-measured at 73a67945 (evidence/residue_rows_head.txt, residue_cases_head.txt)

Pass 147 (R-list): R1 (r11u151's own) partly cleared: C3 both rows CMP_EQUAL (joint conversion above); R-D1..D3
stand (StructParamFuncBodyFieldCompare / StructParamPatternInitCast d/t `fullname(15)`), R-D4 stands
(FuncStructVal testflags `endcol(363)`, diverged). R2 StringMethod d/t `fullname(2)`: stands. R3 stands:
iface_struct_field_partsel `fullname(13)` (was 15), iface_arr_struct_field_partsel `fullname(4)`,
anon_struct_packed_dim `fullname(43)`, `tsi/a6` 10 objects, `tsi/b2` 4, `pos/n5` 2, `mec/f02 f03` 8 / 7.
Pass 147 (S-list): S1 GenForIfaceLocalparamBound / ...NestedGen d/t `endcol(1)` stands; S2 PortInitVal d/t,
PortInitVal2 d/t, sat_asserts_seq d/t are now CMP_EQUAL (cleared by a later pass); S3 genscope_module_ctx_reset
d/t `fullname(1)` stands.
r11v147 (1-3): the same three (r11u151's own, StringMethod, interface paths: `x4` 2 objects, `x7` stage 1 148
lines).
Pass 152 (1-3): N0472 param_array_wildcard / type_param_override_elem_sel d/t `fullname(1)` stand; the ibex family
stands except ibex_alu (CMP_EQUAL, joint); ibex_branch_predict `line(12)`, ibex_icache `line(160)`,
ibex_tracer `fullname(579)`; ParamTypespec2 d/t `fullname(3)` stands.
v11u152 (1-3): KP p03 / KY y04 `endcol` (4 objects each) stand; KW w06 stage 1 (184 lines) stands; KE e01 stage 1
(17 lines) stands.

New residues from this pass, ranked:

1. **The non-package enum alias typedef object** (module, `$unit`, interface: `typedef lp::tx_e my_t;`): golden's
   is a clone of the enum (its span, `Typedef_alias` -> the enum, ElaborationStep.cpp:201-208); ours spans the
   typedef declaration and has no alias reference (stage 1 on `ea/e02 e04 e05 e07`, r11u152 EA e03). In a module
   or `$unit` the plugin reads the packed-array-of-alias variable 32 or 64 bits wide where golden's is 4 or 8
   (downstream DIVERGENT on every binary). Once it is fixed, § packedElemAliasTypedef152 can drop
   § elemAliasPkgScope159v's gate.
2. **The multi-assignment continuous assign delay** (`assign #d b = a, c = ~a;`): ours attaches the delay to
   every net assignment, golden to the first only (`dv/d01`, `d04`; walk diverged).
3. v11u152's residue 4 on a named instance with an import (`pc/q06`): the positional fold against golden's
   `ref_obj`.

## 9. The fence and the process

- **No law, case or number of this pass rests on a fenced head.** No fenced source, copy or sweep database was
  opened; the byte comparisons ran on mirrors without them; the only reads of `FENCED_2` are sweep verdicts.
  Pass 147's ENUMCLONE and ENUMQSPAN laws re-derive from fresh cases and Surelog's source (section 3).
  `r11u143verify/cases/fence_s3` are fresh shapes (its README section 7), not copies.
- **Drivers that read corpus databases or dispatch corpus rows without refusing when `$FENCED` is missing, or
  without skipping those names:**
  - r11u147repro: `changecheck.sh`, `dist.sh`, `fieldcmp.sh`, `row.sh` (a `--filter` regex, no fence), and
    `rowpaths.sh`. `tracewrap.sh` is the census stand-in for a full `tests/sweep.sh` run: it ran the law binary
    on the fenced row's sources in a census, which is not a gate sweep. Its README discloses the firing it read.
    The r11u147repro drivers also source `/tmp/r11u147_env.sh`, which is not committed, so they do not run from
    the repository as committed.
  - r11v147repro: `dist.sh` and `first.sh`.
  - v11u152repro: `normmd5.sh` hashes every `*.uhdm` of any directory given, with no fence.
  - Compliant: r11u147 `bytes.sh`; r11v147 `bytes.sh`, `rc.sh`, `env.sh`; r11u152 `attrib.sh`, `changecheck.py`,
    `heads.sh`, `uvmmovers.sh`; v11u152 `corpusdist.sh`.
  - Case-only or probe-only (no corpus read): r11u147 `rc.sh`, `cx.sh`, `grid.sh`, `switches.sh`; r11v147 `sw.sh`,
    `pdump.sh`, `ds.py`; r11u152 `grid.sh`, `gridall.sh`, `attrib_probe.sh`, `byteonly.sh`, `attrib_table.py`
    (csv verdicts); v11u152 `case.sh`, `grid.sh`, `dscase.py`, `dumpdist.py`.
  - Landed with pass 147: `tools/probe/r11u151struct/drivers/census.py` and `swcheck_rows.py` spell the four
    fenced names literally, in their exclusion sets.
- **Evidence outside its own directory:** the pass-147 landing (b6af876c) touched only `src/`, `results/`,
  `tests/LAWS.md` and its two directories. No `.gpath` file is tracked anywhere, and the seven directories that
  held them list only `dut.sv`. One dangling reference: r11u147repro's README cites `evidence/fieldcmp.txt`
  ("the strict comparator's field tally of the two databases the sweeps wrote", fenced row included), which is
  not committed. That read, a binary run on a fenced sweep database, is one the current brief forbids. No law and
  no committed number depends on it.
- **This pass:** wrote only under `/tmp/wt_r11u159*`, `/tmp/r11u159_*` and the relocated golden cache
  `/tmp/r11u159_dsgold`. It ran its own binaries only on its own cases, on tools/probe cases read from the
  worktree copy, and inside the sweeps. One incident: a first `bytes.sh` launch pointed at the main tree's
  tools/probe, read-only (outputs to `/tmp`). It was stopped by pid after checking the command line, and the run
  was repeated on the worktree copy. The main tree's `git status` is clean.

## 10. Files

- `cases/<group>/<case>/dut.sv`: 136 cases (first line `// § <law>`; `cx/*` name two or three laws).
- `fix.patch`: the two refinements. The directory names them with the section sign, so the commit that lands it
  (or this directory) regenerates `tests/LAWS.md` with `scripts/law_index.py`.
- `drivers/`:
  - Environment and cases: `env.sh` (tools, `$FENCED`), `case.sh` (one case: golden, ours, uhdm-cmp,
    uhdm-strictcmp), `grid.py` (states and scores), `dscase.py` (downstream per case and state),
    `summarize.py` (law_tables.md).
  - Sweeps: `sweep.sh` (the gate sweep with a frozen binary), `bvmirror.sh` (fence-free hard-link mirror for
    byteverify), `coin.sh` (the order-blind UVM coin check).
  - Composition and unmaskings: `compose.py` (the census), `unmask.py` (records of every moved row),
    `samepair.py` (records paired by walk index).
  - The fix: `tracewrap.sh` (its census stand-in), `bytes.sh` (all tools/probe cases on two binaries).
- `evidence/`:
  - Grids: `grid_default.txt`, `grid_elabuhdm.txt`, `law_tables.md` (per case: on, off, score, downstream, fix).
  - Downstream: `downstream_cases_{on,ownoff,alloff}.txt`, `downstream_fix_breakcases.txt`,
    `downstream_e08_width.txt` (the interface case's two lanes' wire widths under the law, its switch and the fix).
  - Sweeps: `sweep_{L,A,X,Y,P,Q,F}.log`, `sweeps_summary.txt`, `canaries_head.txt`.
  - Bytes: `byteverify_*.txt`, `coin_*.txt`, `bytes_toolsprobe_head_vs_fix*.txt`.
  - Composition and unmaskings: `composition_census.txt`, `unmask_alloff_vs_on.txt`, `unmask_same_objects.txt`.
  - The fix: `fix_census_prediction.txt`, `fix_vs_on_all_cases.txt`.
  - Residues: `residue_rows_head.txt`, `residue_cases_head.txt`.

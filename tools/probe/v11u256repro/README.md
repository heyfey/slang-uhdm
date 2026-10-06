# v11u256 — adversarial verification of r11u256 (pass 256, the expression/parameter ground)

Base 5b903eef. Implementer's patch /tmp/r11u256.patch (md5 e2f6d5592ca8409eefe311266049d761): four laws in
src/ExprEmit.cpp and src/ParamEmit.cpp behind src/R256.h (tools/probe/r11u256repro/README.md).

**Verdict: ACCEPT WITH ONE FIX.** Every headline number of the implementer reproduces. One fresh case shape on legal SV
went from pristine-right to law-wrong: a streaming target inside a macro body. It is fixed behind its own switch,
§ macroIpsBaseStreamAbstain256v (`R11V256_STREAMABSTAIN_OFF`; `R11V256_OFF` gives the law's bytes, `R11U256_OFF`
still gives pristine's). The fix moves no gate database against the law. Two delivery defects are corrected:
22 grid cases named a draft law, and one driver wrote into the implementer's scratch.

## 1. The rows (fresh csv rows; results/ untouched)

| row-mode | base | law = fix sweep |
|---|---|---|
| Rggen default | `differ:col(129)`, head #27671 | `Rggen,default,STRICT_NOTEQUAL,differ:type(1),,differ:type(1)` |
| Earlgrey_0_1 default | `differ:fullname(117)` | `Earlgrey_0_1,default,STRICT_NOTEQUAL,differ:fullname(79),,differ:fullname(79)` |
| Earlgrey_0_1 testflags | `differ:fullname(24)` | unchanged; the bytes move (67 records toward golden, 0 away) |
| BlackBePipeInt d/t | depth(1) | unchanged (not attempted by the pass) |

There is no conversion. The heads after the law, quoted from uhdm-strictcmp on the law sweep's databases:
* **Rggen default.** `#92960 type`: golden `range` at block_0.sv 1811:46-47, ours `ref_typespec`; the walk then
  diverges. This is § genLpUnpackedArray, ModuleEmit, the sister ground.
* **Earlgrey default.** `#136315 fullname`: golden `ref_typespec work@sha2`, ours empty (TypeEmit
  crossPkgBoundFoldConst9, sister). It is followed by #214684 / #214686, the `prim_cipher_pkg::PRINCE_ROUND_CONST`
  var_select and part_select full names (TypeEmit § defGenPathSel161, sister).
* **Earlgrey testflags.** `#137760 fullname`, then #216212 and #216343. The walk diverges at `#403326 depth` (24
  objects), which confirms the implementer's account of why the count stays at 24.

## 2. Reproduction (binaries built here, frozen at /tmp/v11u256_bin before any measurement)

* **Build.** Pristine md5 02900011d91aa5da3d83d64143317a14, equal to the main tree's base build. The law build is md5
  bfdcaa5cf6e17d8ea33af50fd3ab6e62, equal to the implementer's. The fix is md5 7238dd5427598265c4fb551094e0bff2.
  uhdm-strictcmp is md5 fa6e4f42f252ae0ab69d9845003e71c5. All report slang 12.0.0+545f88b2e.
* **The patch** applies clean on a fresh 5b903eef (`git apply --check`, rc 0).
* **Sweeps.** `tests/sweep.sh --jobs 3`, all stages, into /tmp/v11u256_wP, _wL and _wF (same-length names;
  evidence/sweep_summary_*.txt, csvdiff.txt).
  * Probe: 3564 EQUAL + 523 STRICT_NOTEQUAL on all three binaries, regressions=0. Pristine reads 0 changes. The law
    and the fix read changes=2: `r10earl_repro/vo` fullname(2) -> (1) and `v11u115repro/grid/f1/v06_gf_vs_psel`
    fullname(3) -> (1).
  * Surelog corpus: regressions=0 conversions=0. Pristine reads 0 changes; the law and the fix read changes=2, the
    two rows above. The LowMem detail text differs only by the workdir path.
  * uhdm2rtlil corpus: 1606 + 0, 0 / 0 / 0 on all three binaries.
  * Downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 on all three. The csvs are byte-identical.
  * Every sweep exits 1 for ONE reason: at the base 5b903eef itself, `scripts/law_index.py --check` reads STALE.
    The pristine worktree, untouched, reads it too. The law and fix worktrees read it because this directory's cases
    were added mid-run. The delivered tree's index is regenerated and `--check` reads current (section 7).
* **Row-by-row strict column** (fence-filtered, evidence/csvdiff.txt): pristine -> law moves exactly the two corpus
  rows and two probe cases above. Law -> fix moves nothing in any of the four csvs.
* **byteverify** (fence-filtered hard-link mirrors, 2560 mirrored and 8 fenced row-modes skipped unread; SELFCHECK=1):
  * law vs pristine: MOVERS 3 / 2560. Earlgrey_0_1 d 9090c6a0bad8, Rggen d 526d684388db and Earlgrey_0_1 t
    b15a828ca58e are the implementer's hashes.
  * fix vs pristine: the same 3.
  * fix vs law: MOVERS 0 / 2560.
  * SELFCHECK reads 2559 / 2560 on every run. The negative control compares every database against ONE fixed
    database. The fixed database compared with itself is the one path that cannot be flagged, so N-1 is the
    passing reading (the script's own threshold is `>= na - 1`). It is not a movers line.
* **Probe and downstream bytes** (drivers/dbmovers.sh; evidence/probe_dbmovers.txt):
  * The probe databases embed the source path. The law and the fix were therefore also run through check_probe from
    the pristine worktree, and the comparison against pristine's databases reads 2 movers of 4087 for each. Those
    are exactly the two changed cases.
  * Fix vs law within one worktree: probe 0 of 4087, downstream 0 of 805.
  * Law vs pristine: downstream 0 of 805.
* **uhdm-cmp**: 0 lines on all three corpus movers (evidence/cmp_corpus_movers_law.txt). The fix's databases are
  byte-identical to these.
* **Firing census, frozen before the law sweep** (drivers/tracecensus.sh with --filter built from $FENCED;
  evidence/predict_law.txt). It is identical line for line to the implementer's predict.txt. It names Earlgrey d/t,
  Rggen d and the two probe cases, with nothing in uhdm2rtlil. All five moved, and nothing else moved.
  * The fix's prediction (evidence/predict_fix.txt) was frozen before the fix sweep: 0 movers against the law.
  * The refinement can only fire where the macro law fires, which in the census is Rggen default alone (522
    firings). The fix binary traced on Rggen default fires the refinement 0 times (evidence/fixcensus_rggen*).
  * The fix sweep read 0 movers against the law.
* **Binary-path audit** (fence-filtered path lists first; evidence/binaudit.txt): in each of the three sweeps, 3265 of
  3315 cmds.txt name that sweep's binary and 0 name another. The other 50 are Surelog-only runs with no slang line.
* **Canaries**: surelog ok=51 changed=1 (Earlgrey_0_1 default 117 -> 79) and uhdm2rtlil ok=16 changed=0, on both the
  law and the fix csvs. Both ctcan2 checks PASS (evidence/canaries.txt).
* **Determinism** (drivers/det.sh, three CONCURRENT harness runs per binary on Earlgrey_0_1 and the five UVM rows,
  both modes; evidence/det_law.txt, det_fix.txt): one hash per row-mode on 11 of 11 for both binaries.
  * Scoreboard testflags is SLANG_REJECT at the base.
  * Every hash equals the implementer's det_law.txt. The fix's hashes equal the law's.
  * The Earlgrey hashes equal the sweeps'.
* **Away census on the corpus movers.**
  * Flat, v11u202 away.py (evidence/awaycorp_law.txt): Earlgrey d 973 -> 935, Earlgrey t 717 -> 650, Rggen d
    523 -> 1; lost 0 on all three.
  * Chain-keyed, map 12's keys through r11u252's awaychain.py / awayrows.py with the variant comparator
    (evidence/awaychain_corpus_law.txt): away 0 on all three. Toward: Earlgrey d 67 chain / 38 flat, Earlgrey t 67,
    Rggen d 522.
* **The implementer's grid** (82 case dirs, 164 case-views, 1148 lines, rerun with the same seven configurations;
  evidence/impl_grid_rerun.txt, impl_gridsum_rerun.txt):
  * It is identical to the implementer's grid.txt in every field but the path-embedding md5: verdict, cmp rc,
    cmplines, strict and exit code on all 1148 lines.
  * R11U256_OFF gives pristine on 164 of 164. 114 case-views move, 80 enter STRICT_EQUAL and none leave.
  * By switch: MACROIPSBASE 42, GENIPSOWNER 38, BODYIPSSEL 20, PATLITFILE 14.
  * Away census on the 114 movers: lost 0 flat (impl_grid_away_rerun.txt) and away 0 chain-keyed
    (impl_grid_awaychain_PL.txt).
  * On the fix binary (impl_vgrid.txt): equal to the law on 164 of 164. R11V256_OFF gives the law's bytes and
    R11U256_OFF pristine's on all of them.
* **The implementer's byte controls** (the same 20 repro dirs, 1616 case dirs, 3232 case-views, three binaries;
  evidence/controls3_impl20.txt):
  * The law moves 6 case-views and 4 enter STRICT_EQUAL: r11u257 decode/HL h03 and h08 in both views, and v11u252
    VF/vf07 in both views (stage 1 with 60 uhdm-cmp lines on both binaries).
  * None leave, no exit code changes, and no uhdm-cmp line count changes.
  * The fix moves 0 against the law.
  * Three elaborated-view case-views crash with rc 139 on ALL three binaries: r11u254 F/f04_class and v11u254
    F/vf02_iface and F/vf04_hier. These are pass 254's standing --elabuhdm residue, not this pass's.
* **Widened controls** (11 more dirs: r11u154repro, r11v154repro, r11u178repro, r11u181repro, r11u184repro,
  r11u246repro, v11u246repro, r11u248repro, r11u255repro, v11u255repro, v11u250repro; 711 case dirs, 1422
  case-views; evidence/controls3_widen.txt):
  * The law moves 2: r11u154repro lv/m2 in both views, col -> STRICT_EQUAL. That is pass 154's macro-body
    `RIF.read_data[1:0]` target, cleared by MACROIPSBASE.
  * None leave. The fix moves 0 against the law.
* **Downstream on the implementer's 82 case dirs** (drivers/dscases.py, three binaries; evidence/ds_impl_*.txt):
  80 IDENTICAL and 2 EQUIVALENT (F/f08, M/m04), the same verdict on all three binaries.

## 3. The attack: 81 fresh case dirs (cases/B, F, G, M), 162 case-views

Every case is in both views. There are two grids:
* evidence/fresh_grid.txt has 1134 lines on 7 configurations: P, L, OFF and each of the four switches off.
* evidence/fresh_vgrid.txt has 810 lines on 5 configurations: P, L, FIX, FIX + R11V256_OFF, and FIX + R11U256_OFF.

Every line carries its exit code. The goldens come from the v1.87 pin.
* **The law against pristine** (fresh_gridsum.txt):
  * R11U256_OFF gives pristine on 162 of 162. 108 case-views move and 78 enter STRICT_EQUAL. None leave
    STRICT_EQUAL, no exit code changes, and no uhdm-cmp line count changes.
  * By switch: MACROIPSBASE 32, GENIPSOWNER 30, BODYIPSSEL 24, PATLITFILE 22. Each mover is moved back by exactly
    one switch.
  * 14 lines exit 4, all M/vm01_paste (a pasted member token), on every binary and configuration.
* **THE BREAK.** The away census (fresh_away.txt flat, fresh_awaychain_PL.txt chain-keyed) reads 0 lost on 102 of
  the 108 movers. It reads 2 records LOST in both views of M/vm09_streaming, vm18_stream_concat_macro and
  vm21_stream_sliced_macro:
  * `define wr(FIF) always_comb {>>{FIF.read_data[3:0]}} = x;` (and `{>>{FIF.read_data[3:0], y}}`,
    `{<<4{FIF.read_data[7:0]}}`), used on an interface port.
  * Golden's base `ref_obj bit_field_if` spans the ACTUAL in the expanded text (dut.sv 3:19-31), as pristine wrote
    it. The law moved it to the member token (3:32-41): `#45 col` A 3:19-31, B 3:32-41.
  * The first strict field turned from defname to col. The distance went 2 -> 4, with 2 lost and 0 gained.
  * Golden compiles a streaming operand as an rvalue, so it does not anchor the lvalue base at the first member.
    The existing helper lvStreamOperand181 (ExprEmit, the same model pass 178/181 used for the procedural-lvalue
    laws) already answers this.
* **The fix: § macroIpsBaseStreamAbstain256v** (`R11V256_STREAMABSTAIN_OFF`; ExprEmit, inside the
  § macroIfaceRangeSelBaseTok256 condition). The macro law abstains when `lvStreamOperand181(parent)` holds; the
  abstention is traced under R11U256_TRACE.
  * fresh_vgridsum.txt: the fix moves exactly those 6 case-views against the law, each back to pristine's bytes.
    Each moves 2 records toward golden and 0 away.
  * Against pristine, the fix moves 102 case-views with 78 entering STRICT_EQUAL, none leaving, and 0 away
    chain-keyed (fresh_awaychain_PFIX.txt).
  * R11V256_OFF gives the law's bytes and R11U256_OFF pristine's on 162 of 162.
* **Downstream on the 81 fresh case dirs** (evidence/ds_fresh_*.txt): 78 IDENTICAL and 3 EQUIVALENT (F/vf05,
  M/vm01, M/vm02). The verdict is the same on all three binaries.
* **Shapes covered, beyond the implementer's grid.**
  * Macro law: a pasted member token, the member name as an argument, an interface-array element, a down select in
    an always_comb, a nonblocking write in a procedural loop, spaces and a line continuation inside the path, a
    virtual-interface `this.` path in a class task, a cross-module child path, three stream targets, an increment,
    the target through two macro levels, the whole target as an argument, a call bound, a modport port in a
    two-level generate, an include-born macro used from two root files, CRLF, and a struct member behind an
    interface. The plain-source twins are controls.
  * § genIpsBoundOwner256: for inside if, if inside for, case with an operand, instance depth 3, user and system
    call arguments, a select in an index, an operation base, a genvar base, a generate-local localparam, a
    replication, an else branch, an unnamed generate block, the top module, a ternary condition, a down select, two
    instances in two scopes, a plain part select, a two-level for, LHS whole and concatenation targets in
    if / case / for, an operand two operations deep, and an interface in an if-generate at depth 2.
  * § elabBodyIpsBoundSelName256: a call argument under an operation, a concatenation in a ternary, a replication, a
    cast, a condition, a struct member, an array element, an implicit-net target, inside, depths 2 and 3, a macro
    select, a class-specialization parameter in the bound, qualified bounds two operations deep, a unary reduction,
    a concatenation target, an always_comb control, a program, a net declaration assignment, and instances in for
    and if generates.
  * § patLitFormFileAtRef256: positional, default:, nested patterns, an enum member, an instance override, a pattern
    in an included header, a macro from an include, a macro defined in the package file, a third file, a package
    pattern, a generate scope, an import at depth 2, an expression member, and a class localparam.
  * No other shape loses a record.

| case | law (first line) | what it tests | default / elaborated: P -> L (-> fix) |
|---|---|---|---|
| `B/vb01_call_arg_op` | § elabBodyIpsBoundSelName256 | the select a user function argument under an operation | fullname -> fullname / fullname -> fullname |
| `B/vb02_concat_in_tern` | § elabBodyIpsBoundSelName256 | the select in a concatenation inside a ternary branch | fullname -> EQ 394 / fullname -> EQ 393 |
| `B/vb03_replication` | § elabBodyIpsBoundSelName256 | the select inside a replication operand | fullname -> EQ 393 / fullname -> EQ 391 |
| `B/vb04_cast` | § elabBodyIpsBoundSelName256 | the select under a size cast and an operation | fullname -> EQ 391 / fullname -> EQ 391 |
| `B/vb05_cond` | § elabBodyIpsBoundSelName256 | the select in a ternary condition | fullname -> EQ 378 / fullname -> EQ 377 |
| `B/vb06_struct_member` | § elabBodyIpsBoundSelName256 | the select of a struct member under an operation | fullname -> fullname / fullname -> fullname |
| `B/vb07_array_elem` | § elabBodyIpsBoundSelName256 | the select of an unpacked array element under an operation | fullname -> fullname / fullname -> fullname |
| `B/vb08_implicit_target` | § elabBodyIpsBoundSelName256 | an implicit-net target under a ternary | fullname -> EQ 408 / fullname -> EQ 407 |
| `B/vb09_inside` | § elabBodyIpsBoundSelName256 | the select an operand of inside | fullname -> EQ 374 / fullname -> EQ 373 |
| `B/vb10_depth3_two` | § elabBodyIpsBoundSelName256 | two instances at depths 2 and 3, a ternary branch | fullname -> EQ 655 / fullname -> EQ 656 |
| `B/vb11_macro_sel` | § elabBodyIpsBoundSelName256 | the select written by a macro in a ternary branch | fullname -> EQ 383 / fullname -> EQ 381 |
| `B/vb12_class_param_bound` | § elabBodyIpsBoundSelName256 | a class-specialization parameter in the bound, a ternary branch | stage1 -> stage1 / stage1 -> stage1 |
| `B/vb13_qualified_nested` | § elabBodyIpsBoundSelName256 | package-qualified bounds nested two operations deep | stage1 -> stage1 / stage1 -> stage1 |
| `B/vb14_unary` | § elabBodyIpsBoundSelName256 | the select under a unary reduction and a logical operation | fullname -> EQ 375 / fullname -> EQ 373 |
| `B/vb15_lhs_concat_tern` | § elabBodyIpsBoundSelName256 | a concatenation target, a ternary right side | EQ 424 -> EQ 424 / EQ 413 -> EQ 413 |
| `B/vb16_always_ctrl` | § elabBodyIpsBoundSelName256 | an always_comb control beside the continuous assignment | fullname -> EQ 415 / fullname -> EQ 407 |
| `B/vb17_program` | § elabBodyIpsBoundSelName256 | a ternary branch in a program continuous assignment | EQ 261 -> EQ 261 / EQ 261 -> EQ 261 |
| `B/vb18_nda` | § elabBodyIpsBoundSelName256 | a net declaration assignment with a nested select | EQ 394 -> EQ 394 / EQ 380 -> EQ 380 |
| `B/vb19_inst_in_genfor` | § elabBodyIpsBoundSelName256 | the module instantiated inside a for-generate and an if-generate of its parent, a ternary branch | fullname -> EQ 561 / fullname -> EQ 560 |
| `F/vf01_positional` | § patLitFormFileAtRef256 | a positional pattern of package values | file -> EQ 315 / file -> EQ 314 |
| `F/vf02_default` | § patLitFormFileAtRef256 | a default: pattern key | file -> EQ 297 / file -> EQ 296 |
| `F/vf03_nested` | § patLitFormFileAtRef256 | a nested pattern of package values | file -> EQ 352 / file -> EQ 351 |
| `F/vf04_enum_member` | § patLitFormFileAtRef256 | an enum constant from another file as a member | file -> EQ 313 / file -> EQ 312 |
| `F/vf05_inst_override` | § patLitFormFileAtRef256 | a pattern given as an instance parameter override | stage1 -> stage1 / stage1 -> stage1 |
| `F/vf06_header_inc` | § patLitFormFileAtRef256 | the pattern written in an included header inside the module | file -> EQ 325 / file -> EQ 324 |
| `F/vf07_macro_hdr` | § patLitFormFileAtRef256 | the member value from a macro defined in an include | file -> EQ 325 / file -> EQ 324 |
| `F/vf08_third_file` | § patLitFormFileAtRef256 | the struct type and the value in two other files | file -> EQ 329 / file -> EQ 328 |
| `F/vf09_pkg_in_pkg` | § patLitFormFileAtRef256 | a package pattern reading another file package | stage1 -> stage1 / stage1 -> stage1 |
| `F/vf10_gen_scope` | § patLitFormFileAtRef256 | the pattern inside a generate scope | stage1 -> stage1 / stage1 -> stage1 |
| `F/vf11_import_star_child` | § patLitFormFileAtRef256 | an imported pattern member in a child instance at depth 2 | file -> file / file -> file |
| `F/vf12_expr_member` | § patLitFormFileAtRef256 | a member written as an expression of a package value (control) | file -> EQ 326 / file -> EQ 325 |
| `F/vf13_class_param` | § patLitFormFileAtRef256 | the pattern a class localparam | stage1 -> stage1 / stage1 -> stage1 |
| `F/vf14_macro_in_pkg_file` | § patLitFormFileAtRef256 | the member value written by a macro defined in the package file | file -> EQ 204 / file -> EQ 203 |
| `G/vg01_for_in_if` | § genIpsBoundOwner256 | a for-generate inside an if-generate, whole right side | EQ 411 -> EQ 411 / EQ 406 -> EQ 406 |
| `G/vg02_if_in_for` | § genIpsBoundOwner256 | an if-generate inside a for-generate, select an operand | EQ 445 -> EQ 445 / EQ 439 -> EQ 439 |
| `G/vg03_case_op` | § genIpsBoundOwner256 | a case-generate, the select an operand | stage1 -> stage1 / stage1 -> stage1 |
| `G/vg04_depth3` | § genIpsBoundOwner256 | instance depth 3, the for-generate in the leaf | fullname -> EQ 546 / fullname -> EQ 545 |
| `G/vg05_call_arg` | § genIpsBoundOwner256 | a for-generate, the select a user function argument | stage1 -> stage1 / stage1 -> stage1 |
| `G/vg06_sel_in_index` | § genIpsBoundOwner256 | a for-generate, the select inside another select index | fullname -> EQ 404 / fullname -> EQ 402 |
| `G/vg07_op_base` | § genIpsBoundOwner256 | a for-generate, a base computed from two package parameters | stage1 -> stage1 / fullname -> fullname |
| `G/vg08_genvar_base` | § genIpsBoundOwner256 | a for-generate, genvar base and package width | fullname -> EQ 420 / fullname -> EQ 419 |
| `G/vg09_gen_localparam` | § genIpsBoundOwner256 | a for-generate-local localparam taken from the package as the width | fullname -> EQ 439 / fullname -> EQ 438 |
| `G/vg10_replication` | § genIpsBoundOwner256 | a for-generate, the select inside a replication | fullname -> EQ 442 / fullname -> EQ 440 |
| `G/vg11_else_whole` | § genIpsBoundOwner256 | an if-else generate, the else branch, whole right side | fullname -> EQ 373 / fullname -> EQ 372 |
| `G/vg12_unnamed_genblk` | § genIpsBoundOwner256 | an unnamed generate for-block in a generate region | fullname -> EQ 424 / fullname -> EQ 423 |
| `G/vg13_top_for` | § genIpsBoundOwner256 | a for-generate in the top module itself | fullname -> EQ 298 / fullname -> EQ 296 |
| `G/vg14_cond_select` | § genIpsBoundOwner256 | an if-generate, the select in a ternary condition | fullname -> EQ 387 / fullname -> EQ 386 |
| `G/vg15_down_op` | § genIpsBoundOwner256 | a for-generate, a down select an operand | stage1 -> stage1 / fullname -> fullname |
| `G/vg16_two_inst` | § genIpsBoundOwner256 | two instances of one module in two scopes, a for-generate operand | fullname -> EQ 680 / fullname -> EQ 682 |
| `G/vg17_part_ps` | § genIpsBoundOwner256 | a for-generate, a plain part select bounded by package parameters | EQ 462 -> EQ 462 / EQ 437 -> EQ 437 |
| `G/vg18_nested_for2` | § genIpsBoundOwner256 | a two-level for-generate, the select an operand two scopes down | EQ 487 -> EQ 487 / EQ 470 -> EQ 470 |
| `G/vg19_if_lhs_whole` | § genIpsBoundOwner256 | an if-generate, the select the whole target | fullname -> fullname / fullname -> fullname |
| `G/vg20_case_lhs_whole` | § genIpsBoundOwner256 | a case-generate, the select the whole target | stage1 -> stage1 / stage1 -> stage1 |
| `G/vg21_if_lhs_concat` | § genIpsBoundOwner256 | an if-generate, the select inside a concatenation target | stage1 -> stage1 / col -> col |
| `G/vg22_for_lhs_concat` | § genIpsBoundOwner256 | a for-generate, the select inside a concatenation target | stage1 -> stage1 / fullname -> fullname |
| `G/vg23_if_two_ops` | § genIpsBoundOwner256 | an if-generate, the select two operations deep | fullname -> EQ 392 / fullname -> EQ 390 |
| `G/vg24_if_call_arg` | § genIpsBoundOwner256 | an if-generate, the select a system-call argument | stage1 -> stage1 / stage1 -> stage1 |
| `G/vg25_iface_in_gen` | § genIpsBoundOwner256 | an interface with a for-generate body, instantiated inside an if-generate at depth 2 | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm01_paste` | § macroIfaceRangeSelBaseTok256 | a pasted member token in the macro body | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm02_member_arg` | § macroIfaceRangeSelBaseTok256 | the member name an argument, the base in the body | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm03_iface_array` | § macroIfaceRangeSelBaseTok256 | an interface array element base in the macro | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm04_downsel_comb` | § macroIfaceRangeSelBaseTok256 | a down select with parameter bounds in an always_comb | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm05_for_nb` | § macroIfaceRangeSelBaseTok256 | a nonblocking write in a procedural for loop | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm06_spaces_lines` | § macroIfaceRangeSelBaseTok256 | spaces and a line continuation inside the path | col -> col / col -> col |
| `M/vm07_class_vif` | § macroIfaceRangeSelBaseTok256 | a virtual-interface path in a class task through this. | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm08_hier_inst` | § macroIfaceRangeSelBaseTok256 | a cross-module path to a child variable in the macro | col -> EQ 53 / col -> EQ 47 |
| `M/vm09_streaming` | § macroIpsBaseStreamAbstain256v | a streaming target in a macro body: golden keeps the actual span; the law broke it, the fix restores it | defname -> col -> fix defname / defname -> col -> fix defname |
| `M/vm10_incdec` | § macroIfaceRangeSelBaseTok256 | an increment of the selected path in a macro | col -> col / col -> col |
| `M/vm11_macro_in_macro_arg` | § macroIfaceRangeSelBaseTok256 | the whole target passed through two macro levels as an argument | col -> EQ 105 / col -> EQ 98 |
| `M/vm12_target_arg` | § macroIfaceRangeSelBaseTok256 | the whole selected target a macro argument | col -> EQ 105 / col -> EQ 98 |
| `M/vm13_call_bound` | § macroIfaceRangeSelBaseTok256 | a function call in the select base | stage1 -> stage1 / stage1 -> stage1 |
| `M/vm14_modport_gen` | § macroIfaceRangeSelBaseTok256 | a modport port in a two-level generate | col -> EQ 197 / col -> EQ 146 |
| `M/vm15_inc_two_roots` | § macroIfaceRangeSelBaseTok256 | an include-born macro used from two root files | col -> EQ 183 / col -> EQ 169 |
| `M/vm16_crlf_ps` | § macroIfaceRangeSelBaseTok256 | a plain part select in a macro body, CRLF line ends | col -> EQ 105 / col -> EQ 98 |
| `M/vm17_stream_plain` | § macroIfaceRangeSelBaseTok256 | a streaming target outside a macro: residue, pristine wrong, golden keeps the actual span | col -> col / col -> col |
| `M/vm18_stream_concat_macro` | § macroIpsBaseStreamAbstain256v | a streaming target with a concatenation in a macro body: golden keeps the actual span | defname -> col -> fix defname / defname -> col -> fix defname |
| `M/vm19_concat_lhs_macro` | § macroIfaceRangeSelBaseTok256 | a concatenation target in a macro body, no stream: the law moves it to golden | col -> EQ 120 / col -> EQ 110 |
| `M/vm20_stream_bitsel_macro` | § macroIfaceRangeSelBaseTok256 | a bit-select streaming target in a macro body: the bit-select branch, § macroIfacePathTokSpans183, residue | col -> col / col -> col |
| `M/vm21_stream_sliced_macro` | § macroIpsBaseStreamAbstain256v | a sliced right-to-left streaming target in a macro body | defname -> col -> fix defname / defname -> col -> fix defname |
| `M/vm22_iface_struct_member` | § macroIfaceRangeSelBaseTok256 | an interface path through a struct member, a part select in a macro body | endline -> EQ 105 / endline -> EQ 98 |
| `M/vm23_iface_struct_member_plain` | § macroIfaceRangeSelBaseTok256 | the plain-source twin of vm22: no macro, the law does not run | EQ 105 -> EQ 105 / EQ 98 -> EQ 98 |

## 4. The law statements as verified

* **§ macroIfaceRangeSelBaseTok256** (`R11U256_MACROIPSBASE_OFF`). In a macro expansion, an lvalue interface /
  hierarchical path with a trailing part select or indexed part select anchors its base ref at the first member's
  token, read from the path's syntax. It applies unless the path sits inside a streaming concatenation's operand:
  the fix's § macroIpsBaseStreamAbstain256v, `R11V256_STREAMABSTAIN_OFF`.
* **§ patLitFormFileAtRef256** (`R11U256_PATLITFILE_OFF`). A struct-pattern member constant re-located at its
  setter takes the setter's file. Verified on positional, default, nested and enum forms, an included-header
  pattern, macro setters from an include and from the package file, a third file and a package-level pattern.
* **§ genIpsBoundOwner256** (`R11U256_GENIPSOWNER_OFF`) and **§ elabBodyIpsBoundSelName256**
  (`R11U256_BODYIPSSEL_OFF`). These are as the implementer states them. No fresh shape on either law moved a record
  away from golden.

## 5. Residues, ranked (all wrong on pristine too; none moved away by the law or the fix)

1. **The streaming-target anchor outside this law.**
   * A streaming lvalue outside a macro (M/vm17: § lvPathBaseAtFirstMember154's text-offset path) and a bit-select
     streaming lvalue in a macro (M/vm20: § macroIfacePathTokSpans183's token path) both anchor the base at the
     first member. Golden keeps the actual: `#45 col` A 4:19-31, B 4:32-41.
   * The same lvStreamOperand181 abstention in those two branches would clear them. That changes the bytes of passes
     154 and 183, so it needs its own pass and its own byte controls.
   * In the macro streaming cases (vm09, vm18, vm21) the next record after the abstention is the part_select
     vpiDefName `read_data` that golden leaves empty: `#46 defname`, golden `bit_field_if.read_data[3:0]` with no
     defname. It is wrong on pristine too.
2. **Module-body selects the BODYIPSSEL branch does not reach.**
   * A select as a user-call argument under an operation (B/vb01): golden `work@top.u.a`, ours `work@top.u`; the
     law abstains on a func_call parent.
   * A struct-member select (B/vb06): golden `work@top.u.s.f[2+:3].f`, the implementer's B b07 shape.
   * An unpacked-element select (B/vb07): golden `work@m`, ours `work@m.arr`; the law does not move it.
3. **Generate-scope selects GENIPSOWNER does not reach.**
   * An if-generate select as the WHOLE TARGET (G/vg19): golden `work@top.u`, ours `work@top.u.gw`.
   * The case and LHS-concatenation shapes are stage 1 on every binary: vg20, vg21, vg22.
4. **§ patLitFormFileAtRef256 does not fire on an unqualified wildcard-imported member at depth 2** (F/vf11): golden
   dut.sv 3:52-61, ours pk.sv 3:38-42. This is the implementer's F f02 residue.
5. **Macro location faces on other branches.**
   * The base of an increment target in a macro (M/vm10): golden 3:16-25, ours 3:3-15.
   * The indexed_part_select start column with spaces inside the path (M/vm06): golden 3:25, ours 3:23.
6. **Stage-1 cells**, wrong on pristine as well:
   * B/vb12 and vb13;
   * F/vf05, vf09, vf10 and vf13;
   * G/vg03, vg05, vg07, vg15, vg24 and vg25;
   * M/vm01 to vm05, vm07 and vm13.
7. **Not attempted by the pass and not attempted here:**
   * the implementer's own section-6 list (Earlgrey #464077, #600811 / #600816, #474416 to #481722, and the
     testflags `--elabuhdm` `::` listing #216212);
   * BlackBePipeInt #331795 / #331692 and the brief's items (4) to (7).

**Sister-ground faces**, as the implementer reports them. The Earlgrey and Rggen first records were re-read here
from the law sweep's databases.
* Earlgrey #136315 / #137760: TypeEmit crossPkgBoundFoldConst9.
* #214684 / #214686 and testflags #216343: TypeEmit § defGenPathSel161.
* #233633 / #233638: ModuleEmit, the rstmgr names.
* #375033 onward: ModuleEmit, the instance prefix missing a generate scope.
* #620047 to #620111: ModuleEmit `dottedLhs`, the implementer's new decode, not re-derived here.
* Rggen #92960: § genLpUnpackedArray, ModuleEmit.
* MiniAmiq / SeqDriver: at this base the heads are the sister pass's. Pass 259 has since landed on main as
  e35381745.

## 6. Delivery corrections made here

* **22 grid cases named a draft law.** r11u256repro cases/G g01 to g22 named the draft law `genCaIpsBoundOwner256` (written here without its section sign, so the index does not list it) in their first
  line. That law exists nowhere in the source, so tests/LAWS.md attributed only 6 cases to § genIpsBoundOwner256.
  * All 22 first lines now read `// § genIpsBoundOwner256`.
  * Only the comment changes, on the same line, so no case's bytes move.
  * The regenerated index lists 28 evidence cases under the law.
* **dbmovers.sh wrote into the implementer's scratch.** r11u256repro/drivers/dbmovers.sh writes its path lists to
  the hard-coded /tmp/r11u256_s. This copy (v11u256repro/drivers/dbmovers.sh) writes them under $S and refuses to
  run without it. The implementer's file is left as delivered.
* **R256.h named the trace file `<pid>.254`.** The code writes `.256`, and the comment now says so.

## 7. Gates on the delivered tree

* The patch /tmp/r11u256.verified.patch is the git diff against 5b903eef. It holds:
  * the implementer's production change, plus the fix in src/ExprEmit.cpp and src/R256.h;
  * the regenerated tests/LAWS.md (`scripts/law_index.py --check` reads current on the delivered tree);
  * tools/probe/r11u256repro, with the 22 first lines corrected;
  * this directory.
* It applies clean on a fresh 5b903eef. `tests/sweep.sh --corpus probe` with the fix binary on the delivered tree exits 0
  (3564 + 523, regressions 0, changes 2).
* The fix binary's gates, from the fix sweep:
  * Probe 3564 + 523: regressions 0, changes 2.
  * Surelog: regressions 0, conversions 0, changes 2.
  * uhdm2rtlil: 0 / 0 / 0.
  * Downstream: 803 / 66 / 2 / 0.
  * byteverify: 3 movers against pristine, 0 against the law.
  * Probe and downstream bytes: 0 movers against the law.
  * Canaries: ok=51 changed=1 and ok=16; both ctcan2 checks PASS.
  * Binary-path audit: 3265 of 3315.
  * Determinism: 11 of 11.

## 8. Process

* **Order of work.** The pristine binary was frozen before any source edit. The law was built in its own worktree
  and frozen. The fix was written only after both binaries were frozen. Its prediction was frozen before the fix
  sweep.
* **Fence.**
  * Every scan built its path list first and filtered it by $FENCED (word boundary, read from canaudit.sh's
    FENCED= line), then opened files: bvmirror.sh, dbmovers.sh, the cmds.txt audit and the csv diffs.
  * The census ran with the harness's --filter built from $FENCED.
  * The four fenced tests were dispatched only by the gate sweeps. No fenced source or database was read, and no
    fenced head was decoded.
  * The evidence files carry no fenced row.
* **No process was signalled.** No pgrep -f or ps listing was used; background jobs were waited on by their own
  completion markers.
* **One slip.** The first case run of a scratch probe used a relative path into the case store and listed nothing.
  It was redone with the store's absolute path. Nothing was written outside this pass's scratch
  (/tmp/v11u256_*) and worktrees (/tmp/wt_v11u256, /tmp/wt_v11u256pris).

## 9. Files

* `cases/B` (§ elabBodyIpsBoundSelName256), `cases/F` (§ patLitFormFileAtRef256), `cases/G`
  (§ genIpsBoundOwner256) and `cases/M` (§ macroIfaceRangeSelBaseTok256, and § macroIpsBaseStreamAbstain256v on
  vm09, vm18, vm21). Each case's first line names its law.
* `drivers/`:
  * copied from r11u256repro: env.sh, case.sh, grid.sh, gridsum.py, controls.sh, away.py, awaycases.sh,
    awaychain.py, awaycorp.sh, dscases.py, det.sh, bvmirror.sh, tracecensus.sh, predict2.py, dbmovers.sh, heads.sh;
  * copied from r11u252repro: awayrows.py, strictcmp_x.cpp, cc_x.sh;
  * new here: pgrid.sh (parallel grids), vgrid.sh / vgridsum.py (P / L / FIX / VOFF / UOFF), controls3.sh /
    ctl3sum.py (three-binary byte controls) and awaychaincases.sh (the chain-keyed census of case-views).
* `evidence/`: every file named above.
